//
//  SettingTableView.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/23.
//

import UIKit

class SettingTableView: UITableView {
    
    var currentUser: User!
    
    override init(frame: CGRect,style: UITableViewStyle){
        super.init(frame: frame, style: style)
        
        self.delegate = self
        self.dataSource = self
        
        self.register(UINib(nibName: "TextFieldTableViewCell",bundle: nil), forCellReuseIdentifier: "TextFieldTableViewCell")
        self.register(UINib(nibName: "TextViewTableViewCell",bundle: nil), forCellReuseIdentifier: "TextViewTableViewCell")

        self.separatorColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
            cell.initNameCell(name: currentUser.name!)
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewTableViewCell", for: indexPath) as! TextViewTableViewCell
            cell.initProfileCell(profile: currentUser.profile!)
            cell.selectionStyle = .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
            cell.initTwitterCell(twitter: currentUser.twitter!)
            cell.selectionStyle = .none
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
            cell.initGitCell(git: currentUser.git!)
            cell.selectionStyle = .none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 100
        }else {
            return 60
        }
    }
}

extension SettingTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
