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
    
    static func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let now = Date()
        return formatter.string(from: now)
    }
    
    class func presentMailView(vc: UIViewController, subject: String, message: String){
        if MFMailComposeViewController.canSendMail()==false {
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
}
