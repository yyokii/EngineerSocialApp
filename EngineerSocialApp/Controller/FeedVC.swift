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

class FeedVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FancyField!
    @IBOutlet weak var mainView: UIView!
    
    var posts = [Post]()
    var imageSelected = false
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var postTableView: PostTableView!
    
    // FIXME: メンバ変数にしなくていいかも
    var userPostsRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // FIXME:基本先にテーブルビュー生成されるからいいけど、もしデータ取得がはやかったら落ちると思われるので修正したい
        getPostsFromFireBase()
        setPostTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getPostsFromFireBase()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("JESS: A valid image wasn't salected")
        }
        
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    @IBAction func addImageTapped(_ sender: Any) {
        
        present(imagePicker, animated: true, completion: nil)
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
        postTableView.posts = self.posts
        // セルの高さを可変にする
        postTableView.estimatedRowHeight = 200
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
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }

    @IBAction func postTapped(_ sender: Any) {
        performSegue(withIdentifier: "toPost", sender: nil)
    }
}
    
    

