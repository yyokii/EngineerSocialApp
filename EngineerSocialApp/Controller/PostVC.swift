//
//  PostVC.swift
//  EngineerSocialApp
//
//  Created by Yoki on 2017/12/24.
//

import UIKit

class PostVC: UIViewController, UIPopoverPresentationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapModalPresentationStyle(_ sender: UIButton) {
        
        //let contentVC = PopOverContentViewController()
        let storyBoard = UIStoryboard(name: "PopOver", bundle: nil)
        let contentVC = storyBoard.instantiateInitialViewController() as! PopOverContentViewController
        contentVC.modalPresentationStyle = .popover
        contentVC.preferredContentSize = CGSize(width: 300, height: 300)
        //sourceViewは表示するviewを指定して、sourceRectはそのviewの中のどこからにゅにゅっと表示するかを指定する
        contentVC.popoverPresentationController?.sourceView = view
        contentVC.popoverPresentationController?.sourceRect = sender.frame
        contentVC.popoverPresentationController?.permittedArrowDirections = .any
        contentVC.popoverPresentationController?.delegate = self
        present(contentVC, animated: true, completion: nil)
    }
    
    /// Popover appears on iPhone
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}
