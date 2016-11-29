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
        
        
        usernameTxtField.frame = CGRect(x: 10, y: 100, width: self.view.frame.size.width - 20, height: 30)
        passwordTxtField.frame = CGRect(x: 10, y: usernameTxtField.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        
        forgotBtn.frame = CGRect(x: 10, y: passwordTxtField.frame.origin.y+40, width: self.view.frame.size.width / 3, height: 20)
        
        signInBtn.frame = CGRect(x: 10, y: forgotBtn.frame.origin.y + 40, width: self.view.frame.size.width / 4, height: 30)
        signInBtn.layer.cornerRadius = signInBtn.frame.size.width / 20
        
        signUpBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 10, y: signInBtn.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        signUpBtn.layer.cornerRadius = signUpBtn.frame.size.width / 20
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)

    }
    
    @IBAction func signInBtn_click(_ sender: Any) {
        
        self.view.endEditing(true)
        
        UserManager.sharedInstance.login(user: self.usernameTxtField.text!, password: self.passwordTxtField.text!, onCompletion: { json in
            print(json)
            let code = json["errorCode"]
                
            if(code != "SNET_0"){
                self.presentAlert(alertMessage: "Username and password does not match")
                return
            }
            let authToken = String(describing: json["token"])
            let userId = String(describing: json["id"])

            UserDefaults.standard.set(authToken, forKey: "authToken")
            UserDefaults.standard.set(userId, forKey: "userId")
            
            UserDefaults.standard.synchronize()
            
            let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.login()
        })
    }
    
    func presentAlert(alertMessage : String){
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "Warning", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func forgotBtn_click(_ sender: Any) {
        print("forgot pressed")
    }
    
    func hideKeyboard(recognizer : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
