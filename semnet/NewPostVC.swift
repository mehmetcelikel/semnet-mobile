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
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var placeholderLabelTag : UILabel!
    
    var selectedTags = [SemanticLabel]()
    
    var autocompleteLabels = [SemanticLabel]()
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
        hideTap.cancelsTouchesInView = false
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.down
        backSwipe.cancelsTouchesInView = false
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
            
            let label = autocompleteLabels[index]
            cell!.textLabel!.text = getTagLabel(label: label)
        }
            
        else {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: autoCompleteRowIdentifier)
        }
        
        return cell!
    }
    
    func getTagLabel(label: SemanticLabel)->String{
        return label.label + "(" + label.clazz + ")"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedTags.append(autocompleteLabels[indexPath.row])
        
        var text = ""
        for object in selectedTags {
            text += getTagLabel(label: object) + ","
        }
        
        tagTextView.text = text
        autoCompleteTableView.isHidden = true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteLabels.count
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        autocompleteLabels.removeAll(keepingCapacity: false)
        
        let substring = (tagTextView.text as NSString).replacingCharacters(in: range, with: text)
        searchAutocompleteEntriesWithSubstring(str: substring)
        return true
    }
    
    func searchAutocompleteEntriesWithSubstring(str: String) {
        
        let substringArr = str.characters.split{$0 == ","}.map(String.init)
        
        var substring = str
        if(substringArr.count>=1){
            substring = substringArr[substringArr.count-1]
        }
        
        autocompleteLabels.removeAll(keepingCapacity: false)
        
        SearchManager.sharedInstance.getLabels(queryString: substring){ (response) in
            if(response.0){
                self.autocompleteLabels = response.1
                
                if(self.autocompleteLabels.count == 0){
                    self.autoCompleteTableView.isHidden = true
                }else{
                    
                    self.autoCompleteTableView!.isHidden = false
                    self.autoCompleteTableView!.reloadData()
                }
                
            }else{
                self.autoCompleteTableView.isHidden = true
            }
        }
        
    }
    
    @IBAction func postButtonClick(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let hasImage = self.image != nil
        ContentManager.sharedInstance.createContent(description: contentTextView.text!, hasImage: hasImage){ (response) in
            if(response.0){
                print("Content has been created")
                
                if(hasImage){
                    
                    ContentManager.sharedInstance.uploadContent(image: self.imageView.image, contentId: response.1){ (response) in
                        if(response){
                            print("Content has been uploaded")
                            
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }else{
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                    
                    self.dismiss(animated: true, completion: nil)
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
