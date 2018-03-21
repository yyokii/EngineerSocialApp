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
    
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        twitterLogin()
        initPrivacyPolicyLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
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
        
        logInButton.center = CGPoint(x: view.center.x, y: view.center.y + 50.0)
        self.view.addSubview(logInButton)
    }
    
    // FIXME: ログイン時に獲得アクション数を各要素0にしてdbに登録しておく。アドレスでログインした時もdbが同じになってるようにしておく
    // snsログインで使用するfirebase認証用のメソッド
    func firebaseAuth (_ credential: FIRAuthCredential) {
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                
                print("Error: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                
                print("OK: Successfully authenticated with Firebase")
                if let user = user {
                    print("ユーザーのid：" + user.uid)
                    
                    FirebaseLogic.existUser(uid: user.uid, newUser: {
                        [weak self] in
                        // ユーザー名を保存
                        var name = "anonymous"
                        if let displayName = user.displayName{
                            name = displayName
                        }
                        // 初回ログイン時に、獲得アクション数を0にしてdbに登録する
                        let getActions: Dictionary<String, AnyObject> = [SMILES: 0 as AnyObject, HEARTS: 0 as AnyObject, CRIES: 0 as AnyObject, CLAPS: 0 as AnyObject, OKS: 0 as AnyObject]
                        let userData: Dictionary<String,Any> = ["provider": credential.provider, GET_ACTIONS: getActions, NAME: name]
                        
                        self?.uploadImage(user: user)
                        self?.completeSignIn(id: user.uid, userData: userData)
                    }, loginUser: {
                        [weak self] in
                        let keychainResult = KeychainWrapper.standard.set(user.uid, forKey: KEY_UID)
                        print("OK: Data saved to keychain \(keychainResult)")
                        self?.performSegue(withIdentifier: "goToFeed", sender: nil)
                    })
                }
            }
        })
    }
    
//    // メールログイン
//    @IBAction func signInTapped(_ sender: Any) {
//
//        if let email = emailField.text, let pwd = pwdField.text {
//            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
//                if error == nil {
//                    //exsisting user
//                    print("OK: Email user authenticated with Firebase")
//                    if let user = user {
//                        let userData = ["provider": user.providerID ]
//                        self.completeSignIn(id: user.uid, userData: userData)
//                    }
//                } else {
//                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
//                        if error != nil {
//                            print("Error: Unable to authenticate with Firebase using email")
//                        } else {
//                            //new user
//                            print("OK: Successfully authenticated with Firebase")
//                            if let user = user {
//                                let userData = ["provider": user.providerID ]
//                                self.completeSignIn(id: user.uid, userData: userData)
//                            }
//                        }
//                    })
//                }
//            })
//        }
//    }
    
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
        
        // FIXME: 置き換えれたら置き換える
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
        print("OK: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    func initPrivacyPolicyLabel(){
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(labelTapped(sender:)))
        privacyPolicyLabel.isUserInteractionEnabled = true
        privacyPolicyLabel.addGestureRecognizer(labelTap)
    }
    
    @objc func labelTapped(sender: UITapGestureRecognizer) {
        let url = URL(string: "https://peraichi.com/landing_pages/view/timetohack")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
}

