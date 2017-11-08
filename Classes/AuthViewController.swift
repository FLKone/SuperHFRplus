//
//  AuthViewController.swift
//  SuperHFRplus
//
//  Created by FLK on 08/11/2017.
//

import UIKit

class AuthViewController: IdentificationViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction override func connexion()  {
        print("connexion")
        super.connexion()
    }

}
