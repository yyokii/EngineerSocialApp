//
//  BaseTableViewCell.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/01/28.
//

import UIKit

protocol BaseTableViewCellDelegate: class {
    func scrollViewDidEndScroll(x: CGFloat) -> Void
}

class BaseTableViewCell: UITableViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    var baseTableViewCellDelegate: BaseTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setScrollView(contentWidth: CGFloat) {
        scrollView.delegate = self
        self.scrollView.contentSize.width = contentWidth
        self.scrollView.isPagingEnabled = true
    }
    
    /// １つ目のcellに入っているスクロールの位置を調整する
    ///
    /// - Parameter pointX: スクロールのx座標
    func adjustContent(pointX: Int) {
        scrollView.setContentOffset(CGPoint(x: pointX, y: 0), animated: true)
    }
}

extension BaseTableViewCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        baseTableViewCellDelegate?.scrollViewDidEndScroll(x: scrollView.contentOffset.x)
    }
}
