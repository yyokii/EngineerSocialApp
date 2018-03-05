//
//  Alert.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/03/05.
//

import UIKit

class Alert {
    public static func showReportActionSheet(vc: UIViewController, postUserId: String, positiveAction: @escaping () -> Void){
        let alert: UIAlertController = UIAlertController(title: "Alert!", message: "通報してもいいですか？", preferredStyle:  UIAlertControllerStyle.actionSheet)
        let defaultAction: UIAlertAction = UIAlertAction(title: "通報する⚠️", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            positiveAction()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル🙅‍♂️", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in

        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)

        vc.present(alert, animated: true, completion: nil)
    }
}
