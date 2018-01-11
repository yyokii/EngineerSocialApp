//
//  PostTableViewCell.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2017/12/31.
//

import UIKit
import Firebase

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImg: CircleView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var caption: UITextView!
    
    // ユーザーのアクション
    @IBOutlet weak var smileLabel: BorderLabel!
    @IBOutlet weak var heartLabel: BorderLabel!
    @IBOutlet weak var cryLabel: BorderLabel!
    @IBOutlet weak var clapLabel: BorderLabel!
    @IBOutlet weak var okLabel: BorderLabel!
    
    // ユーザーのアクション数を表示するためのラベル
    @IBOutlet weak var smileCountLabel: UILabel!
    @IBOutlet weak var heartCountLabel: UILabel!
    @IBOutlet weak var cryCountLabel: UILabel!
    @IBOutlet weak var clapCountLabel: UILabel!
    @IBOutlet weak var okCountLabel: UILabel!

    // FIXME: 多分いらない
//    @IBOutlet weak var postImag: UIImageView!
//    @IBOutlet weak var likesLbl: UILabel!
//    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post!
    
    // アクションの参照先
    var smileRef: FIRDatabaseReference!
    var heartRef: FIRDatabaseReference!
    var cryRef: FIRDatabaseReference!
    var clapRef: FIRDatabaseReference!
    var okRef: FIRDatabaseReference!
    
    enum ActionType {
        case smile
        case heart
        case cry
        case clap
        case ok
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // FIXME: 後で消す。いいね機能の参考になる
        //let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        //tap.numberOfTapsRequired = 1
        //likeImg.addGestureRecognizer(tap)
        //likeImg.isUserInteractionEnabled = true
        
        addTapGestureToLabel()
    }
    
    /// ユーザーが投稿にアクションする用のラベルをタップできるように設定する
    func addTapGestureToLabel () {
        let smileTap = UITapGestureRecognizer(target: self, action: #selector(smileTapped(sender:)))
        smileLabel.addGestureRecognizer(smileTap)
        
        let heartTap = UITapGestureRecognizer(target: self, action: #selector(heartTapped(sender:)))
        heartLabel.addGestureRecognizer(heartTap)
        
        let cryTap = UITapGestureRecognizer(target: self, action: #selector(cryTapped(sender:)))
        cryLabel.addGestureRecognizer(cryTap)
        
        let clapTap = UITapGestureRecognizer(target: self, action: #selector(clapTapped(sender:)))
        clapLabel.addGestureRecognizer(clapTap)
        
        let okTap = UITapGestureRecognizer(target: self, action: #selector(okTapped(sender:)))
        okLabel.addGestureRecognizer(okTap)
    }
    
    func configureCell (post: Post, img: UIImage? = nil) {
        self.post = post
        // ユーザーの投稿へのアクション情報を見るための参照
        smileRef = DataService.ds.REF_USER_CURRENT.child("action").child("smile").child(post.postKey)
        heartRef = DataService.ds.REF_USER_CURRENT.child("action").child("heart").child(post.postKey)
        cryRef = DataService.ds.REF_USER_CURRENT.child("action").child("cry").child(post.postKey)
        clapRef = DataService.ds.REF_USER_CURRENT.child("action").child("clap").child(post.postKey)
        okRef = DataService.ds.REF_USER_CURRENT.child("action").child("ok").child(post.postKey)

        setSmileLabel(ref: smileRef)
        setHeartLabel(ref: heartRef)
        setCryLabel(ref: cryRef)
        setClapLabel(ref: clapRef)
        setOkLabel(ref: okRef)
        
        self.caption.text = post.caption
        
        // いいね数表示用ラベル
        //self.likesLbl.text = "\(post.likes)"
        self.smileCountLabel.text = "\(post.smiles)"
        self.heartCountLabel.text = "\(post.hearts)"
        self.cryCountLabel.text = "\(post.cries)"
        self.clapCountLabel.text = "\(post.claps)"
        self.okCountLabel.text = "\(post.oks)"

        
        // FIXEME:　全体のタイムラインと個人の過去投稿でif分岐したい　→　別になくてもいいか
        setUserImage(uid: post.postUserId)
        
//        //Cacheにある場合とない場合（storageからとってきてCaCheに入れる）
//        //TODO:Cache適宜消さないと容量まずいきがする
//        if img != nil {
//            self.postImag.image = img
//        } else {
//            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
//
//            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                if error != nil {
//                    print("JESS: Unable to download image from Firebase storage")
//                } else {
//                    print("JESS: Image downloaded from Firebase storage")
//                    if let imgData = data {
//                        if let img = UIImage(data: imgData) {
//                            self.postImag.image = img
//                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
//
//                        }
//                    }
//                }
//            })
//        }
        
//        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            if let _ = snapshot.value as? NSNull {
//                self.likeImg.image = UIImage(named: "empty-heart")
//            } else {
//                self.likeImg.image = UIImage(named: "filled-heart")
//            }
//        })
    }
    
    /// 投稿者のアイコン取得 FIXME:画像荒い
    ///
    /// - Parameter uid: 投稿者のid
    func setUserImage(uid: String) {
        let ref = DataService.ds.REF_USER_IMAGES.child(uid)
        
        ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("Error: Firebase storageからアイコン画像の取得失敗")
            } else {
                print("OK: Firebase storageからアイコン取得成功")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.profileImg.image = img
                        //FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                    }
                }
            }
        })
    }
    
    // FIXME: ここともう一つしたのブロックで同じようなメソッドを5個ずつ作ってるのそれぞれ1つにまとめたいなあ
    ////////// ユーザーのアクション状況をビューに反映させる
    func setSmileLabel(ref: FIRDatabaseReference) {
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.smileLabel.notSelectedLabel()
            } else {
                self.smileLabel.selectedLabel()
            }
        })
    }
    
    func setHeartLabel(ref: FIRDatabaseReference) {
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.heartLabel.notSelectedLabel()
            } else {
                self.heartLabel.selectedLabel()
            }
        })
    }
    
    func setCryLabel(ref: FIRDatabaseReference) {
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.cryLabel.notSelectedLabel()
            } else {
                self.cryLabel.selectedLabel()
            }
        })
    }
    
    func setClapLabel(ref: FIRDatabaseReference) {
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.clapLabel.notSelectedLabel()
            } else {
                self.clapLabel.selectedLabel()
            }
        })
    }
    
    func setOkLabel(ref: FIRDatabaseReference) {
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.okLabel.notSelectedLabel()
            } else {
                self.okLabel.selectedLabel()
            }
        })
    }
    
    //////////
    
    
    // FIXME: 2重タップの制御が必要。現状のisEnabledのタイミングでは不十分。
    ////////// ユーザーのタップアクション時のメソッド5つ。タップ時にユーザーの情報として任意の記事にアクションしたことを保持する。処理はほぼ同じ。dbにのパス,ajust関数が異なる。
    @objc func smileTapped (sender: UITapGestureRecognizer) {
        self.smileLabel.isEnabled = false
        smileRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.smileLabel.selectedLabel()
                self.post.ajustSmile(addSmile: true)
                self.smileRef.setValue(true)
                self.addPostUserGetActinos(actionType: ActionType.smile, isAdd: true)
            } else {
                self.smileLabel.notSelectedLabel()
                self.post.ajustSmile(addSmile: false)
                self.smileRef.removeValue()
                self.addPostUserGetActinos(actionType: ActionType.smile, isAdd: false)
            }
            self.smileLabel.isEnabled = true
        })
    }
    
    @objc func heartTapped (sender: UITapGestureRecognizer) {
        self.heartLabel.isEnabled = false
        heartRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.heartLabel.selectedLabel()
                self.post.ajustHeart(addHeart: true)
                self.heartRef.setValue(true)
                self.addPostUserGetActinos(actionType: ActionType.heart, isAdd: true)
            } else {
                self.heartLabel.notSelectedLabel()
                self.post.ajustHeart(addHeart: false)
                self.heartRef.removeValue()
                self.addPostUserGetActinos(actionType: ActionType.heart, isAdd: false)
            }
            self.heartLabel.isEnabled = true
        })
    }
    
    @objc func cryTapped (sender: UITapGestureRecognizer) {
        self.cryLabel.isEnabled = false
        cryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.cryLabel.selectedLabel()
                self.post.ajustCry(addCry: true)
                self.cryRef.setValue(true)
                self.addPostUserGetActinos(actionType: ActionType.cry, isAdd: true)
            } else {
                self.cryLabel.notSelectedLabel()
                self.post.ajustCry(addCry: false)
                self.cryRef.removeValue()
                self.addPostUserGetActinos(actionType: ActionType.cry, isAdd: false)
            }
            self.cryLabel.isEnabled = true
        })
    }
    
    @objc func clapTapped (sender: UITapGestureRecognizer) {
        self.clapLabel.isEnabled = false
        clapRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.clapLabel.selectedLabel()
                self.post.ajustClap(addClap: true)
                self.clapRef.setValue(true)
                self.addPostUserGetActinos(actionType: ActionType.clap, isAdd: true)
            } else {
                self.clapLabel.notSelectedLabel()
                self.post.ajustClap(addClap: false)
                self.clapRef.removeValue()
                self.addPostUserGetActinos(actionType: ActionType.smile, isAdd: false)
            }
            self.clapLabel.isEnabled = true
        })
    }
    
    @objc func okTapped (sender: UITapGestureRecognizer) {
        self.okLabel.isEnabled = false
        okRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.okLabel.selectedLabel()
                self.post.ajustOk(addOk: true)
                self.okRef.setValue(true)
                self.addPostUserGetActinos(actionType: ActionType.ok, isAdd: true)
            } else {
                self.okLabel.notSelectedLabel()
                self.post.ajustOk(addOk: false)
                self.okRef.removeValue()
                self.addPostUserGetActinos(actionType: ActionType.ok, isAdd: false)
            }
            self.okLabel.isEnabled = true
        })
    }
    //////////

    /// 投稿者のデータとしてそれぞれの獲得アクション数を増減させる
    ///
    /// - Parameters:
    ///   - actionType: どのアクションをタップしたか
    ///   - isAdd: アクション追加か取消か
    func addPostUserGetActinos(actionType: ActionType, isAdd: Bool) {
        
        var actionTypeString: String?
        switch actionType {
        case ActionType.smile:
            actionTypeString = "smiles"
        case ActionType.heart:
            actionTypeString = "hearts"
        case ActionType.cry:
            actionTypeString = "cries"
        case ActionType.clap:
            actionTypeString = "claps"
        case ActionType.ok:
            actionTypeString = "oks"
        }
        
        if let _ = actionTypeString {
            let getSmileActionsTotalRef = DataService.ds.REF_USER_CURRENT.child("getActions").child(actionTypeString!)
            getSmileActionsTotalRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let getActions = snapshot.value as? Int {
                    if isAdd {
                        getSmileActionsTotalRef.setValue(getActions + 1)
                    } else {
                        getSmileActionsTotalRef.setValue(getActions - 1)
                    }
                }
            })
        }
    }
}
