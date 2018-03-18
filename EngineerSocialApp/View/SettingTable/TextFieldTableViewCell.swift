//
//  TextFieldTableViewCell.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/23.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func initNameCell(name: String) {
        titleLabel.text = "Name"
        textField.text = name
    }
    
    func initTwitterCell(twitter: String) {
        titleLabel.text = "Twitter"
        textField.placeholder = "アカウント名（@は不要です）"
        textField.text = twitter
    }
    
    func initGitCell(git: String) {
        titleLabel.text = "Git"
        textField.placeholder = "アカウント名"
        textField.text = git
    }
}
