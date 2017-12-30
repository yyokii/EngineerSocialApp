//
//  ProfileVC.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2017/12/30.
//

import UIKit

class ProfileVC: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var profileScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProdileScrollView()
        setPostDataView()
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
    
}
