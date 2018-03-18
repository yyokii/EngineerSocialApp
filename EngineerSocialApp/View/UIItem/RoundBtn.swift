//
//  RoundBtn.swift
//  UdemySocialApp
//
//  Created by 東原与生 on 2017/03/16.
//  Copyright © 2017年 yoki. All rights reserved.
//

import UIKit

class RoundBtn: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 5
    }

}
