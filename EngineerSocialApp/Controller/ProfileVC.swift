//
//  ProfileVC.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2017/12/30.
//

import UIKit
import Firebase

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // コンテンツ切り替え用のラベル
    @IBOutlet weak var myDataLabel: ProfileSetContentLabel!
    @IBOutlet weak var myPostLabel: ProfileSetContentLabel!
    
    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var userImageView: CircleView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // 獲得した総アクション数を保持
    var smiles: Int = 0
    var heats: Int = 0
    var cries: Int = 0
    var claps: Int = 0
    var oks: Int = 0
    
    // 投稿データを円グラフで表示するために使用
    var postDataView: PostData!
    var devLanguagesArray = [DevelopData]()
    var devThingsArray = [DevelopData]()
    
    // 過去の投稿を表示するために使用
    var postTableView: PostTableView!
    var myPosts = [Post]()

    // プロフィール画像を設定
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserInfo()
        setProfileScrollView()
        initSelectCotentLabel()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        setSelectContentLabel()
        getGetActionsData()
    }
    
    // FIXME: オートレイアウト使用時、viewWillAppearでもframe.sizeは決定していないので、ここでサイズ決めのメソッドとか使用してるとまずいよ　→ didlayoutに処理を移したよん、ほかのvcでも気を付けてね
    override func viewWillAppear(_ animated: Bool) {
        if self.postDataView != nil {
            self.getMyPostData()
            self.getGetActionsData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        // ①開発データを表示するコンテンツを設定。データ取得した後にチャートがすでにあれば、データ更新。なければ生成して表示。
        if self.postDataView == nil {
            // チャートビューの生成
            setDevelopDataView()
            getMyPostData()
            getGetActionsData()
        }
        // ②自分の過去投稿を表示するコンテンツを設定
        if self.postTableView == nil {
            setMyPostTableView()
        } else {
            // FIXME: ビューを生成せずにデータだけ更新する
        }
        // データ取得した後にテーブル更新
        getMyPosts()
        
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
    
    func setProfileScrollView() {
        profileScrollView.delegate = self
        self.profileScrollView.contentSize.width = self.view.frame.width*2
        self.profileScrollView.isPagingEnabled = true
    }
    
    // FIXME: ここ、DataServiceクラスのカレントユーザー使わないと、キーチェーン利用してログインした時にcurrentUserが取得できない可能性ある気がする。→ 言う通り
    func setUserInfo() {
        
        let loginUser = DataService.ds.REF_USER_CURRENT
        let userImageRef = DataService.ds.REF_USER_IMAGES.child(loginUser.key)
        userImageRef.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("Error: Firebase storageからアイコン画像の取得失敗")
            } else {
                print("OK: Firebase storageからアイコン取得成功")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.userImageView.image = img
                        //FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                    }
                }
            }
        })
    }
    
    /// 獲得したアクション数を取得
    func getGetActionsData() {
        // 開発言語のデータ取得
        DataService.ds.REF_USER_CURRENT.child("getActions").observeSingleEvent(of: .value) { (snapshot) in
            
            if let getActions = snapshot.children.allObjects as? [FIRDataSnapshot]{
                print(getActions)
                for getAction in getActions{
                    switch getAction.key {
                    case "smiles":
                        self.smiles = getAction.value as! Int
                    case "hearts":
                        self.heats = getAction.value as! Int
                    case "cries":
                        self.cries = getAction.value as! Int
                    case "claps":
                        self.claps = getAction.value as!Int
                    case "oks":
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
        DataService.ds.REF_USER_CURRENT.child("devLanguage").queryOrderedByValue().observeSingleEvent(of: .value) { (snapshot) in
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
        DataService.ds.REF_USER_CURRENT.child("do").queryOrderedByValue().observeSingleEvent(of: .value) { (snapshot) in
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
    
    func getMyPosts() {
        DataService.ds.REF_USER_CURRENT.child("posts").observeSingleEvent(of: .value) { (snapshot) in
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
                                
                                if self.myPosts.count == myPostsKey.count {
                                    // 過去の投稿情報が全件取得完了 → テーブルビューに表示 FIXME: ここもっとクールに書きたい
                                    //self.setMyPostTableView()
                                }
                            }
                            self.postTableView.posts = self.myPosts
                            self.postTableView.reloadData()
                        }
                    }
                } else {
                    print("Error: 過去の投稿がないよー")
                }
            }
        }
    }
    
    /// （個人投稿データ（開発言語））下部の横スクロールビュー内のコンテンツを設置
    func setDevelopDataView() {
            self.postDataView = PostData(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.profileScrollView.frame.height))
            profileScrollView.addSubview(postDataView)
    }
    
    /// （自分の過去投稿を表示するテーブルビュー）下部の横スクロールビュー内のコンテンツを設置
    func setMyPostTableView(){
        let frame = CGRect(x: self.view.frame.width, y: 0, width: self.view.frame.width, height: self.profileScrollView.frame.height)
        self.postTableView = PostTableView(frame: frame,style: UITableViewStyle.plain)
        postTableView.posts = myPosts
        // セルの高さを可変にする
        postTableView.estimatedRowHeight = 200
        postTableView.rowHeight = UITableViewAutomaticDimension
        self.profileScrollView.addSubview(postTableView)
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
}

extension ProfileVC: UIScrollViewDelegate {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setSelectContentLabel()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setSelectContentLabel()
    }
}
