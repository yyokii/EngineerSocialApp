//
//  FirebaseLogic.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/04.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FirebaseLogic {
    
    static func fetchUserName (uid: String, completion: @escaping ((String) -> Void)){
        let postUserNameRef = DataService.ds.REF_USERS.child(uid).child(NAME)
        postUserNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let name = snapshot.value as? String {
                completion(name)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    static func fetchUserProfile (uid: String, completion: @escaping ((String) -> Void)){
        let postUserNameRef = DataService.ds.REF_USERS.child(uid).child(PROFILE)
        postUserNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let profile = snapshot.value as? String {
                completion(profile)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    static func fetchTwitterAccount (uid: String, completion: @escaping ((String) -> Void)){
        let postUserNameRef = DataService.ds.REF_USERS.child(uid).child(TWITTER)
        postUserNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let twitter = snapshot.value as? String {
                completion(twitter)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    static func fetcGitAccount (uid: String, completion: @escaping ((String) -> Void)){
        let postUserNameRef = DataService.ds.REF_USERS.child(uid).child(GIT)
        postUserNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let git = snapshot.value as? String {
                completion(git)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    static func fetchUserImage (uid: String, completion: @escaping ((UIImage) -> Void)){
        let userImageRef = DataService.ds.REF_USER_IMAGES.child(uid)
        userImageRef.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("Error: Firebase storageからアイコン画像の取得失敗")
            } else {
                print("OK: Firebase storageからアイコン取得成功")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        completion(img)
                        // FIXME: キャッシュどうしましょ
                        //FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                    }
                }
            }
        })
    }
    
    /// 画像をストレージにアップロードする
    ///
    /// - Parameters:
    ///   - image: 保存する画像
    static func uploadImage(image: UIImage, completion: (() -> Void)?){
        if let imgData = UIImageJPEGRepresentation(image, 0.5) {
            let imgUid = KeychainWrapper.standard.string(forKey: KEY_UID)!
            let matadata = FIRStorageMetadata()
            matadata.contentType = "image/jpeg"
            
            // 画像をfirebaseストレージに追加
            DataService.ds.REF_USER_IMAGES.child(imgUid).put(imgData, metadata: matadata) { (metadata, error) in
                if error != nil {
                    print("Error: Firebasee storageへの画像アップロード失敗")
                } else {
                    print("OK:　Firebase storageへの画像アップロード成功")
                    completion?()
                }
            }
        }
    }
    
    /// 獲得アクション数取得
    ///
    /// - Parameter completion: 値取得後の処理（引数：辞書型）
    static func getGetActionsData(uid: String, completion: ((Dictionary<String, Int>) -> Void)?) {
        DataService.ds.REF_USERS.child(uid).child(GET_ACTIONS).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Int> {
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
        let currentUser = KeychainWrapper.standard.string(forKey: KEY_UID)!
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
        let currentUser = KeychainWrapper.standard.string(forKey: KEY_UID)!
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
        let currentUser = KeychainWrapper.standard.string(forKey: KEY_UID)!
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
    
    /// フォローしているユーザー情報を取得
    ///
    /// - Parameter completion: 通信成功後の処理
    static func fetchFollowUser (uid: String, completion: @escaping (([String]) -> Void)){
        DataService.ds.REF_FOLLOW_FOLLOWER.child(uid).child(FOLLOW).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Bool> {
                var followUidArray = [String]()
                for uid in dict.keys {
                    followUidArray.append(uid)
                }
                completion(followUidArray)
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    /// フォローされているユーザー情報を取得
    ///
    /// - Parameter completion: 通信成功後の処理
    static func fetchFollowerUser (uid: String, completion: @escaping (([String]) -> Void)){
        DataService.ds.REF_FOLLOW_FOLLOWER.child(uid).child(FOLLOWER).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Bool> {
                var followerUidArray = [String]()
                for uid in dict.keys {
                    followerUidArray.append(uid)
                }
                completion(followerUidArray)
            }
        }){ (error) in
            print("--------------------------")
            print(error.localizedDescription)
        }
    }
    
    /// （settingからプロフィール情報を変更する）ログインユーザーの情報を書き換える
    ///
    /// - Parameters:
    ///   - name: なまえ
    ///   - profile: じこしょうかい
    ///   - twitter: ついったー
    ///   - git: ぎっと
    ///   - completion: おわったよー、のとき
    static func updateUserInfo (name: String, profile: String, twitter: String, git: String, completion: @escaping (() -> Void)){
        let currentUser = KeychainWrapper.standard.string(forKey: KEY_UID)!
        let childUpdates = ["/\(currentUser)/\(NAME)": name,
                            "/\(currentUser)/\(PROFILE)": profile,
                            "/\(currentUser)/\(TWITTER)": twitter,
                            "/\(currentUser)/\(GIT)": git]
        DataService.ds.REF_USERS.updateChildValues(childUpdates) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                completion()
            }
        }
    }
}
