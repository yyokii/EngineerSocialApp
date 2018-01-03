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
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
        postToFirebase()
    }
    
    /// firebaseのデータストアに投稿情報を書き込む（postに追加）
    ///
    /// - Parameter imgUrl: 画像のurl
    func postToFirebase () {
        let action: Dictionary<String, AnyObject> = ["smile": 0 as AnyObject, "heart": 0 as AnyObject, "cry": 0 as AnyObject, "clap": 0 as AnyObject, "ok": 0 as AnyObject]
        let post: Dictionary<String, AnyObject> = [
            "programmingLanguage": languageLabel.text! as AnyObject,
            "do": doingLabel.text! as AnyObject,
            "caption": captionTextView.text! as AnyObject,
            "likes": 0 as AnyObject, // FIXME 消去
            "uid": KeychainWrapper.standard.string(forKey: KEY_UID) as AnyObject,
            "action": action as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        print("投稿完了！")
        
        setUserPost(myPostKey: firebasePost.key)
        captionTextView.text = ""
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /// プロフィール画面で自分の過去投稿を見られるようにユーザーのpostkeyをdbに保存しておく
    /// TODO：削除機能つける時はpostkey消す（投稿情報関連は全て消す必要あり、ん〜面倒　→　removeを監視できるのでそれでやる感じですね）
    /// - Parameter myPostKey: postのkey（autoIdで作成されたもの）
    func setUserPost (myPostKey:String){
        let userPostsRef = DataService.ds.REF_USER_CURRENT.child("posts").child(myPostKey)
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
