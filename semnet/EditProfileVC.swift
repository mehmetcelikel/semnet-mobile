//
//  EditProfileVC.swift
//  semnet
//
//  Created by ceyda on 03/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var firstnameLabel: UITextField!
    @IBOutlet weak var lastnameLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var phoneLabel: UITextField!
    @IBOutlet weak var genderLabel: UITextField!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    var genderPicker : UIPickerView!
    let genders = ["male","female"]
    
    var keyboard = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderLabel.inputView = genderPicker
        
        
        // check notifications of keyboard shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(EditProfileVC.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // tap to choose image
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(EditProfileVC.loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(avaTap)
        
        let userId = UserManager.sharedInstance.getUserId()
        
        UserManager.sharedInstance.getUser(userId: userId!) { (response) in
            if(response.0){
                self.firstnameLabel.text = response.1.firstname
                self.lastnameLabel.text = response.1.lastname
            }
        }
        
        UserManager.sharedInstance.downloadImage(userId: userId!){ (response) in
            if(response.0){
                self.profileImage.image = response.1
            }
        }

    }
    
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func updateButtonClick(_ sender: Any) {
        
        // if incorrect email according to regex
        if !validateEmail(emailLabel.text!) {
            alert("Incorrect email", message: "please provide correct email address")
            return
        }
        
        let userId = UserManager.sharedInstance.getUserId()
        let username = UserManager.sharedInstance.getUsername()
        
        let user = SemNetUser(id: userId!, username: username!, firstname: firstnameLabel.text!, lastname: lastnameLabel.text!, email: emailLabel.text!, phone: phoneLabel.text!)
        
        UserManager.sharedInstance.updateUser(user: user){ (response) in
            if(response){
                
                UserManager.sharedInstance.uploadUserImage(image: self.profileImage.image!){ (response) in
                    if(response){
                        self.view.endEditing(true)
                        self.dismiss(animated: true, completion: nil)
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                    }
                }
            }
        }
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollview.contentSize.height = self.view.frame.size.height - self.keyboard.height
        })
    }
    
    
    
    func keyboardWillHide(_ notification: Notification) {
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollview.contentSize.height = 0
        })
    }
    
    func validateEmail (_ email : String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func alert (_ error: String, message : String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func loadImg (_ recognizer : UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profileImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // picker text numb
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    // picker text config
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderLabel.text = genders[row]
        self.view.endEditing(true)
    }

}
