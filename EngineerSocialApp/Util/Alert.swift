//
//  Alert.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/03/05.
//

import UIKit

class Alert {
    
    //iphoneとipadで、報告を出す方法を分ける（iphone：アクションシート、ipad：ダイアログ）
    // 不適切な投稿の報告機能
    public static func showPostReportView(vc: UIViewController, title: String, message: String, firstTitle: String, secondTitle: String, thirdTitle: String, firstAction: @escaping () -> Void, secondAction: @escaping () -> Void) {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            presentThreeBtnActionSheet(vc: vc, title: title, message: message, firstTitle: firstTitle, secondTitle: secondTitle, thirdTitle: thirdTitle, firstAction: firstAction, secondAction: secondAction)
        }else if UIDevice.current.userInterfaceIdiom == .pad {
            presentThreeBtnAlert(vc: vc, title: title, message: message, firstTitle: firstTitle, secondTitle: secondTitle, thirdTitle: thirdTitle, firstAction: firstAction, secondAction: secondAction)
        }
    }
    
    // 不適切なユーザーの投稿機能
    public static func showUserReportView(vc: UIViewController, title: String, message: String, firstTitle: String, secondTitle: String, firstAction: @escaping () -> Void) {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            presentTwoBtnActionSheet(vc: vc, title: title, message: message, firstTitle: firstTitle, secondTitle: secondTitle, firstAction: firstAction)
        }else if UIDevice.current.userInterfaceIdiom == .pad {
            presentTwoBtnAlert(vc: vc, title: title, message: message, positiveTitle: firstTitle, negativeTitle: secondTitle, positiveAction: firstAction)
        }
    }
    
    // アラートを表示する汎用メソッド（ボタン1個）
    public static func presentOneBtnAlert(vc: UIViewController, title: String, message: String, positiveTitle: String, positiveAction: @escaping () -> Void) {
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.alert)
        
        let positiveAction: UIAlertAction = UIAlertAction(title: positiveTitle, style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            positiveAction()
        })
        alert.addAction(positiveAction)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    // アラートを表示する汎用メソッド（ボタン2個）
    public static func presentTwoBtnAlert(vc: UIViewController, title: String, message: String, positiveTitle: String, negativeTitle: String, positiveAction: @escaping () -> Void) {
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.alert)
        
        let positiveAction: UIAlertAction = UIAlertAction(title: positiveTitle, style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            positiveAction()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: negativeTitle, style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        
        alert.addAction(positiveAction)
        alert.addAction(cancelAction)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    // アラートを表示する汎用メソッド（ボタン3個）
    public static func presentThreeBtnAlert(vc: UIViewController, title: String, message: String, firstTitle: String, secondTitle: String, thirdTitle: String, firstAction: @escaping () -> Void, secondAction: @escaping () -> Void) {
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.alert)
        
        let firstAction: UIAlertAction = UIAlertAction(title: firstTitle, style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            firstAction()
        })
        
        let secondAction: UIAlertAction = UIAlertAction(title: secondTitle, style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            secondAction()
        })
        
        let thirdAction: UIAlertAction = UIAlertAction(title: thirdTitle, style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(thirdAction)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    /// ボタン3つのアクションシートを表示する（隠す機能と報告機能をもつ）、FIXME:もっと汎用的にできる
    public static func presentThreeBtnActionSheet(vc: UIViewController, title: String, message: String, firstTitle: String, secondTitle: String, thirdTitle: String, firstAction: @escaping () -> Void, secondAction: @escaping () -> Void){
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: firstTitle, style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            firstAction()
        })
        let secondAction: UIAlertAction = UIAlertAction(title: secondTitle, style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            secondAction()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: thirdTitle, style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            
        })

        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(cancelAction)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    /// ボタン2つのアクションシートを表示する（隠す機能と報告機能をもつ）、FIXME:もっと汎用的にできる
    public static func presentTwoBtnActionSheet(vc: UIViewController, title: String, message: String, firstTitle: String, secondTitle: String, firstAction: @escaping () -> Void){
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.actionSheet)
        
        let firstAction: UIAlertAction = UIAlertAction(title: firstTitle, style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            firstAction()
        })
        let secondAction: UIAlertAction = UIAlertAction(title: secondTitle, style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(firstAction)
        alert.addAction(secondAction)

        vc.present(alert, animated: true, completion: nil)
    }
}
