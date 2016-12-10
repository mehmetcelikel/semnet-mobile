//
//  NewPostVC.swift
//  semnet
//
//  Created by ceyda on 09/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class NewPostVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    var image:UIImage!
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var tagTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var autoCompleteTableView: UITableView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var placeholderLabelTag : UILabel!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    var autocompleteCountries = [String]()
    let countries = NSLocale.isoCountryCodes.map { (code:String) -> String in
        let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
        return NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        tagTextView.layer.borderWidth = 1.0
        tagTextView.layer.borderColor = UIColor.lightGray.cgColor
        tagTextView.delegate = self
        
        placeholderLabelTag = UILabel()
        placeholderLabelTag.text = "Tag"
        placeholderLabelTag.font = UIFont.italicSystemFont(ofSize: (tagTextView.font?.pointSize)!)
        placeholderLabelTag.sizeToFit()
        tagTextView.addSubview(placeholderLabelTag)
        placeholderLabelTag.frame.origin = CGPoint(x: 5, y: (tagTextView.font?.pointSize)! / 2)
        placeholderLabelTag.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabelTag.isHidden = !tagTextView.text.isEmpty
        
        autoCompleteTableView.delegate = self
        autoCompleteTableView.dataSource = self
        autoCompleteTableView.isHidden=true
        autoCompleteTableView.layer.borderWidth = 1.0
        autoCompleteTableView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.view.addSubview(autoCompleteTableView)
        
        if(self.image == nil){
            imageViewHeightConstraint.constant = 0
        }else{
            imageView.image = image
        }
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(backSwipe)
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabelTag.isHidden = !textView.text.isEmpty
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 15
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let autoCompleteRowIdentifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: autoCompleteRowIdentifier) as UITableViewCell!
        
        if cell != nil {
            let index = indexPath.row as Int
            cell!.textLabel!.font = UIFont.italicSystemFont(ofSize: 10)
            cell!.textLabel!.text = autocompleteCountries[index]
        }
            
        else {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: autoCompleteRowIdentifier)
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRow(at: indexPath as IndexPath)!
        tagTextView.text = selectedCell.textLabel!.text
        autoCompleteTableView.isHidden = true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteCountries.count
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        autoCompleteTableView!.isHidden = false
        
        let substring = (tagTextView.text as NSString).replacingCharacters(in: range, with: text)
        searchAutocompleteEntriesWithSubstring(substring: substring)
        return true
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String) {
        autocompleteCountries.removeAll(keepingCapacity: false)
        
        for curString in countries {
            //print(curString)
            let myString: NSString! = curString.lowercased() as NSString
            let substringRange: NSRange! = myString.range(of: substring.lowercased())
            if (substringRange.location == 0) {
                autocompleteCountries.append(curString)
            }
        }
        if(autocompleteCountries.count == 0){
            autoCompleteTableView.isHidden = true
        }
        autoCompleteTableView!.reloadData()
    }
    
    @IBAction func postButtonClick(_ sender: Any) {
        
        self.view.endEditing(true)
        
        ContentManager.sharedInstance.createContent(description: contentTextView.text!){ (response) in
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
    
    func back(_ gesture: UIGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
}
