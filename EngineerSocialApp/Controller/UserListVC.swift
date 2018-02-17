//
//  UserListVC.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/13.
//

import UIKit

class UserListVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    
    var followListTable: UserListTableView!
    var followerListTable: UserListTableView!
    var isShowFollowPage = true
    
    var followUidArray = [String]()
    var followerUidArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        // フォロー、フォロワーラベルにタップ時の挙動を追加、選択状況を設定
        initTopLabel()
        setTopSelectedLabel()
        if !isShowFollowPage {
            let pointX = self.view.frame.width
            scrollView.setContentOffset(CGPoint(x: pointX, y: 0), animated: true)
            setTopSelectedLabel()
        }
    }
    
    override func viewDidLayoutSubviews() {
        // 2ページ分のスクロールビューの生成
        scrollView.contentSize.width = self.view.frame.width * 2
        scrollView.isPagingEnabled = true
        
        if followListTable == nil && followerListTable == nil {
            initTableView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initTableView() {
        
        followListTable = UserListTableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: scrollView.frame.height),style: UITableViewStyle.plain)
        followListTable.uidArray = followUidArray
        followListTable.userListTableViewDelegate = self
        scrollView.addSubview(followListTable)
        
        followerListTable = UserListTableView(frame: CGRect(x: self.view.frame.width, y: 0, width: self.view.frame.width, height: scrollView.frame.height),style: UITableViewStyle.plain)
        followerListTable.uidArray = followerUidArray
        followerListTable.userListTableViewDelegate = self
        scrollView.addSubview(followerListTable)
    }
    
    func initTopLabel() {
        let followLblTap = UITapGestureRecognizer(target: self, action: #selector(followLblTapped(sender:)))
        followLabel.addGestureRecognizer(followLblTap)
        
        let followerLblTap = UITapGestureRecognizer(target: self, action: #selector(followerLblTapped(sender:)))
        followerLabel.addGestureRecognizer(followerLblTap)
    }
    
    func setTopSelectedLabel(){
        let page = scrollView.contentOffset.x
        
        switch page {
        case 0:
            followLabel.textColor = UIColor(hex: TERMINAL_TEXT_WHITE)
            followerLabel.textColor = UIColor(hex: TERMINAL_TEXT_GRAY)
        case self.view.frame.width:
            followLabel.textColor = UIColor(hex: TERMINAL_TEXT_GRAY)
            followerLabel.textColor = UIColor(hex: TERMINAL_TEXT_WHITE)
        default:
            break
        }
    }
    
    @objc func followLblTapped (sender: UITapGestureRecognizer) {
        let pointX = 0
        scrollView.setContentOffset(CGPoint(x: pointX, y: 0), animated: true)
        setTopSelectedLabel()
    }
    
    @objc func followerLblTapped (sender: UITapGestureRecognizer) {
        let pointX = self.view.frame.width
        scrollView.setContentOffset(CGPoint(x: pointX, y: 0), animated: true)
        setTopSelectedLabel()
    }
}

extension UserListVC: UIScrollViewDelegate {

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setTopSelectedLabel()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setTopSelectedLabel()
    }

}

extension UserListVC: UserListTableViewDelegate {
    func didSelectCell() {
        //
    }
}
