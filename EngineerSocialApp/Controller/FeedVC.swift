//
//  FeedVC.swift
//  UdemySocialApp
//
//  Created by 東原与生 on 2017/03/17.
//  Copyright © 2017年 yoki. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import MessageUI

class FeedVC: UIViewController, MFMailComposeViewControllerDelegate{

    @IBOutlet weak var mainView: UIView!
    
    var posts = [Post]()
    var imageSelected = false
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var postTableView: PostTableView!
    var selectedPostUserId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(type(of: self).showActionSheet(notification:)),
                           name: Notification.Name.PostCell.arrowDownNotification,
                           object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if postTableView != nil{
            self.getPostsFromFireBase()
        }
    }
    
    override func viewDidLayoutSubviews() {
        setPostTableView()
        getPostsFromFireBase()
    }
    
    @objc func showActionSheet(notification: NSNotification){
        guard let userInfo = notification.userInfo,
            let postUserId  = userInfo["postUserId"] as? String else {
                print("エラー：　No userInfo found in notification")
                return
        }
        print(postUserId)
        Alert.showReportActionSheet(vc: self, postUserId: postUserId) {
            //メールを送信できるかチェック
            if MFMailComposeViewController.canSendMail()==false {
                return
            }
            
            let mailViewController = MFMailComposeViewController()
            let toRecipients = ["yyokii.h@gmail.com"]
            
            mailViewController.mailComposeDelegate = self
            mailViewController.setSubject("お問い合わせ")
            mailViewController.setToRecipients(toRecipients)
            mailViewController.setMessageBody("不適切な投稿をした次のユーザーを通報しまします。\n " + postUserId, isHTML: false)
            
            self.present(mailViewController, animated: true, completion: nil)
        }
    }
    
    /// データベースから投稿情報を取得
    func getPostsFromFireBase() {
        //.value means  Any new posts or changes to a post
        DataService.ds.REF_POSTS.observeSingleEvent(of: .value , with: { (snapshot) in
            
            print("全ての投稿情報:\(snapshot)")
            
            self.posts = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("Snap: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        //self.posts.append(post)
                        self.posts.insert(post, at: 0)
                        
                    }
                }
                self.postTableView.posts = self.posts
                self.postTableView.reloadData()
            }
        })
    }
    
    /// 投稿表示用のテーブルビュー
    func setPostTableView(){
        let frame = CGRect(x: 0, y: 0, width: self.mainView.frame.width, height: self.mainView.frame.height)
        self.postTableView = PostTableView(frame: frame,style: UITableViewStyle.plain)
        postTableView.postTableViewDelegate = self
        postTableView.posts = self.posts
        // セルの高さを可変にする
        postTableView.estimatedRowHeight = 100
        postTableView.rowHeight = UITableViewAutomaticDimension
        // リフレッシュ機能をつける
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged(sender:)), for: .valueChanged)
        postTableView.addSubview(refreshControl)
        
        self.mainView.addSubview(postTableView)
    }
    
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        // FIXME: getPost()メソッドの処理と最後以外同じなのでリファクタしたい
        DataService.ds.REF_POSTS.observeSingleEvent(of: .value , with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("Snap: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        //self.posts.append(post)
                        self.posts.insert(post, at: 0)
                        
                    }
                }
                sender.endRefreshing()
                self.postTableView.posts = self.posts
                self.postTableView.reloadData()
            }
        })
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("JESS: ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: TO_SIGN_IN, sender: nil)
    }

    @IBAction func postTapped(_ sender: Any) {
        performSegue(withIdentifier: TO_POST, sender: nil)
    }
}

// FIXME: ベースビュー作って処理をまとめた方がいい、と思ったけどここだけに書けばいいみたい。。。
extension FeedVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is PostVC {
            let postStoryBoard = UIStoryboard(name: "Post", bundle: nil)
            let postVC = postStoryBoard.instantiateInitialViewController() as! PostVC
            self.present(postVC, animated: true, completion: nil)
            return false
        }
        return true
    }
}

extension FeedVC: PostTableViewDelegate{
    func didSelectCell(postUserId: String) {
        selectedPostUserId = postUserId
        if selectedPostUserId != KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: TO_POST_USER_PROFILE, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TO_POST_USER_PROFILE {
            let profileVC = segue.destination as! ProfileVC
            profileVC.profileType = ProfileVC.ProfileType.others
            profileVC.uid = selectedPostUserId!
        }
    }
    
    func didTableScrollToBottom(y: CGFloat) {
        // なにもしない
    }
    
    func didTableScrollToTop(y: CGFloat) {
        // なにもしない
    }
}
