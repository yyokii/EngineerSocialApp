//
//  ProfileSetContentLabel.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/01/13.
//

import UIKit

class ProfileSetContentLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        notSelectedLabel()
    }
    
    func notSelectedLabel() {
        self.alpha = 0.5
        self.textColor = UIColor.init(hex: COOL_GRAY)
        layer.borderColor = UIColor.init(hex: COOL_GRAY).cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 5
    }
    
    func selectedLabel() {
        self.alpha = 1
        self.textColor = UIColor.init(hex: NAVY_BLUE)
        layer.borderColor = UIColor.init(hex: NAVY_BLUE).cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 5
    }
}
