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
    @IBOutlet weak var postBtn: FancyBtn!
    
    let programLang = ["Assembly","C","C#","C++","Go","HTML","Java","JavaScript","Kotlin","Objective-C","Perl","PHP","Python","R","Ruby","Scala","Shell","SQL","Swift","Visual Basic","その他"]
    let doing = ["iOSアプリ","Androidアプリ","インフラ構築","組み込み系","業務効率化","ゲーム","サーバー","WEBアプリ","記事作成","資料作成","バグ修正","その他"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        captionTextView.delegate = self
        setLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        removeObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // FIXME: 入力内容が不十分の場合は投稿ボタンにalphaをかけておく
    @IBAction func postTapped(_ sender: Any) {
        
        guard let language = languageLabel.text, language != "" else {
            print("Error: 言語が設定されてませんよっ")
            return
        }

        guard let doing = doingLabel.text, doing != "" else {
            print("Error: やることが設定されてませんよっ")
            return
        }

        guard let caption = captionTextView.text, caption != "" else {
            print("Error: キャプションなし！？")
            return
        }
        
        Alert.presentTwoBtnAlert(vc: self, title: "func confirm()", message: "投稿しても良いですか:)？", positiveTitle: "OK🙆‍♂️", negativeTitle: "CANCEL🙅") { [weak self] in
            FirebaseLogic.postToFirebase(vc: self!, language: (self?.languageLabel.text)!, develop: (self?.doingLabel.text!)!, caption: (self?.captionTextView.text)!, completion: {
                self?.languageLabel.text = ""
                self?.doingLabel.text = ""
                self?.captionTextView.text = ""
                
                PopupView.sharedManager.show()
                self?.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    // 投稿情報を送信　→ ユーザー情報を書き換え → ユーザーの投稿情報に一件のKeyを追加
    
    /// firebaseのデータストアに投稿情報を書き込む（postに追加）
    ///
    func postToFirebase () {
        let action: Dictionary<String, AnyObject> = [SMILES: 0 as AnyObject, HEARTS: 0 as AnyObject, CRIES: 0 as AnyObject, CLAPS: 0 as AnyObject, OKS: 0 as AnyObject]
        let post: Dictionary<String, AnyObject> = [
            DATE: Util.getTodayDateString() as AnyObject,
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
    
    // キーボード以外のところタップしたらキーボード隠す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if captionTextView.isFirstResponder{
            captionTextView.resignFirstResponder()
        }
    }
    
    // FIXME: FeedVCでも同じ処理書いてるのでリファクタしたい
    // キーボードのNotificationを設定
    func configureObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // キーボードのNotificationを削除
    func removeObserver() {
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    // キーボードが現れた時に、画面全体をずらす。
    @objc func keyboardWillShow(notification: Notification?) {
        let rect = (notification?.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!/2)
            self.view.transform = transform
            
        })
    }
    
    // キーボードが消えたときに、画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            self.view.transform = CGAffineTransform.identity
        })
    }
}

extension PostVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
