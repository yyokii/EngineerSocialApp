//
//  FirebaseLogic.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/04.
//

import UIKit
import Firebase

class FirebaseLogic {
    
    static func setUserName (uid: String, nameLabel: UILabel){
        let postUserNameRef = DataService.ds.REF_USERS.child(uid).child(NAME)
        postUserNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let name = snapshot.value {
                nameLabel.text = name as? String
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    static func setUserImage (uid: String, userImageView: UIImageView){
        let userImageRef = DataService.ds.REF_USER_IMAGES.child(uid)
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
    
    /// 獲得アクション数取得
    ///
    /// - Parameter completion: 値取得後の処理（引数：辞書型）
    static func getGetActionsData(uid: String, completion: ((Dictionary<String, Int>) -> Void)?) {
        DataService.ds.REF_USERS.child(uid).child(GET_ACTIONS).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Int> {
                print(dict)
                completion?(dict)
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    static func tes() {
        
    }
    
    /// フォロー済みかどうかを判断する
    ///
    /// - Parameter uid: 表示しているユーザー（自分以外）のuid
    static func fetchFollowState (uid: String, completion: ((Bool) -> Void)?){
        let currentUser = DataService.ds.REF_USER_CURRENT.key
        DataService.ds.REF_FOLLOW_FOLLOWER.child(currentUser).child(FOLLOW).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let isFollowState = snapshot.value as? Bool{
                completion?(isFollowState)
            }else {
                completion?(false)
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    /// フォローアクション情報をdbに反映させるメソッド
    /// ログインユーザーのフォローアカウント追加、フォローされたアカウントをフォロワーアカウント追加
    /// - Parameter uid: フォローされた側のuid
    /// - completion: 通信成功後の処理
    static func followAction (uid: String, completion: @escaping (() -> Void)){
        // フォローした側（ログインユーザー）
        let currentUser = DataService.ds.REF_USER_CURRENT.key
        let childUpdates = ["/\(currentUser)/\(FOLLOW)/\(uid)": true,
                            "/\(uid)/\(FOLLOWER)/\(currentUser)": true]
        DataService.ds.REF_FOLLOW_FOLLOWER.updateChildValues(childUpdates) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                completion()
            }
        }
    }
    
    /// アンフォローアクション情報をdbに反映させるメソッド
    /// ログインユーザーのフォローアカウント削除、フォローされたアカウントをフォロワーアカウント削除
    /// - Parameter uid: アンフォローされた側のuid
    /// - completion: 通信成功後の処理
    static func unfollowAction (uid: String, completion: @escaping (() -> Void)){
        let currentUser = DataService.ds.REF_USER_CURRENT.key
        let childUpdates = ["/\(currentUser)/\(FOLLOW)/\(uid)": NSNull(),
                            "/\(uid)/\(FOLLOWER)/\(currentUser)": NSNull()]
        DataService.ds.REF_FOLLOW_FOLLOWER.updateChildValues(childUpdates) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                completion()
            }
        }
    }
}
