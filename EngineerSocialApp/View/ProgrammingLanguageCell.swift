//
//  ProgrammingLanguageCell.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2018/01/02.
//

import UIKit

class ProgrammingLanguageCell: UICollectionViewCell {
    
    @IBOutlet weak var languageNameLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 5.0
    }
    
    
    func  configureCell (languageName: String){
        
        languageNameLabel.text = languageName
    }
    
}
