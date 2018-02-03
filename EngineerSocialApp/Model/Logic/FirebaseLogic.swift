//
//  FirebaseLogic.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/04.
//

import UIKit
import Firebase

class FirebaseLogic {
    
    
    /// ユーザーの名前とプロフィール画像を取得
    ///
    /// - Parameters:
    ///   - nameLabel: 表示対象のラベル
    ///   - userImageView: 表示対象のimageView
    static func setUserInfo (nameLabel: UILabel, userImageView: UIImageView){
        
        let loginUser = DataService.ds.REF_USER_CURRENT
        
        loginUser.child(NAME).observeSingleEvent(of: .value, with: { (snapshot) in
            if let name = snapshot.value {
                nameLabel.text = name as? String
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        let userImageRef = DataService.ds.REF_USER_IMAGES.child(loginUser.key)
        userImageRef.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("Error: Firebase storageからアイコン画像の取得失敗")
            } else {
                print("OK: Firebase storageからアイコン取得成功")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        userImageView.image = img
                        // FIXME: キャッシュどうしましょ
                        //FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                    }
                }
            }
        })
    }
    
}
