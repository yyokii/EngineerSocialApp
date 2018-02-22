//
//  PostVC.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2017/12/24.
//

import UIKit
import SwiftKeychainWrapper

class PostVC: UIViewController, UIPopoverPresentationControllerDelegate, PopOverContentDelegate {
    
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var doingLabel: UILabel!
    @IBOutlet weak var captionTextView: UITextView!
    
    let programLang = ["swift","kotlin","ruby","python","go", "その他"]
    let doing = ["iOSアプリ開発","Androidアプリ開発","サーバー開発","インフラ構築","その他"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // FIXME: 入力内容が不十分の場合は投稿ボタンにalphaをかけておく
    @IBAction func postTapped(_ sender: Any) {
        
//        guard let language = languageLabel.text, language != "" else {
//            print("Error: 言語が設定されてませんよっ")
//            return
//        }
//
//        guard let doing = doingLabel.text, doing != "" else {
//            print("Error: やることが設定されてませんよっ")
//            return
//        }
//
//        guard let caption = captionTextView.text, caption != "" else {
//            print("Error: キャプションなし！？")
//            return
//        }
        
        // 遷移させない方が自然かも
        //self.tabBarController?.selectedIndex = 0
        PopupView.sharedManager.show()
        // FIXME: デバッグ用にコメントアウト
        //postToFirebase()
    }
    
    // FIXME: ここでdbに書き込む際にユーザーのツリーの中にlanguageとdoing要素のカウントを増やす。
    // 投稿内容の確認　→ ref → データがあるかないかで分岐　→ 書き込み　（サインインで各要素0で設定しておくと使用しないツリーが出てくるので、1以上のみを保存する。データがない時のui必要）
    
    /// firebaseのデータストアに投稿情報を書き込む（postに追加）
    ///
    /// - Parameter imgUrl: 画像のurl
    func postToFirebase () {
        let action: Dictionary<String, AnyObject> = [SMILES: 0 as AnyObject, HEARTS: 0 as AnyObject, CRIES: 0 as AnyObject, CLAPS: 0 as AnyObject, OKS: 0 as AnyObject]
        let post: Dictionary<String, AnyObject> = [
            DATE: getTodayDateString() as AnyObject,
            PROGRAMMING_LANGUAGE: languageLabel.text! as AnyObject,
            DEVELOP: doingLabel.text! as AnyObject,
            CAPTION: captionTextView.text! as AnyObject,
            KEY_UID: KeychainWrapper.standard.string(forKey: KEY_UID) as AnyObject,
            ACTION: action as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        print("投稿完了！")
        
        setUserDevelopData(devLanguage: languageLabel.text!, develop: doingLabel.text!)
        setUserPost(myPostKey: firebasePost.key)
        captionTextView.text = ""
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let now = Date()
        return formatter.string(from: now)
    }
    
    /// 投稿時にユーザーの使用言語とやることをユーザー情報としてdbに保存する（チャートで表示するため）
    ///
    /// - Parameters:
    ///   - devLanguage: 使用言語
    ///   - develop: やること
    func setUserDevelopData(devLanguage: String, develop: String) {
        let userDevLanguageDataRef = DataService.ds.REF_USER_CURRENT.child(PROGRAMMING_LANGUAGE).child(devLanguage)
        let userDevelopThingsDataRef = DataService.ds.REF_USER_CURRENT.child(DEVELOP).child(develop)
        
        userDevLanguageDataRef.observeSingleEvent(of: .value) { (snapshot) in
            if let counts = snapshot.value as? Int {
                userDevLanguageDataRef.setValue(counts + 1)
            } else {
                userDevLanguageDataRef.setValue(1)
            }
        }
        
        userDevelopThingsDataRef.observeSingleEvent(of: .value) { (snapshot) in
            if let counts = snapshot.value as? Int {
                userDevelopThingsDataRef.setValue(counts + 1)
            } else {
                userDevelopThingsDataRef.setValue(1)
            }
        }
    }
    
    /// プロフィール画面で自分の過去投稿を見られるようにユーザーのpostkeyをdbに保存しておく
    /// TODO：削除機能つける時はpostkey消す（投稿情報関連は全て消す必要あり、ん〜面倒　→　removeを監視できるのでそれでやる感じですね）
    /// - Parameter myPostKey: postのkey（autoIdで作成されたもの）
    func setUserPost (myPostKey:String){
        let userPostsRef = DataService.ds.REF_USER_CURRENT.child(POSTS).child(myPostKey)
        userPostsRef.setValue(true)
    }
    
    /// ラベルタップ時にポップオーバーを表示するよう設定する
    func setLabel() {
        let tapLanguageLabel = UITapGestureRecognizer(target: self, action: #selector(showPopOver(sender:)))
        let tapDoingLabel = UITapGestureRecognizer(target: self, action: #selector(showPopOver(sender:)))
        languageLabel.addGestureRecognizer(tapLanguageLabel)
        doingLabel.addGestureRecognizer(tapDoingLabel)
        
        languageLabel.isUserInteractionEnabled = true
        doingLabel.isUserInteractionEnabled = true
    }
    
    @objc func showPopOver(sender: UITapGestureRecognizer) {
        let storyBoard = UIStoryboard(name: "PopOver", bundle: nil)
        let contentVC = storyBoard.instantiateInitialViewController() as! PopOverContentViewController
        contentVC.modalPresentationStyle = .popover
        contentVC.preferredContentSize = CGSize(width: self.view.frame.width, height: 300)
        //sourceViewは表示するviewを指定して、sourceRectはそのviewの中のどこからにゅにゅっと表示するかを指定する
        contentVC.popoverPresentationController?.sourceView = view
        contentVC.popoverPresentationController?.permittedArrowDirections = .up
        contentVC.popoverPresentationController?.delegate = self
        contentVC.customDelegate = self
        if let tappedLabel = sender.view as? UILabel {
            contentVC.popoverPresentationController?.sourceRect = tappedLabel.frame
            
            if tappedLabel == languageLabel {
                contentVC.contentArry = programLang
                contentVC.contentType = PopOverContentViewController.PopOverContentType.programLanguage
            } else if tappedLabel == doingLabel {
                contentVC.contentArry = doing
                contentVC.contentType = PopOverContentViewController.PopOverContentType.doing
            }
        }
        
        present(contentVC, animated: true, completion: nil)
    }
    
    /// ポップオーバーをiPhoneで表示させる FIXME:　ipadでも表示させるために修正必要かも
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func didSelectedItem(text: String, contentType: PopOverContentViewController.PopOverContentType) {
        if contentType == PopOverContentViewController.PopOverContentType.programLanguage{
            languageLabel.text = text
        } else if contentType == PopOverContentViewController.PopOverContentType.doing {
            doingLabel.text = text
        }
    }
}
