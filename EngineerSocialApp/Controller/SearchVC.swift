//
//  SearchVC.swift
//  EngineerSocialApp
//
//  Created by Yoki Higashihara on 2018/02/06.
//

import UIKit

class SearchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func searchVC(_ sender: Any) {
        performSegue(withIdentifier: "toPost", sender: nil)
    }
}
