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
    
    private let maxLength = 30
    private var previousText = ""
    private var lastReplaceRange: NSRange!
    private var lastReplacementString = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initProfileCell(profile: String) {
        titleLabel.text = "Me"
        textView.text = profile
    }
}

extension TextViewTableViewCell: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 文字数最大を決める.
        let maxLength: Int = 150
        // 入力済みの文字と入力された文字を合わせて取得.
        let str = textView.text + text
        // 文字数がmaxLength以下ならtrueを返す.
        if str.count < maxLength {
            return true
        }
        return false
    }
}
