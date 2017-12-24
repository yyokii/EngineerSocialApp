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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FancyField!
    
    var posts = [Post]()
    var imageSelected = false
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    var userPostsRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //.value means  Any new posts or changes to a post
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
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
            }
            self.tableView.reloadData()
        })

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let  post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            
            //cacheがあればそこから画像とってくる
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
            }
            
            //なければこっちの処理 FIXME: else にしなくてよいの？？
            cell.configureCell(post: post) //一回いらなくねと思い消す→データ読み込まれない→もとに戻す→できた 、解決済
            return cell
            
        } else {
            return PostCell()
        }
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
    @IBAction func postBtnTapped(_ sender: Any) {
        guard let caption = captionField.text, caption != "" else {
            print("JESS: Caption must be entered")
            return
        }
        
        // FIXME: 画像の投稿は使わないのでここいらない
        guard let img = imageAdd.image, imageSelected == true else {
            print("JESS: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let matadata = FIRStorageMetadata()
            matadata.contentType = "image/jpeg"
            
            // 画像がfirebaseストレージに追加できたらpost情報をデータベースに書き込む
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: matadata) { (metadata, error) in
                if error != nil {
                    print("JESS: Unable to upload image to Firebasee torage")
                } else {
                    print("JESS: Successfully uploaded image to Firebase storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
            
        }
    }
    
    
    /// firebaseのデータストアに投稿情報を書き込む（postに追加）
    ///
    /// - Parameter imgUrl: 画像のurl
    func postToFirebase (imgUrl: String) {
        let post: Dictionary<String, AnyObject> = [
            "caption": captionField.text! as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "likes": 0 as AnyObject,
            "uid": KeychainWrapper.standard.string(forKey: KEY_UID) as AnyObject // このuidで検索してユーザーのimageを出したい
            ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        setUserPost(myPostKey: firebasePost.key)
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
    }
    
    
    /// プロフィール画面で自分の過去投稿を見られるように保存しておく
    ///
    /// - Parameter myPostKey: postのkey（autoIdで作成されたもの）
    func setUserPost (myPostKey:String){
        userPostsRef = DataService.ds.REF_USER_CURRENT.child("posts").child(myPostKey)
        userPostsRef.setValue(true)
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
    
    

