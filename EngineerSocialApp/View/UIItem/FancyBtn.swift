//
//  FancyBtn.swift
//  UdemySocialApp
//
//  Created by 東原与生 on 2017/03/16.
//  Copyright © 2017年 yoki. All rights reserved.
//

import UIKit

class FancyBtn: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.cornerRadius = 10
    }
    
    public func applyEnableBtn() {
        self.isEnabled = true
        self.backgroundColor = UIColor(hex: TERMINAL_TEXT_WHITE, alpha: 1)
        self.alpha = 1
    }
    
    public func applyUnEnableBtn() {
        self.isEnabled = false
        self.backgroundColor = UIColor(hex: TERMINAL_TEXT_GRAY, alpha: 0.7)
        self.alpha = 0.5
    }
}
