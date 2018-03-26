//
//  SettingVC.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/24.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import MessageUI

class SettingVC: UIViewController {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
  
    // ユーザーの画像を変更する
    var imagePicker: UIImagePickerController!

    var currentUser: User?
    var settingTableView: SettingTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUserImageView()
        profileImageView.image = currentUser?.profileImage
    }
    
    override func viewDidLayoutSubviews() {
        if settingTableView == nil {
            initSettingTableView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initUserImageView(){
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        // ユーザーのプロフィール画像をタップしてカメラロールから変更できるようにする
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
    }
    
    func initSettingTableView(){
        settingTableView = SettingTableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.baseView.frame.height))
        settingTableView.currentUser = currentUser
        settingTableView.vc = self
        self.baseView.addSubview(settingTableView)
    }
    
    @objc func imageTapped() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okTapped(_ sender: Any) {
        let nameCell = settingTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextFieldTableViewCell
        let name = nameCell.textField.text!
        
        let profileCell = settingTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TextViewTableViewCell
        let profile = profileCell.textView.text!
        
        let twitterCell = settingTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! TextFieldTableViewCell
        let twitter = twitterCell.textField.text!
        
        let gitCell = settingTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! TextFieldTableViewCell
        let git = gitCell.textField.text!
        
        FirebaseLogic.updateUserInfo(vc: self, name: name, profile: profile, twitter: twitter, git: git) {
            [weak self] in self?.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func inquiryTapped(_ sender: Any) {
        Util.presentMailView(vc: self, subject: "お問い合わせ", message: "アプリのこと、開発について、などなどなんでもお問い合わせください！")
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        Alert.presentTwoBtnAlert(vc: self, title: "ログアウトしますか？🚪", message: "同じアカウントでログインするとデータは復元されます💮", positiveTitle: "ログアウト", negativeTitle: "キャンセル") {
            _ = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            do {
                try FIRAuth.auth()?.signOut()
            } catch let signOutError as NSError {
                print ("Error サインアウト: %@", signOutError)
                return;
            }
            
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // キーボード以外のところタップしたらキーボード隠す　FIXME: テーブルビュー内のタップには反応しないので修正したい
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let nameCell = settingTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextFieldTableViewCell
        let nameTextField = nameCell.textField!
        
        let profileCell = settingTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TextViewTableViewCell
        let profileTextView = profileCell.textView!
        
        let twitterCell = settingTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! TextFieldTableViewCell
        let twitterTextField = twitterCell.textField!
        
        let gitCell = settingTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! TextFieldTableViewCell
        let gitTextField = gitCell.textField!
        
        if nameTextField.isFirstResponder{
            nameTextField.resignFirstResponder()
        }
        
        if profileTextView.isFirstResponder{
            profileTextView.resignFirstResponder()
        }
        
        if twitterTextField.isFirstResponder{
            twitterTextField.resignFirstResponder()
        }
        
        if gitTextField.isFirstResponder{
            gitTextField.resignFirstResponder()
        }
    }
    
    // キーボードのNotificationを設定
    func configureObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // キーボードのNotificationを削除
    func removeObserver() {
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    // キーボードが現れた時に、画面全体をずらす。
    @objc func keyboardWillShow(notification: Notification?) {
        let rect = (notification?.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!/2)
            self.view.transform = transform
            
        })
    }
    
    // キーボードが消えたときに、画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            self.view.transform = CGAffineTransform.identity
        })
    }
}

extension SettingVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SettingVC: UINavigationControllerDelegate ,UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.image = image
            FirebaseLogic.uploadImage(image: image, completion: {})
        } else {
            print("Error: 適切な画像が選択されなかったよん")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension SettingVC: UITextViewDelegate, UITextFieldDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
