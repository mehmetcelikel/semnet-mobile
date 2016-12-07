//
//  NewPostVC.swift
//  semnet
//
//  Created by ceyda on 08/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class NewPostVC: UIViewController, UITextViewDelegate{

    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var postButton: UIButton!
    
    var placeholderLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.postTextView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth - 100)
        self.previewImageView.frame = CGRect(x:10, y:self.postTextView.frame.maxY, width: screenWidth-20, height: screenHeight-screenWidth-20)
        self.postButton.frame = CGRect(x:0, y:screenHeight-80, width: screenWidth, height: 20)
        
        postTextView.layer.borderWidth = 1.0
        postTextView.layer.borderColor = UIColor.lightGray.cgColor
        postTextView.delegate = self
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "Type or say something"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (postTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        postTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (postTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.isHidden = !postTextView.text.isEmpty
        
        previewImageView.image = UIImage(named: "pp.jpg.gif")!
    }

    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

}
