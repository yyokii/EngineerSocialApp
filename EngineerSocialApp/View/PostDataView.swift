//
//  PostDataView.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2017/12/30.
//

import UIKit

class PostDataView: UIView {
    
    @IBOutlet weak var baseView: UIView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    
    func loadNib(){
        let view = Bundle.main.loadNibNamed("PostData", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
}
