//
//  ProfileVC.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2017/12/30.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

/// ＜初回＞didLoad：tableviewセット　didLayout：tableのheaderをセット、ユーザーの情報を取得して表示
/// ＜初回以後＞willappear：投稿情報、過去投稿の最新データを取得
class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // コンテンツ切り替え用のラベル
    @IBOutlet weak var myDataLabel: ProfileSetContentLabel!
    @IBOutlet weak var myPostLabel: ProfileSetContentLabel!
    
    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var userImageView: CircleView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // ベースになってるテーブルビュー関係
    var baseTableView: UITableView!
    var headerView: ProfilehHeaderView!
    
    let hederViewHeight = 350
    
    // 獲得した総アクション数を保持
    var smiles: Int = 0
    var heats: Int = 0
    var cries: Int = 0
    var claps: Int = 0
    var oks: Int = 0
    
    // 投稿データを円グラフで表示するために使用
    var postDataView: PostDataView!
    var devLanguagesArray = [DevelopData]()
    var devThingsArray = [DevelopData]()
    
    // 過去の投稿を表示するために使用
    var postTableView: PostTableView!
    var myPosts = [Post]()

    // プロフィール画像を設定
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ユーザー情報
//        setUserInfo()
//        setProfileScrollView()
        
        // tapGestureの設定を初期化
//        initSelectCotentLabel()

//        setSelectContentLabel()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        setBaseTableView()
        // ユーザー情報を表示するヘッダーviewを設定
        setHeaderView()
        // ユーザ情報表示
        FirebaseLogic.setUserInfo(nameLabel: headerView.userNameLabel, userImageView: headerView.userImageView)
        // コンテンツの表示
        getMyPostData()
        getGetActionsData()
        getMyPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if headerView != nil {
            FirebaseLogic.setUserInfo(nameLabel: headerView.userNameLabel, userImageView: headerView.userImageView)
        }
        
        if postDataView != nil {
            // 投稿データを取得してviewの更新
            self.getMyPostData()
            self.getGetActionsData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initSelectCotentLabel(){
        // ユーザーのプロフィール画像をタップしてカメラロールから変更できるようにする
        let userImageTap = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(userImageTap)
        
        // コンテンツ切り替え用のラベルのタップ時の挙動を設定
        let dataLabelTap = UITapGestureRecognizer(target: self, action: #selector(dataLabelTapped))
        myDataLabel.isUserInteractionEnabled = true
        myDataLabel.addGestureRecognizer(dataLabelTap)
        let postLabelTap = UITapGestureRecognizer(target: self, action: #selector(postLabelTapped))
        myPostLabel.isUserInteractionEnabled = true
        myPostLabel.addGestureRecognizer(postLabelTap)
    }
    
    /// 獲得したアクション数を取得
    func getGetActionsData() {
        // 開発言語のデータ取得
        DataService.ds.REF_USER_CURRENT.child(GET_ACTIONS).observeSingleEvent(of: .value) { (snapshot) in
            
            if let getActions = snapshot.children.allObjects as? [FIRDataSnapshot]{
                print(getActions)
                for getAction in getActions{
                    switch getAction.key {
                    case SMILES:
                        self.smiles = getAction.value as! Int
                    case HEARTS:
                        self.heats = getAction.value as! Int
                    case CRIES:
                        self.cries = getAction.value as! Int
                    case CLAPS:
                        self.claps = getAction.value as!Int
                    case OKS:
                        self.oks = getAction.value as! Int
                    default:
                        break
                    }
                }
            }
            self.postDataView.setGetActionsCountLabel(smileCount: self.smiles.description, heartCount: self.heats.description, cryCount: self.cries.description, clapCount: self.claps.description, okCount: self.oks.description)
        }
    }
    
    /// 開発言語と開発項目のデータを取得して配列に保存
    func getMyPostData() {
        // 開発言語のデータ取得
        DataService.ds.REF_USER_CURRENT.child(PROGRAMMING_LANGUAGE).queryOrderedByValue().observeSingleEvent(of: .value) { (snapshot) in
            if let devLanguages = snapshot.children.allObjects as? [FIRDataSnapshot]{
                // 前回取得したデータが残らないように一度空にする
                self.devLanguagesArray = []
                for devLanguage in devLanguages{
                    let devLanguageData = DevelopData(devLanguage: devLanguage.key, count: devLanguage.value as! Int)
                    self.devLanguagesArray.insert(devLanguageData, at: 0)
                }
            }
            // FIXME: 投稿がない時、引数の配列要素が0になって、サンプルのチャートが表示されているかの確認必要
            self.postDataView.setupDevLangsPieChartView(developDataArray: self.devLanguagesArray)
            self.postDataView.animationDevLangsChart()
        }
        
        // 開発項目のデータ取得
        DataService.ds.REF_USER_CURRENT.child(DEVELOP).queryOrderedByValue().observeSingleEvent(of: .value) { (snapshot) in
            if let toDos = snapshot.children.allObjects as? [FIRDataSnapshot]{
                self.devThingsArray = []
                for todo in toDos{
                    let toDoData = DevelopData(toDo: todo.key, count: todo.value as! Int)
                    self.devThingsArray.insert(toDoData, at: 0)
                }
            }
            self.postDataView.setupDevThingsPieChartView(developDataArray: self.devThingsArray)
            self.postDataView.animationDevThingsChart()
        }
    }
    
    
    /// 過去の投稿を取得
    func getMyPosts() {
        DataService.ds.REF_USER_CURRENT.child(POSTS).observeSingleEvent(of: .value) { (snapshot) in
            print("取得したデータ：\(snapshot)")
            
            var myPostsKey = [String]()
            
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    let postKey = snap.key
                    myPostsKey.insert(postKey, at: 0)
                }
                
                print("取得した投稿キー配列:\(myPostsKey)")
                
                // 投稿全てのkeyが取得できたらそのkeyに該当するpostを取得する
                if !myPostsKey.isEmpty {
                    self.myPosts = []
                    for key in myPostsKey {
                        DataService.ds.REF_POSTS.child(key).observeSingleEvent(of: .value) { (snapshot) in
                            print("過去の投稿情報:\(snapshot)")
                            // 投稿情報を取得
                            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                                
                                let key = snapshot.key
                                let post = Post(postKey: key, postData: postDict)
                                self.myPosts.append(post)
                                
                                // 投稿データが１つずつ追加されているのがわかる
                                print("過去の投稿データ：\(self.myPosts)")
                            }
                            self.postTableView.posts = self.myPosts
                            if let _ = self.postTableView {
                                // 多分ないが（描画よりデータ取得の方が時間かかるのでデータ取れたころにはviewはあるはず）、nilをケア
                                self.postTableView.reloadData()
                            }
                        }
                    }
                } else {
                    print("Error: 過去の投稿がないよー")
                }
            }
        }
    }
    
    @objc func dataLabelTapped() {
        let pointX = 0
        profileScrollView.setContentOffset(CGPoint(x: pointX, y: 0), animated: true)
        setSelectContentLabel()
    }
    
    @objc func postLabelTapped() {
        let pointX = self.view.frame.width
        profileScrollView.setContentOffset(CGPoint(x: pointX, y: 0), animated: true)
        setSelectContentLabel()
    }
    
    // スクロールビューのコンテンツ位置に従って選択ラベルの状態を変更させる
    func setSelectContentLabel(){
        let page = profileScrollView.contentOffset.x
        
        switch page {
        case 0:
            myDataLabel.selectedLabel()
            myPostLabel.notSelectedLabel()
        case self.view.frame.width:
            myDataLabel.notSelectedLabel()
            myPostLabel.selectedLabel()
        default:
            break
        }
    }
    
    @objc func userImageTapped() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            userImageView.image = image
            // 選択した画像をストレージに画像を保存する
            if let imgData = UIImageJPEGRepresentation(image, 0.5) {
                let imgUid = DataService.ds.REF_USER_CURRENT.key
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
        } else {
            print("Error: 適切な画像が選択されなかったよん")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func setBaseTableView() {
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let displayWidth = self.view.frame.width
        let displayHeight = self.view.frame.height
        
        // テーブル
        baseTableView = UITableView(frame: CGRect(x: 0, y: statusBarHeight, width: displayWidth, height: displayHeight))
        baseTableView.register(UINib(nibName: "BaseTableViewCell",bundle: nil), forCellReuseIdentifier: "BaseTableViewCell")
        baseTableView.dataSource = self
        baseTableView.delegate = self
        // コンテンツをヘッダーの高さ分だけ下げる
        baseTableView.contentInset.top = CGFloat(hederViewHeight)
        baseTableView.rowHeight = self.view.frame.height
        baseTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        self.view.addSubview(baseTableView)
    }
    
    func setHeaderView() {
        // オリジナルヘッダービューを作成
        headerView = ProfilehHeaderView(frame: CGRect(x: 0, y: -CGFloat(hederViewHeight), width: self.view.frame.width, height: CGFloat(hederViewHeight)))
        headerView.backgroundColor = UIColor.green
        baseTableView.addSubview(headerView)
    }

    // 暫時的にサインアウトボタンと投稿ボタンを設置
    @IBAction func signOutTapped(_ sender: Any) {
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("JESS: ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
    @IBAction func postTapped(_ sender: Any) {
        performSegue(withIdentifier: "toPost", sender: nil)
    }
}

// FIXME: 挙動がおかしかったので一旦コメントアウト（baseTableView入れた時におかしくなってた）→ cell内のscrollを制御する必要がある
//extension ProfileVC: UIScrollViewDelegate {
//
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        setSelectContentLabel()
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        setSelectContentLabel()
//    }
//
//}

extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BaseTableViewCell", for: indexPath) as! BaseTableViewCell
        cell.setScrollView(contentWidth: self.view.frame.width*2)
        let contentHeight = self.view.frame.height - UIApplication.shared.statusBarFrame.height - CGFloat(hederViewHeight) + CGFloat(hederViewHeight/2)
        
        // ①投稿データviewの生成
        postDataView = PostDataView(frame:  CGRect(x: 0, y: 0, width: self.view.frame.width, height: contentHeight))
        postDataView.scrollView.isScrollEnabled = false
        postDataView.delegate = self

        // ②過去の投稿を表示するviewの生成
        let frame = CGRect(x: self.view.frame.width, y: 0, width: self.view.frame.width, height: contentHeight)
        self.postTableView = PostTableView(frame: frame,style: UITableViewStyle.plain)
        // セルの高さを可変にする
        postTableView.estimatedRowHeight = 200
        postTableView.rowHeight = UITableViewAutomaticDimension
        postTableView.isScrollEnabled = false
        postTableView.postTableViewDelegate = self
        
        cell.scrollView.addSubview(postDataView)
        cell.scrollView.addSubview(postTableView)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 下に引っ張ったときは、ヘッダー位置を計算して動かないようにする
        if scrollView.contentOffset.y < -CGFloat(hederViewHeight) {
            self.headerView.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: self.view.frame.width, height: CGFloat(hederViewHeight))
        }
        
        guard let _ = postDataView else {
            return
        }
        
        if scrollView.contentOffset.y > -CGFloat(hederViewHeight/2){
            // cell内のコンテンツだけを動かせる
            baseTableView.contentOffset = CGPoint(x: 0, y: -CGFloat(hederViewHeight/2))
            baseTableView.isScrollEnabled = false
            // 下部のコンテンツのスクロールの設定を変更
            postDataView.scrollView.isScrollEnabled = true
            postTableView.isScrollEnabled = true
        }else {
            baseTableView.isScrollEnabled = true
            postDataView.scrollView.isScrollEnabled = false
            postTableView.isScrollEnabled = false
        }
    }
    
}

extension ProfileVC: PostDataViewDelegate{
    func didScrollToBottom(y: CGFloat) {
    }
    
    func didScrollToTop(y: CGFloat) {
        if baseTableView.contentOffset.y <= 0 {
            baseTableView.isScrollEnabled = true
            postDataView.scrollView.isScrollEnabled = false
            // -100（固定させるヘッダーの高さ）の設定をすることで挙動のカクツキが改善。ないとスクロールが2タップぐらい反応しない
            baseTableView.contentOffset = CGPoint(x: 0, y: -CGFloat(hederViewHeight/2))
        }
    }
}

extension ProfileVC: PostTableViewDelegate{
    func didTableScrollToBottom(y: CGFloat) {
    }
    
    func didTableScrollToTop(y: CGFloat) {
        if baseTableView.contentOffset.y <= 0 {
            baseTableView.isScrollEnabled = true
            postTableView.isScrollEnabled = false
            // -100（固定させるヘッダーの高さ）の設定をすることで挙動のカクツキが改善。ないとスクロールが2タップぐらい反応しない
            baseTableView.contentOffset = CGPoint(x: 0, y: -CGFloat(hederViewHeight/2))
        }
    }
}

