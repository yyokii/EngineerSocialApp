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

class FeedVC: UIViewController {

    @IBOutlet weak var mainView: UIView!
    
    var posts = [Post]()
    var imageSelected = false
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var postTableView: PostTableView!
    var selectedPostUserId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = " :) Feed "
        
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
              let postKey  = userInfo["postKey"] as? String else {
                print("エラー：　No userInfo found in notification")
                return
        }
        print(postKey)
        
        Alert.showPostReportView(vc: self, title: "不適切なコンテンツ？", message: "不適切なコンテンツは非表示にしたり通報したりすることができます", firstTitle: "この投稿を非表示にする✨", secondTitle: "通報する⚠️", thirdTitle: "キャンセル🙅‍♂️", firstAction: {
            [weak self] in
            // 非表示にする
            Util.saveHidePosts(postKey: postKey)
            self?.getPostsFromFireBase()
        }) {
            [weak self] in
            Util.presentMailView(vc: self!, subject: "お問い合わせ（不適切な投稿）", message: "不適切な投稿を通報します。\n " + "Key: " + postKey + "\nこのまま（もしくは開発者へのエールを添えて）ご送信ください:)。運営にて投稿内容を確認し、24時間以内に対応いたします。")
        }
    }
    
    /// データベースから投稿情報を取得
    func getPostsFromFireBase() {
        FirebaseLogic.fetchLatestPostsData { [weak self] (snapshot) in
            self?.posts = []
            for snap in snapshot {
                
                if Util.isNotShowPost(postKey: snap.key) {
                    // 非表示設定してるものはpostsの配列に保存しない
                    continue
                }
                
                if let postDict = snap.value as? Dictionary<String, AnyObject> {
                    let key = snap.key
                    let post = Post(postKey: key, postData: postDict)
                    self?.posts.insert(post, at: 0)
                }
            }
            self?.postTableView.posts = (self?.posts)!
            self?.postTableView.reloadData()
        }
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
        
        getPostsFromFireBase()
        sender.endRefreshing()
//        // FIXME: getPost()メソッドの処理と最後以外同じなのでリファクタしたい
//        DataService.ds.REF_POSTS.observeSingleEvent(of: .value , with: { (snapshot) in
//            self.posts = []
//            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                for snap in snapshot {
//
//                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
//
//                        let key = snap.key
//                        let post = Post(postKey: key, postData: postDict)
//                        self.posts.insert(post, at: 0)
//
//                    }
//                }
//                sender.endRefreshing()
//                self.postTableView.posts = self.posts
//                self.postTableView.reloadData()
//            }
//        })
    }
}

extension FeedVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
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

