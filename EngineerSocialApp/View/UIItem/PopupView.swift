//
//  PopupView.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/18.
//

import Foundation
import UIKit

public class PopupView {
    
    private var popupView: UIView!
    static let sharedManager = PopupView()
    
    private func setup() {
        popupView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        popupView.backgroundColor = UIColor(hex: TERMINAL_TEXT_GRAY)
        popupView.alpha = 0.8
        popupView.layer.cornerRadius = 8
        
        // ポップアップ内のコンテンツを設定
        let centerLabelWidth: CGFloat = 100
        let centerLabelHeight: CGFloat = 100
        let centerLabel = UILabel(frame: CGRect(x: popupView.frame.width/2.0 - centerLabelWidth/2, y: popupView.frame.height/2.0 - centerLabelHeight/2, width: centerLabelWidth, height: centerLabelHeight))
        centerLabel.text = "👍"
        centerLabel.font = UIFont(name:"Helvetica", size: 70.0)
        centerLabel.textAlignment = NSTextAlignment.center
        popupView.addSubview(centerLabel)
        
        let descLblWidth: CGFloat = 180
        let descLblHeight: CGFloat = 20
        let descriptionLabel = UILabel(frame: CGRect(x: popupView.frame.width/2.0 - descLblWidth/2, y: popupView.frame.height/2.0  + centerLabelHeight/2, width: descLblWidth, height: descLblHeight))
        descriptionLabel.text = "Success"
        descriptionLabel.textColor = UIColor(hex: TERMINAL_TEXT_WHITE)
        descriptionLabel.font = UIFont(name:"Helvetica Bold", size: 25.0)
        descriptionLabel.textAlignment = NSTextAlignment.center
        popupView.addSubview(descriptionLabel)
        
    }
    
    public func show() {
        if popupView == nil {
            self.setup()
        }
        
        if let window = UIApplication.shared.delegate?.window {
            window!.addSubview(popupView)
            popupView.center = window!.center
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn, animations: {
                self.popupView.alpha = 0
            }) { _ in
                self.popupView.removeFromSuperview()
                self.popupView.alpha = 1
            }
        }
    }
}
