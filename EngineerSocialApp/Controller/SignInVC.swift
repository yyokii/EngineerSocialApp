//
//  SignIn.swift
//  UdemySocialApp
//
//  Created by 東原与生 on 2017/03/15.
//  Copyright © 2017年 yoki. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
        
        // FIXME: 場所変えるか、facebookみたいにするか
        self.twitterLogin()
    }
    
    // facebookログイン
    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                
                print("JESS: Unable to authenticate with Facebook - \(String(describing: error))")
            } else if result?.isCancelled == true {
                
                print("JESS: User cancelled Facebook authentication")
            } else {
                
                print("JESS: Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
    }
    
    // twitterログイン
    func twitterLogin() {
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                let authToken = session?.authToken
                let authTokenSecret = session?.authTokenSecret
                let credential = FIRTwitterAuthProvider.credential(withToken: authToken!, secret: authTokenSecret!)
                self.firebaseAuth(credential)
            } else {
                // ...
            }
        })
        
        logInButton.center = view.center
        self.view.addSubview(logInButton)
    }
    
    // FIXME: ログイン時に獲得アクション数を各要素0にしてdbに登録しておく。アドレスでログインした時もdbが同じになっているかの確認必要かも
    // snsログインで使用するfirebase認証用のメソッド
    func firebaseAuth (_ credential: FIRAuthCredential) {
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                
                print("Error: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                
                print("OK: Successfully authenticated with Firebase")
                if let user = user {
                    
                    let getActions: Dictionary<String, AnyObject> = ["smiles": 0 as AnyObject, "hearts": 0 as AnyObject, "cries": 0 as AnyObject, "claps": 0 as AnyObject, "oks": 0 as AnyObject]
                    let userData: Dictionary<String,Any> = ["provider": credential.provider, "getActions": getActions]
                    
                    self.uploadImage(user: user)
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }
    
    // メールログイン
    @IBAction func signInTapped(_ sender: Any) {
        
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    //exsisting user
                    print("OK: Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID ]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("Error: Unable to authenticate with Firebase using email")
                        } else {
                            //new user
                            print("OK: Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID ]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func uploadImage(user: FIRUser) {
        var imageData: Data?
        do {
            imageData = try Data(contentsOf: user.photoURL!, options: Data.ReadingOptions.mappedIfSafe)
        }catch {
            imageData = nil
            print("Errro: アイコン画像のData型生成に失敗")
        }
        
        guard let _ = imageData else {
            return
        }
        // ログイン時にユーザーのアイコンイメージをストレージに保存する
        if let imgData = UIImageJPEGRepresentation(UIImage(data: imageData!)!, 0.5) {
            let imgUid = user.uid
            let matadata = FIRStorageMetadata()
            matadata.contentType = "image/jpeg"
            
            // 画像をfirebaseストレージに追加する
            DataService.ds.REF_USER_IMAGES.child(imgUid).put(imgData, metadata: matadata) { (metadata, error) in
                if error != nil {
                    print("Error: Firebasee storageへの画像アップロード失敗")
                } else {
                    print("OK:　Firebase storageへの画像アップロード成功")
                }
            }
        }
    }
    
    func completeSignIn (id: String, userData: Dictionary<String,Any>){
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("JESS: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}

