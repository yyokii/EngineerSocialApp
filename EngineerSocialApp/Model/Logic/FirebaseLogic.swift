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
            }else {
                completion("")
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
            }else {
                completion("")
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
    
    /// 引数で受け取ったidをキーとするユーザーが存在するかどうかで処理を分けるメソッド
    ///
    /// - Parameters:
    ///   - uid: 検索するユーザーid
    ///   - newUser: 新規ユーザー登録処理を行う
    ///   - loginUser: 画面遷移を行う
    static func existUser (uid: String, newUser: @escaping (() -> Void), loginUser: @escaping (() -> Void)){
        let ref = DataService.ds.REF_USERS.child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                newUser()
            }else {
                loginUser()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    /// 画像をストレージにアップロードする
    ///
    /// - Parameters:
    ///   - image: 保存する画像
    static func uploadImage(image: UIImage, completion: @escaping (() -> Void)){
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
                    completion()
                }
            }
        }
    }
    
    
    /// Postする際のFirebase処理（以下４つの処理が必要。FIXME: completionの受け渡し多すぎ→他のコールバックの方がいいかも。compはadjustDevelopDataで実行されます）
    ///
    /// - Parameters:
    ///   - language: 開発言語
    ///   - develop: 開発項目
    ///   - caption: 投稿内容
    ///   - completion: adjustDevelopDataが終了後に呼ばれる処理
    static func postToFirebase(vc: UIViewController, language: String, develop: String, caption: String, completion: @escaping (() -> Void)) {
        
        let action: Dictionary<String, AnyObject> = [SMILES: 0 as AnyObject, HEARTS: 0 as AnyObject, CRIES: 0 as AnyObject, CLAPS: 0 as AnyObject, OKS: 0 as AnyObject]
        let post: Dictionary<String, AnyObject> = [
            DATE: Util.getTodayDateString() as AnyObject,
            PROGRAMMING_LANGUAGE: language as AnyObject,
            DEVELOP: develop as AnyObject,
            CAPTION: caption as AnyObject,
            KEY_UID: KeychainWrapper.standard.string(forKey: KEY_UID) as AnyObject,
            ACTION: action as AnyObject
        ]
        
        let firebasePostRef = DataService.ds.REF_POSTS.childByAutoId()
        firebasePostRef.setValue(post) { (error, ref) in
            if error == nil {
                applayUserPost(language: language, develop: develop, postKey: firebasePostRef.key, completion: completion)
            }else {
                Alert.presentOneBtnAlert(vc: vc, title: "Error😇", message: "Sorry... Please Check Internet Connection.", positiveTitle: "OK", positiveAction: {})
            }
        }
    }
    
    static func applayUserPost(language: String, develop: String, postKey: String, completion: @escaping (() -> Void)) {
        let userPostsRef = DataService.ds.REF_USER_CURRENT.child(POSTS).child(postKey)
        userPostsRef.setValue(true) { (error, ref) in
            if error == nil {
                adjustLanguageData(language: language, develop: develop, completion: completion)
            }
        }
    }
    
    static func adjustLanguageData(language: String, develop: String, completion: @escaping (() -> Void)) {
        let userDevLanguageDataRef = DataService.ds.REF_USER_CURRENT.child(PROGRAMMING_LANGUAGE).child(language)
        
        userDevLanguageDataRef.observeSingleEvent(of: .value) { (snapshot) in
            if let counts = snapshot.value as? Int {
                userDevLanguageDataRef.setValue(counts + 1, withCompletionBlock: { (error, ref) in
                    adjustDevelopData(develop: develop, completion: completion)
                })
            } else {
                userDevLanguageDataRef.setValue(1, withCompletionBlock: { (error, ref) in
                    adjustDevelopData(develop: develop, completion: completion)
                })
            }
        }
    }
    
    static func adjustDevelopData(develop: String, completion: @escaping (() -> Void)) {
        let userDevelopThingsDataRef = DataService.ds.REF_USER_CURRENT.child(DEVELOP).child(develop)
        
        userDevelopThingsDataRef.observeSingleEvent(of: .value) { (snapshot) in
            if let counts = snapshot.value as? Int {
                userDevelopThingsDataRef.setValue(counts + 1, withCompletionBlock: { (error, ref) in
                    completion()
                })
            } else {
                userDevelopThingsDataRef.setValue(1, withCompletionBlock: { (error, ref) in
                    completion()
                })
            }
        }
    }
    
    /// 最新50件の投稿情報を取得する（古い順に返ってくる）
    ///
    /// - Parameters:
    ///   - completion: データが取得できた後の処理
    static func fetchLatestPostsData(completion: @escaping (([FIRDataSnapshot]) -> Void)) {
        DataService.ds.REF_POSTS.queryLimited(toLast: 50).observeSingleEvent(of: .value , with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                completion(snapshot)
            }
        })
    }
    
    /// 過去の「自分の」投稿を取得
    static func fetchMyPostsData(uid: String, completion: @escaping (([Post]) -> Void)) {
        DataService.ds.REF_USERS.child(uid).child(POSTS).observeSingleEvent(of: .value) { (snapshot) in
            var myPostsKey = [String]()
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    let postKey = snap.key
                    myPostsKey.insert(postKey, at: 0)
                }
                // 投稿全てのkeyが取得できたらそのkeyに該当するpostを取得する
                if !myPostsKey.isEmpty {
                    var myPosts = [Post]()
                    for key in myPostsKey {
                        DataService.ds.REF_POSTS.child(key).observeSingleEvent(of: .value) { (snapshot) in
                            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                                let key = snapshot.key
                                let post = Post(postKey: key, postData: postDict)
                                myPosts.append(post)
                            }
                            completion(myPosts)
                        }
                    }
                } else {
                    print("エラー: 過去の投稿がないよー")
                }
            }
        }
    }
    
    /// 獲得アクション数取得
    ///
    /// - Parameter completion: 値取得後の処理（引数：辞書型）
    static func getGetActionsData(uid: String, completion: @escaping ((Dictionary<String, Int>) -> Void)) {
        DataService.ds.REF_USERS.child(uid).child(GET_ACTIONS).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Int> {
                completion(dict)
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    /// 開発言語の累計データを取得する
    ///
    /// - Parameters:
    ///   - uid: 誰の
    ///   - completion: グラフ再描画とか
    static func fetchDevLangData(uid: String, completion: @escaping (([FIRDataSnapshot]?) -> Void)) {
        // 開発言語のデータ取得
        DataService.ds.REF_USERS.child(uid).child(PROGRAMMING_LANGUAGE).queryOrderedByValue().observeSingleEvent(of: .value) { (snapshot) in
            if let devLanguages = snapshot.children.allObjects as? [FIRDataSnapshot]{
                completion(devLanguages)
            }else {
                completion(nil)
            }
        }
    }
    
    /// 開発項目の累計データを取得する
    ///
    /// - Parameters:
    ///   - uid: 誰の
    ///   - completion: グラフ再描画とか
    static func fetchDevelopData(uid: String, completion: @escaping (([FIRDataSnapshot]?) -> Void)) {
        // 開発項目のデータ取得
        DataService.ds.REF_USERS.child(uid).child(DEVELOP).queryOrderedByValue().observeSingleEvent(of: .value) { (snapshot) in
            if let develops = snapshot.children.allObjects as? [FIRDataSnapshot]{
                completion(develops)
            }else {
                completion(nil)
            }
        }
    }
    
    /// フォロー済みかどうかを判断する
    ///
    /// - Parameter uid: 表示しているユーザー（自分以外）のuid
    static func fetchFollowState (uid: String, completion: @escaping ((Bool) -> Void)){
        let currentUser = KeychainWrapper.standard.string(forKey: KEY_UID)!
        DataService.ds.REF_FOLLOW_FOLLOWER.child(currentUser).child(FOLLOW).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let isFollowState = snapshot.value as? Bool{
                completion(isFollowState)
            }else {
                completion(false)
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    /// フォローアクション情報をdbに反映させるメソッド
    /// ログインユーザーのフォローアカウント追加、フォローされたアカウントをフォロワーアカウント追加
    /// - Parameter uid: フォローされた側のuid
    /// - completion: 通信成功後の処理
    static func followAction (vc: UIViewController, uid: String, completion: @escaping (() -> Void)){
        // フォローした側（ログインユーザー）
        let currentUser = KeychainWrapper.standard.string(forKey: KEY_UID)!
        let childUpdates = ["/\(currentUser)/\(FOLLOW)/\(uid)": true,
                            "/\(uid)/\(FOLLOWER)/\(currentUser)": true]
        DataService.ds.REF_FOLLOW_FOLLOWER.updateChildValues(childUpdates) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
                Alert.presentOneBtnAlert(vc: vc, title: "Error😇", message: "Sorry... Please Check Internet Connection.", positiveTitle: "OK", positiveAction: {})
            }else {
                completion()
            }
        }
    }
    
    /// アンフォローアクション情報をdbに反映させるメソッド
    /// ログインユーザーのフォローアカウント削除、フォローされたアカウントをフォロワーアカウント削除
    /// - Parameter uid: アンフォローされた側のuid
    /// - completion: 通信成功後の処理
    static func unfollowAction (vc: UIViewController, uid: String, completion: @escaping (() -> Void)){
        let currentUser = KeychainWrapper.standard.string(forKey: KEY_UID)!
        let childUpdates = ["/\(currentUser)/\(FOLLOW)/\(uid)": NSNull(),
                            "/\(uid)/\(FOLLOWER)/\(currentUser)": NSNull()]
        DataService.ds.REF_FOLLOW_FOLLOWER.updateChildValues(childUpdates) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
                Alert.presentOneBtnAlert(vc: vc, title: "Error😇", message: "Sorry... Please Check Internet Connection.", positiveTitle: "OK", positiveAction: {})
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
            var followUidArray = [String]()
            if let dict = snapshot.value as? Dictionary<String, Bool> {
                for uid in dict.keys {
                    followUidArray.append(uid)
                }
                completion(followUidArray)
            }else {
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
    static func updateUserInfo (vc: UIViewController, name: String, profile: String, twitter: String, git: String, completion: @escaping (() -> Void)){
        let currentUser = KeychainWrapper.standard.string(forKey: KEY_UID)!
        let childUpdates = ["/\(currentUser)/\(NAME)": name,
                            "/\(currentUser)/\(PROFILE)": profile,
                            "/\(currentUser)/\(TWITTER)": twitter,
                            "/\(currentUser)/\(GIT)": git]
        DataService.ds.REF_USERS.updateChildValues(childUpdates) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
                Alert.presentOneBtnAlert(vc: vc, title: "Error😇", message: "Sorry... Please Check Internet Connection.", positiveTitle: "OK", positiveAction: {})
            }else {
                completion()
            }
        }
    }
    
    
    /// ブロックするユーザーのuidをセットする
    ///
    /// - Parameters:
    ///   - uid: ブロック対象
    ///   - completion: firebase処理おわったら
    static func setBlockUserFirebase(vc: UIViewController, uid: String, completion: @escaping (() -> Void)) {
        
        let blockUsersRef = DataService.ds.REF_USER_CURRENT.child(BLOCK_USERS)
        blockUsersRef.child(uid).setValue(true) { (error, ref) in
            if error == nil {
                completion()
            }else {
                Alert.presentOneBtnAlert(vc: vc, title: "Error😇", message: "Sorry... Please Check Internet Connection.", positiveTitle: "OK", positiveAction: {})
            }
        }
    }
    
    /// ブロックしているユーザーのuidを取得する
    ///
    /// - Parameters:
    ///   - uid: ブロック対象
    ///   - completion: firebase処理おわったら
    static func fetchBlockUserFirebase(vc: UIViewController, completion: @escaping (([String]) -> Void)) {
        
        let blockUsersRef = DataService.ds.REF_USER_CURRENT.child(BLOCK_USERS)
        blockUsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var blockUidArray = [String]()
            if let dict = snapshot.value as? Dictionary<String, Bool> {
                for uid in dict.keys {
                    blockUidArray.append(uid)
                }
                completion(blockUidArray)
            }else {
                completion(blockUidArray)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
