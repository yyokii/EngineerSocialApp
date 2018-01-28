//
//  BaseTableViewCell.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/01/28.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setScrollView(contentWidth: CGFloat) {
        self.scrollView.contentSize.width = contentWidth
        self.scrollView.isPagingEnabled = true
    }
}
