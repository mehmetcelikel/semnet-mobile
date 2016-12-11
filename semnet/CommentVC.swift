//
//  CommentVC.swift
//  semnet
//
//  Created by ceyda on 11/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

var commentContentArr = [Content]()

class CommentVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var commentTableview: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    let maxAnswerLength = 160
    
    var refresher = UIRefreshControl()
    
    var tableViewHeight : CGFloat = 0
    var commentY : CGFloat = 0
    var commentHeight : CGFloat = 0
    
    var keyboard = CGRect()
    var commentArr = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "COMMENTS"

        commentTableview.layoutMargins = UIEdgeInsets.zero
        commentTableview.separatorInset = UIEdgeInsets.zero
        
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        sendButton.isEnabled = false
        
        alignment()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true
        
        commentTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    

    // while writing something
    func textViewDidChange(_ textView: UITextView) {
        
        // disable button if entered no text
        let spacing = CharacterSet.whitespacesAndNewlines
        if !commentTextView.text.trimmingCharacters(in: spacing).isEmpty {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
        
        // + paragraph
        if commentTextView.contentSize.height > textView.frame.size.height && textView.frame.height < 130 {
            
            // find difference to add
            let difference = textView.contentSize.height - textView.frame.size.height
            
            // redefine frame of commentTxt
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            // move up tableView
            if textView.contentSize.height + keyboard.height + commentY >= commentTableview.frame.size.height {
                commentTableview.frame.size.height = commentTableview.frame.size.height - difference
            }
        }
            
            // - paragraph
        else if textView.contentSize.height < textView.frame.size.height {
            
            
            let difference = textView.frame.size.height - textView.contentSize.height
            
            
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            
            if textView.contentSize.height + keyboard.height + commentY > commentTableview.frame.size.height {
                commentTableview.frame.size.height = commentTableview.frame.size.height + difference
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //If the text is larger than the maxtext, the return is false
        let result = (textView.text.characters.count) + text.characters.count - range.length
        return result <= maxAnswerLength
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArr.count
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommentTVCell
        
        cell.layoutMargins = UIEdgeInsets.zero

        let comment = commentArr[indexPath.row]
        
        cell.usernameButton.setTitle(comment.ownerName, for: UIControlState())
        cell.usernameButton.sizeToFit()
    
        cell.commentLabel.text = comment.comment
        
        UserManager.sharedInstance.downloadImage(userId: comment.ownerId){ (response) in
            if(response.0){
                print("profile image has been loaded")
                cell.userImageView.image = response.1
            }
        }
        cell.dateLabel.text = comment.date
        cell.usernameButton.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    // cell editabil
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // swipe cell for actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cell = tableView.cellForRow(at: indexPath) as! CommentTVCell
        
        // 1. Delete
        let delete = UITableViewRowAction(style: .normal, title: "    ") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            let comment = self.commentArr[indexPath.item]
            let content = commentContentArr.last
            
            // 1. Delete comment from server
            ContentManager.sharedInstance.deleteComment(contentId: (content?.id)!, commentId: comment.id){ (response) in
                if(response){
                    
                    // close cell
                    tableView.setEditing(false, animated: true)
                    
                    // 3. Delete comment row from tableView
                    self.commentArr.remove(at: indexPath.row)
                    
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
        
        delete.backgroundColor = UIColor(patternImage: UIImage(named: "delete.png")!)
        
        // comment belongs to user
        if cell.usernameButton.titleLabel?.text == UserManager.sharedInstance.getUsername() {
            return [delete]
        }
            
            // post belongs to user
        else if commentArr.last?.ownerId == UserManager.sharedInstance.getUserId() {
            return [delete]
        }
        
        return []
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        
        let desc = commentTextView.text as String
            
        ContentManager.sharedInstance.createComment(contentId: (commentContentArr.last?.id)!, comment: desc){ (response) in
            if(response.0){
                let commentId = response.1
                let ownerId = UserManager.sharedInstance.getUserId()
                let ownerName = UserManager.sharedInstance.getUsername()
                
                let comment = Comment(id: commentId, comment: desc, ownerId: ownerId!, ownerName: ownerName!, date: 1)
                self.commentArr.append(comment)
                
                self.commentTableview?.reloadData()
                
                // scroll to bottom
                self.commentTableview.scrollToRow(at: IndexPath(item: self.commentArr.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
                
                //   Reset UI
                self.sendButton.isEnabled = false
                self.commentTextView.text = ""
                self.commentTextView.frame.size.height = self.commentHeight
                self.commentTextView.frame.origin.y = self.sendButton.frame.origin.y
                self.commentTableview.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTextView.frame.size.height + self.commentHeight
            }
        }
    }
    
    
    func alert (_ title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func keyboardWillShow(_ notification : Notification) {
        
        // defnine keyboard frame size
        keyboard = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        // move UI up
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.commentTableview.frame.size.height = self.tableViewHeight - keyboardHeight - self.commentTextView.frame.size.height + self.commentHeight
            self.commentTextView.frame.origin.y = self.commentY - keyboardHeight - self.commentTextView.frame.size.height + self.commentHeight
            self.sendButton.frame.origin.y = self.commentTextView.frame.origin.y
        })
    }
    
    func keyboardWillHide(_ notification : Notification) {
        
        // move UI down
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.commentTableview.frame.size.height = self.tableViewHeight
            self.commentTextView.frame.origin.y = self.commentY
            self.sendButton.frame.origin.y = self.commentY
        })
    }
    
    func back(_ sender : UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
        
        
        if !commentContentArr.isEmpty {
            commentContentArr.removeLast()
        }
    }
    
    func alignment() {
        
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        
        //568/518=1.096
        commentTableview.frame = CGRect(x: 0, y: 0, width: width, height: height / 1.096 - self.navigationController!.navigationBar.frame.size.height - 20)
        
        //320/60=5.333
        commentTableview.estimatedRowHeight = width / 5.333
        commentTableview.rowHeight = UITableViewAutomaticDimension
        
        //568/56.8=10 gap ve 320/1.306=245 text view width
        commentTextView.frame = CGRect(x: 10, y: screenHeight-40, width: width / 1.306, height: 33)
        commentTextView.layer.cornerRadius = commentTextView.frame.size.width / 50
        
        //320/32=10 gap
        sendButton.frame = CGRect(x: commentTextView.frame.origin.x + commentTextView.frame.size.width + width / 32, y: commentTextView.frame.origin.y, width: width - (commentTextView.frame.origin.x + commentTextView.frame.size.width) - (width / 32) * 2, height: commentTextView.frame.size.height)
        
        
        
        commentTextView.delegate = self
        commentTableview.delegate = self
        commentTableview.dataSource = self
        
        
        
        tableViewHeight = commentTableview.frame.size.height
        commentHeight = commentTextView.frame.size.height
        commentY = commentTextView.frame.origin.y
    }
    
    func loadData() {
        
        ContentManager.sharedInstance.loadCommentlist(contentId: (commentContentArr.last?.id)!){ (response) in
            if(response.0){
                self.commentArr = response.1
                self.commentTableview?.reloadData()
            }
        }
        refresher.endRefreshing()
    }
}
