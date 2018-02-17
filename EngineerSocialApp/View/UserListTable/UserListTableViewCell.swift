//
//  UserListTableViewCell.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/13.
//

import UIKit

class UserListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!

    var uid:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        FirebaseLogic.fetchUserImage(uid: uid!) {[weak self] (img) in self?.userImage.image = img }
        FirebaseLogic.fetchUserName(uid: uid!) {[weak self] (name) in self?.userNameLabel.text = name }
    }
    
}
