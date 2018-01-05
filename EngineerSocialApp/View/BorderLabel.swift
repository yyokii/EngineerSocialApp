//
//  BorderLabel.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2018/01/03.
//

import UIKit

class BorderLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        notSelectedLabel()
    }
    
    func notSelectedLabel() {
        self.alpha = 0.5
        layer.borderColor = UIColor.gray.cgColor
        layer.backgroundColor = UIColor.white.cgColor
        layer.borderWidth = 0.7
        layer.cornerRadius = 10
    }
    
    func selectedLabel() {
        self.alpha = 1
        layer.borderColor = UIColor.blue.cgColor
        layer.backgroundColor = UIColor.green.cgColor
        layer.borderWidth = 0.7
        layer.cornerRadius = 10
    }
}
