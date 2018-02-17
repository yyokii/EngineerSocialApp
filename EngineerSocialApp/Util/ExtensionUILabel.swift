//
//  ExtensionUILabel.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/12.
//

import UIKit

// FIXME: 使えるかどうかはあなた次第？！
extension UILabel {
    
    func fontSizeToFit() {
        self.fontSizeToFit(minimumFontScale: 0.2, diminishRate: 0.5)
    }
    
    func fontSizeToFit(minimumFontScale: CGFloat, diminishRate: CGFloat) {
        let text = self.text!
        if (text.count == 0) {
            return
        }
        let size = self.frame.size
        let fontName = self.font.fontName
        let fontSize = self.font.pointSize
        let minimumFontSize = fontSize * minimumFontScale
        let isOneLine = (self.numberOfLines == 1)
        
        var boundingSize = CGSize.zero
        var area = CGSize.zero
        var font = UIFont()
        var fs = fontSize
        var newAttributes = [NSAttributedStringKey : Any]()
        self.attributedText?.enumerateAttributes(in: NSMakeRange(0, text.count), options: .longestEffectiveRangeNotRequired, using: { (attributes: [NSAttributedStringKey : Any], range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            newAttributes = attributes
        })
        if newAttributes.count == 0 {
            return
        }
        while (true) {
            font = UIFont(name: fontName, size: fs)!
            newAttributes[NSAttributedStringKey.font] = font
            
            if isOneLine {
                boundingSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: size.height)
            }
            else {
                boundingSize = CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude)
            }
            area = NSString(string: text).boundingRect(with: boundingSize, options: .usesLineFragmentOrigin, attributes: newAttributes, context: nil).size
            if isOneLine {
                if area.width <= size.width {
                    break;
                }
            }
            else {
                if area.height <= size.height {
                    break;
                }
            }
            
            if fs == minimumFontSize {
                break;
            }
            
            fs -= diminishRate
            if fs < minimumFontSize {
                fs = minimumFontSize
            }
        }
        
        self.font = font
    }
    
}
