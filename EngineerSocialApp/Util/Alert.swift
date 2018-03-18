//
//  Alert.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/03/05.
//

import UIKit

class Alert {
    
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
    public static func presentAlert(vc: UIViewController, title: String, message: String, positiveTitle: String, negativeTitle: String,  positiveAction: @escaping () -> Void) {
        
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
    
    // 通報用のアクションシートを表示する
    public static func presentReportActionSheet(vc: UIViewController, postUserId: String, positiveAction: @escaping () -> Void){
        let alert: UIAlertController = UIAlertController(title: "Alert!", message: "通報してもいいですか？", preferredStyle:  UIAlertControllerStyle.actionSheet)
        let positiveAction: UIAlertAction = UIAlertAction(title: "通報する⚠️", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            positiveAction()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル🙅‍♂️", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in

        })
        alert.addAction(cancelAction)
        alert.addAction(positiveAction)

        vc.present(alert, animated: true, completion: nil)
    }
}
