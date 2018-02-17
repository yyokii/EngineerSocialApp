//
//  ProfileHeaderView.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/01/28.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseAuth

protocol ProfilehHeaderViewDelegate: class {
    func followButtonTapped() -> Void
    func followLabelTapped() -> Void
    func followerLabelTapped() -> Void
}

class ProfilehHeaderView: UIView {
    
    @IBOutlet weak var userImageView: CircleView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    
    weak var profilehHeaderViewDelegate: ProfilehHeaderViewDelegate?
    
    // FIXME: デバッグ用
    @IBAction func signOutTap(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("JESS: ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
    }
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib(){
        let view = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        // dbからフォロー状態を取得できるまでは反応させない
        followBtn.isEnabled = false
        self.addSubview(view)
    }
    
    @IBAction func tapFollowBtn(_ sender: Any) {
        profilehHeaderViewDelegate?.followButtonTapped()
    }
    
    func applyFollowBtn(){
        followBtn.setTitle("フォローする", for: .normal)
        followBtn.isEnabled = true
    }
    
    func applyUnFollowBtn(){
        followBtn.setTitle("フォローをはずす", for: .normal)
        followBtn.isEnabled = true
    }
    
    func initFollowLabel(followCount: Int){
        let followTap = UITapGestureRecognizer(target: self, action: #selector(followTapped(sender:)))
        followLabel.addGestureRecognizer(followTap)
        
        followLabel.text = "\(followCount):FOLLOW"
        followLabel.isUserInteractionEnabled = true
    }
    
    @objc func followTapped (sender: UITapGestureRecognizer) {
        profilehHeaderViewDelegate?.followLabelTapped()
    }
    
    func initFollowerLabel(followerCount: Int){
        let followerTap = UITapGestureRecognizer(target: self, action: #selector(followerTapped(sender:)))
        followerLabel.addGestureRecognizer(followerTap)
        
        followerLabel.text = "\(followerCount):FOLLOWER"
        followerLabel.isUserInteractionEnabled = true
    }
    
    @objc func followerTapped (sender: UITapGestureRecognizer) {
        profilehHeaderViewDelegate?.followerLabelTapped()

    }
}
