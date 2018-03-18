//
//  SettingVC.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/24.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

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
        Alert.presentAlert(vc: self, title: "ログアウトしますか？🚪", message: "同じアカウントでログインするとデータは復元されます💮", positiveTitle: "ログアウト", negativeTitle: "キャンセル") {
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
