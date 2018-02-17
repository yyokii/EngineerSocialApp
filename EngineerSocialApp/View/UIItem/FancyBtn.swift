//
//  FancyBtn.swift
//  UdemySocialApp
//
//  Created by 東原与生 on 2017/03/16.
//  Copyright © 2017年 yoki. All rights reserved.
//

import UIKit

class FancyBtn: UIButton {
    
    //nibファイルとは、簡単にいってしまうとボタンなどのUI要素の描画情報が記述されたファイルのこと
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.cornerRadius = 2.0
    }

}
