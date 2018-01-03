//
//  PostCell.swift
//  UdemySocialApp
//
//  Created by 東原与生 on 2017/03/18.
//  Copyright © 2017年 yoki. All rights reserved.
//

import UIKit
import Firebase
// このクラスを消して　→　PostTableViewCellに置き換える
class PostCell: UITableViewCell {

    @IBOutlet weak var profieImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImag: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
        
    }
    
    func configureCell (post: Post, img: UIImage? = nil) {
        self.post = post
        // ユーザーが投稿にいいねしているかどうかでハートの状態を変更するので、likeの参照を保持
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)

        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        //self.profieImg.image = UIImage(data: )
        setUserImage(uid: post.postUserId)
        
        //Cacheにある場合とない場合（storageからとってきてCaCheに入れる）
        //TODO:Cache適宜消さないと容量まずいきがする
        if img != nil {
            self.postImag.image = img
        } else {
            guard post.imageUrl != "" else {
                return
            }
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("JESS: Unable to download image from Firebase storage")
                } else {
                    print("JESS: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImag.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                            
                        }
                    }
                }
            })
        }
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
    }
    
    @objc func likeTapped (sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.ajustLike(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.ajustLike(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    
    /// 投稿者のアイコン取得 FIXME:画像荒い
    ///
    /// - Parameter uid: 投稿者のid
    func setUserImage(uid: String) {
        let ref = FIRStorage.storage().reference().child("user-icon-pics").child(uid)
        
        ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("Error: Firebase storageからアイコン画像の取得失敗")
            } else {
                print("OK: Firebase storageからアイコン取得成功")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.profieImg.image = img
                        //FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                    }
                }
            }
        })
    }
}
