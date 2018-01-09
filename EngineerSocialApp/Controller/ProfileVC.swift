//
//  ProfileVC.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2017/12/30.
//

import UIKit
import Firebase

class ProfileVC: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var userImageView: CircleView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // 投稿データを円グラフで表示するために使用
    var developDataView: PostData!
    var devLanguagesArray = [DevelopData]()
    var devThingsArray = [DevelopData]()
    
    var postTableView: PostTableView!
    var myPosts = [Post]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfileScrollView()
        setUserInfo()
    }
    
    // FIXME: オートレイアウト使用時、viewWillAppearでもframe.sizeは決定していないので、ここでサイズ決めのメソッドとか使用してるとまずいよ　→ didlayoutに処理を移したよん
    override func viewWillAppear(_ animated: Bool) {
        if self.developDataView != nil {
            self.getMyPostData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        if self.postTableView == nil {
            setMyPostTableView()
        } else {
            // FIXME: ビューを生成せずにデータだけ更新する
        }
        // データ取得した後にテーブル更新
        getMyPosts()
        
        // データ取得した後にチャートがすでにあれば、データ更新。なければ生成して表示。
        if self.developDataView == nil {
            // チャートビューの生成
            self.setDevelopDataView()
            self.getMyPostData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setProfileScrollView() {
        profileScrollView.delegate = self
        self.profileScrollView.contentSize.width = self.view.frame.width*2
        self.profileScrollView.isPagingEnabled = true
    }
    
    // FIXME: ここ、DataServiceクラスのカレントユーザー使わないと、キーチェーン利用してログインした時にcurrentUserが取得できない可能せいある気がする。→ 言う通り
    func setUserInfo() {
        let loginUser = FIRAuth.auth()?.currentUser
        let name = loginUser?.displayName
        let imageUrl = loginUser?.photoURL?.absoluteString
        
        self.nameLabel.text = name
        ProfileVC.downloadImageWithDataTask(urlString: imageUrl!, imageView: userImageView)
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
            self.developDataView.setupDevLangsPieChartView(developDataArray: self.devLanguagesArray)
            self.developDataView.animationDevLangsChart()
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
            self.developDataView.setupDevThingsPieChartView(developDataArray: self.devThingsArray)
            self.developDataView.animationDevThingsChart()
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
            self.developDataView = PostData(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.profileScrollView.frame.height))
            profileScrollView.addSubview(developDataView)
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
    
    static func downloadImageWithDataTask(urlString: String, imageView: UIImageView){
        
        // FIXME: 5minの間違い？
        let fiveSecondsCache: TimeInterval = 5 * 60
        
        //urlをエンコーディングして無効なURLが入ったら処理を抜ける
        guard let encURL = URL(string:urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) else {
            print("Error：　urlをエンコード出来なかったよ!")
            return
        }
        
        let req = URLRequest(url: encURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: fiveSecondsCache)
        
        let conf = URLSessionConfiguration.default
        let session = URLSession(configuration: conf, delegate: nil, delegateQueue: OperationQueue.main)
        
        session.dataTask(with: req, completionHandler:
            { (data, resp, err) in
                if (err == nil){
                    print("画像表示成功！")
                    let image = UIImage(data: data!)
                    imageView.image = image
                } else {
                    print("Error：　画像の取得に失敗しました")
                }
        }).resume()
    }
}
