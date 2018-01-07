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
    
    var myPosts = [Post]()
    var postTableView: PostTableView!
    var postDataView: PostData!
    var devLanguagesArray = [DevelopData]()
    var doArray = [DevelopData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfileScrollView()
        setUserInfo()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // スクロールビュー内のコンテンツ設定
        if self.postDataView == nil {
            setPostDataView()
        }
        
        if self.postTableView == nil {
            setMyPostTableView()
        }
        getMyPosts()
        getMyPostData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setProfileScrollView() {
        profileScrollView.delegate = self
        
        self.profileScrollView.contentSize = CGSize(width: self.view.frame.width*2, height: self.profileScrollView.frame.height)
        self.profileScrollView.isPagingEnabled = true
        
    }
    
    // （個人投稿データ）下部の横スクロールビュー内のコンテンツ
    func setPostDataView() {
        // 高さは固定ではなくて、コンテンツの大きさに依存する感じで。→縦のスクロールビュー入れてるから考えなくてもいいかも
        let xibView = PostData(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        profileScrollView.addSubview(xibView)
    }
    
    // （自分の過去投稿を表示するテーブルビュー）下部の横スクロールビュー内のコンテンツ
    func setMyPostTableView(){
        let frame = CGRect(x: self.view.frame.width, y: 0, width: self.view.frame.width, height: self.profileScrollView.frame.height)
        self.postTableView = PostTableView(frame: frame,style: UITableViewStyle.plain)
        postTableView.posts = myPosts
        // セルの高さを可変にする
        postTableView.estimatedRowHeight = 200
        postTableView.rowHeight = UITableViewAutomaticDimension
        self.profileScrollView.addSubview(postTableView)
    }
    
    // FIXME: ここ、DataServiceクラスのカレントユーザー使わないと、キーチェーン利用してログインした時にcurrentUserが取得できない可能せいある気がする。
    func setUserInfo() {
        let loginUser = FIRAuth.auth()?.currentUser
        let name = loginUser?.displayName
        let imageUrl = loginUser?.photoURL?.absoluteString
        
        self.nameLabel.text = name
        ProfileVC.downloadImageWithDataTask(urlString: imageUrl!, imageView: userImageView)
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
    
    
    /// 開発言語と開発項目のデータを取得して配列に保存
    func getMyPostData() {
        // 開発言語のデータ取得
        DataService.ds.REF_USER_CURRENT.child("devLanguage").queryOrderedByValue().observeSingleEvent(of: .value) { (snapshot) in
            if let devLanguages = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for devLanguage in devLanguages{
                    let devLanguageData = DevelopData(devLanguage: devLanguage.key, count: devLanguage.value as! Int)
                    self.devLanguagesArray.insert(devLanguageData, at: 0)
                }
            }
        }
        
        // 開発項目のデータ取得
        DataService.ds.REF_USER_CURRENT.child("do").queryOrderedByValue().observeSingleEvent(of: .value) { (snapshot) in
            if let toDos = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for todo in toDos{
                    let toDoData = DevelopData(toDo: todo.key, count: todo.value as! Int)
                    self.doArray.insert(toDoData, at: 0)
                }
            }
        }
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
