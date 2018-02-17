//
//  UserListTableView.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/13.
//

import UIKit

protocol UserListTableViewDelegate: class {
    func didSelectCell() -> Void
}

class UserListTableView: UITableView {

    var uidArray = [String]()
    
    weak var userListTableViewDelegate: UserListTableViewDelegate?
    
    override init(frame: CGRect,style: UITableViewStyle){
        super.init(frame: frame, style: style)
        
        self.delegate = self
        self.dataSource = self
        
        self.register(UINib(nibName: "UserListTableViewCell",bundle: nil), forCellReuseIdentifier: "UserListTableViewCell")
        self.separatorColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension UserListTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uidArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell", for: indexPath) as! UserListTableViewCell
        cell.uid = uidArray[indexPath.row]
        cell.configureCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension UserListTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userListTableViewDelegate?.didSelectCell()
    }
}
