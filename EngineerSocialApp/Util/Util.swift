//
//  Util.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/03/11.
//

import Foundation
import UIKit
import MessageUI

class Util {
    
    class func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let now = Date()
        return formatter.string(from: now)
    }
    
    class func presentMailView(vc: UIViewController, subject: String, message: String){
        if MFMailComposeViewController.canSendMail() == false {
            return
        }
        
        let mailViewController = MFMailComposeViewController()
        let toRecipients = ["timetohackapp@gmail.com"]
        
        mailViewController.mailComposeDelegate = vc as? MFMailComposeViewControllerDelegate
        mailViewController.setSubject(subject)
        mailViewController.setToRecipients(toRecipients)
        mailViewController.setMessageBody(message, isHTML: false)
        
        vc.present(mailViewController, animated: true, completion: nil)
    }
    
    /// 非表示にする投稿を保存する
    ///
    /// - Parameter postKey: 非表示にする投稿key
    class func saveHidePosts(postKey: String)
    {
        if UserDefaults.standard.object(forKey: HIDE_POSTS) != nil {
            // 非表示投稿を保存している場合は重複確認
            var hidePosts = UserDefaults.standard.object(forKey: HIDE_POSTS) as! Array<String>
            if !hidePosts.contains(postKey){
                hidePosts.append(postKey)
                UserDefaults.standard.set(hidePosts, forKey: HIDE_POSTS)
            }else {
                // 重複してる（非表示にしているものを再度非表示にすることは起こり得ないはずなので、ここには来ない）
            }
        }else {
            // 非表示投稿を保存していない場合
            // 配列作成
            let hidePosts = [postKey]
            // 保存
            UserDefaults.standard.set(hidePosts, forKey: HIDE_POSTS)
        }
    }
    
    class func isNotShowPost(postKey: String) -> Bool {
        if UserDefaults.standard.object(forKey: HIDE_POSTS) != nil {
            let hidePosts = UserDefaults.standard.object(forKey: HIDE_POSTS) as! Array<String>
            if hidePosts.contains(postKey){
                // 非表示設定しているのでtrue（＝非表示にする）
                return true
            }else {
                return false
            }
        }else {
            // 非表示投稿を保存していない場合は全投稿を表示
            return false
        }
    }
}
