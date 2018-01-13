//
//  PostActionLabel.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2018/01/03.
//

import UIKit

class PostActionLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        notSelectedLabel()
    }
    
    func notSelectedLabel() {
        self.alpha = 0.5
        layer.borderColor = UIColor.init(hex: COOL_GRAY).cgColor
        layer.backgroundColor = UIColor.white.cgColor
        layer.borderWidth = 0.7
        layer.cornerRadius = 10
    }
    
    func selectedLabel() {
        self.alpha = 1
        layer.borderColor = UIColor.init(hex: BABY_BLUE, alpha: 0.6).cgColor
        layer.backgroundColor = UIColor.init(hex: BABY_BLUE, alpha: 0.2).cgColor
        layer.borderWidth = 0.7
        layer.cornerRadius = 10
    }
}
