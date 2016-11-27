//
//  SignInVC.swift
//  semnet
//
//  Created by ceyda on 27/11/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {

    @IBOutlet weak var usernameTxtField: UITextField!
    
    
    @IBOutlet weak var passwordTxtField: UITextField!
    
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signInBtn_click(_ sender: Any) {
        print("sign in pressed")
    }
    
    @IBAction func forgotBtn_click(_ sender: Any) {
        print("forgot pressed")
    }
}
