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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProdileScrollView()
        setPostDataView()
        setUserInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setProdileScrollView() {
        profileScrollView.delegate = self
        
        self.profileScrollView.contentSize = CGSize(width: self.view.frame.width*2, height: self.profileScrollView.frame.height)
        self.profileScrollView.isPagingEnabled = true
        
    }
    
    func setPostDataView() {
        // 高さは固定ではなくて、コンテンツの大きさに依存する感じで。→縦のスクロールビュー入れてるから考えなくてもいいかも
        let xibView = PostData(frame: CGRect(x: 0, y: 0, width: profileScrollView.frame.width, height: 200))
        profileScrollView.addSubview(xibView)
    }
    
    func setUserInfo() {
        let loginUser = FIRAuth.auth()?.currentUser
        let name = loginUser?.displayName
        let imageUrl = loginUser?.photoURL?.absoluteString
        
        self.nameLabel.text = name
        ProfileVC.downloadImageWithDataTask(urlString: imageUrl!, imageView: userImageView)
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
