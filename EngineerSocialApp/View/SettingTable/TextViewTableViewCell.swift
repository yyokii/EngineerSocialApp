//
//  TextViewTableViewCell.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/23.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initProfileCell(profile: String) {
        titleLabel.text = "Me"
        textView.text = profile
    }
}
