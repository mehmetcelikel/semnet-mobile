//
//  PostVC.swift
//  semnet
//
//  Created by ceyda on 04/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class PostVC: UIViewController {

    var image:UIImage!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(PostVC.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        self.imageView.image = image
    }

    @IBAction func postButtonClick(_ sender: Any) {
        self.view.endEditing(true)
        
        ContentManager.sharedInstance.createContent(description: descriptionTextView.text!){ (response) in
            if(response.0){
                print("Content has been created")
                ContentManager.sharedInstance.uploadContent(image: self.imageView.image, contentId: response.1){ (response) in
                    if(response){
                        print("Content has been uploaded")
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }

    func hideKeyboard() {
        self.view.endEditing(true)
    }
}
