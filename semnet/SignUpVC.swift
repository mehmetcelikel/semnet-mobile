//
//  SignUpVC.swift
//  semnet
//
//  Created by ceyda on 27/11/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit
import Alamofire

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var avatarImg: UIImageView!
    
    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var repeatPasswordTxtField: UITextField!
    @IBOutlet weak var firstnameTxtField: UITextField!
    @IBOutlet weak var lastnameTxtField: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var scrollviewHeight : CGFloat = 0
    var keyboard = CGRect()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollviewHeight = scrollView.frame.size.height
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(showKeyboard), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(hideKeyboard), name: .UIKeyboardWillHide, object: nil)
        
        let hideTap = UITapGestureRecognizer(target: self, action:#selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        avatarImg.layer.cornerRadius = avatarImg.frame.size.width / 2
        avatarImg.clipsToBounds = true
        
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        avatarTap.numberOfTapsRequired = 1
        avatarImg.isUserInteractionEnabled = true
        avatarImg.addGestureRecognizer(avatarTap)
    }
    
    func loadImg(recognizer:UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // connect selected image to  ImageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        avatarImg.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func hideKeyboardTap(recognizer: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    func showKeyboard(notification: NSNotification){
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        UIView.animate(withDuration: 0.4, animations: {
            self.scrollView.frame.size.height = self.scrollviewHeight - self.keyboard.height
        })
    }
    
    func hideKeyboard(notification: NSNotification){
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        UIView.animate(withDuration: 0.4, animations: {
            self.scrollView.frame.size.height = self.view.frame.height
        })
    }

    @IBAction func signUpBtn_click(_ sender: Any) {
        if (usernameTxtField.text!.isEmpty || passwordTxtField.text!.isEmpty || repeatPasswordTxtField.text!.isEmpty || firstnameTxtField.text!.isEmpty || lastnameTxtField.text!.isEmpty) {
            
            presentAlert(alertMessage: "please fill required fields")
            return
        }

        if passwordTxtField.text != repeatPasswordTxtField.text {
            presentAlert(alertMessage: "passwords do not match")
            return
        }
        
        var user = SemNetUser(id: "", username: usernameTxtField.text!, firstname: firstnameTxtField.text!, lastname: lastnameTxtField.text!)
        user.password = passwordTxtField.text!
        
        UserManager.sharedInstance.createUser(user: user){ (response) in
            if(response){
                
                UserManager.sharedInstance.uploadUserImage(image: self.avatarImg.image){ (response) in
                    if(response){
                        
                        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.login()
                    }
                }
            }
        }
    }
    
    @IBAction func cancelBtn_click(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func presentAlert(alertMessage : String){
        let alert = UIAlertController(title: "Warning", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
