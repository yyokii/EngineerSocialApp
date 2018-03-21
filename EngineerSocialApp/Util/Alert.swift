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
    
    /// 投稿の通報用アクションシートを表示する
    ///
    /// - Parameters:
    ///   - vc: 表示するvc
    ///   - uid: 投稿Key、もしくはuid
    ///   - positiveAction: 通報時の処理（メールを開くとか）
    public static func presentPostReportActionSheet(vc: UIViewController, uid: String, hideAction: @escaping () -> Void, reportAction: @escaping () -> Void){
        let alert: UIAlertController = UIAlertController(title: "不適切なコンテンツ？", message: "不適切なコンテンツは非表示にしたり通報したりすることができます", preferredStyle:  UIAlertControllerStyle.actionSheet)
        let hideAction: UIAlertAction = UIAlertAction(title: "この投稿を非表示にする✨", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            hideAction()
        })
        let reportAction: UIAlertAction = UIAlertAction(title: "通報する⚠️", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            reportAction()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル🙅‍♂️", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            
        })
        
        alert.addAction(hideAction)
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    /// 通報用のアクションシートを表示する
    ///
    /// - Parameters:
    ///   - vc: 表示するvc
    ///   - uid: 投稿Key、もしくはuid
    ///   - positiveAction: 通報時の処理（メールを開くとか）
    public static func presentReportActionSheet(vc: UIViewController, uid: String, positiveAction: @escaping () -> Void){
        let alert: UIAlertController = UIAlertController(title: "Alert!", message: "不適切なコンテンツとして通報することができます", preferredStyle:  UIAlertControllerStyle.actionSheet)
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
