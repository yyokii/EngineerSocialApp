//
//  ProfileHeaderView.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/01/28.
//

import UIKit

class ProfilehHeaderView: UIView {
    
    @IBOutlet weak var userImageView: CircleView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var follorImageView: UIImageView!
    
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
        self.addSubview(view)
    }
}
