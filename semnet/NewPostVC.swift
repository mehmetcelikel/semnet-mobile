//
//  NewPostVC.swift
//  semnet
//
//  Created by ceyda on 09/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class NewPostVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {


    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var tagTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    var placeholderLabelTag : UILabel!
    var tagTableView: UITableView!
    
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
        
        tagTableView = UITableView()
        tagTableView!.delegate = self
        tagTableView!.dataSource = self
        tagTableView!.isScrollEnabled = true
        tagTableView!.isHidden = true
        tagTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabelTag.isHidden = !textView.text.isEmpty
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let autoCompleteRowIdentifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: autoCompleteRowIdentifier) as UITableViewCell!
        
        if let tempo1 = cell {
            let index = indexPath.row as Int
            cell!.textLabel!.text = autocompleteCountries[index]
        }
            
        else {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: autoCompleteRowIdentifier)
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRow(at: indexPath as IndexPath)!
        contentTextView.text = selectedCell.textLabel!.text
        tagTableView.isHidden = true
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteCountries.count
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("text field has changed")
        tagTableView!.isHidden = false
        
        let substring = (tagTextView.text as NSString).replacingCharacters(in: range, with: text)
        print(substring)
        searchAutocompleteEntriesWithSubstring(substring: substring)
        return true
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String) {
        autocompleteCountries.removeAll(keepingCapacity: false)
        print(substring)
        
        for curString in countries {
            //print(curString)
            let myString: NSString! = curString.lowercased() as NSString
            let substringRange: NSRange! = myString.range(of: substring.lowercased())
            if (substringRange.location == 0) {
                autocompleteCountries.append(curString)
            }
        }
        
        tagTableView!.reloadData()
    }
}
