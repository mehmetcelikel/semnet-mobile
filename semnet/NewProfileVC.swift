//
//  NewProfileVC.swift
//  semnet
//
//  Created by ceyda on 06/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

var profileUserId = [String]()

class NewProfileVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var refresher : UIRefreshControl!
    var activityIndicator: UIActivityIndicatorView!
    
    var userId:String!
    var user: SemNetUser!
    
    var friendArray = [SemNetUser]()
    var contentArr = [Content]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView?.alwaysBounceVertical = true
        
        if profileUserId.last == nil {
            userId = UserManager.sharedInstance.getUserId()
        }else{
            userId = profileUserId.last
        }
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(NewProfileVC.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        ContentManager.sharedInstance.loadContentlist(userId: userId, type: "SPECIFIED"){ (response) in
            if(response.0){
                print("contentList has been loaded")
                self.contentArr = response.1
                self.tableView.reloadData()
            }else{
                self.returnToLogin()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewProfileVC.reload(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewProfileVC.uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension NewProfileVC:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewProfileTVCell
        
        cell.usernameLbl.font = UIFont.boldSystemFont(ofSize: 12.0)
        cell.descriptionLbl.text = contentArr[indexPath.item].description
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 100, y: 100, width: 20, height: 20))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = cell.contentImage.center
        cell.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        ContentManager.sharedInstance.downloadContent(contentId: contentArr[indexPath.row].id){ (response) in
            if(response.0){
                print("content has been downloaded")
                cell.contentImage.image = response.1
                cell.usernameLbl.text = "@" + self.user.username
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
            }else{
                self.returnToLogin()
            }
        }
        
        /*if ( indexPath.row != 1){
            cell.contentHeightConstraint.constant = 0
        }*/
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }
     
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView()
     
        vw.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 100)
        vw.backgroundColor = UIColor.white
        vw.layer.borderWidth = 1.0
        vw.layer.borderColor = UIColor.lightGray.cgColor
     
        let profileImage = UIImageView()
        profileImage.frame = CGRect(x: 10, y: 10, width: 80, height: 80)
        profileImage.layer.cornerRadius = 4
        profileImage.layer.masksToBounds = true
        
        UserManager.sharedInstance.downloadImage(userId: userId){ (response) in
            if(response.0){
                print("profile image has been loaded")
                profileImage.image = response.1
            }else{
                self.returnToLogin()
            }
        }
        
        vw.addSubview(profileImage)
        
        let fullname = UILabel(frame: CGRect(x: profileImage.frame.maxX + 10, y: 5, width: screenWidth/2, height: 20))
        
        fullname.textColor = UIColor.black
        fullname.font = UIFont(name: fullname.font.fontName, size: 12)
        fullname.textAlignment = NSTextAlignment.left
        fullname.contentMode = UIViewContentMode.scaleAspectFit
        
        vw.addSubview(fullname)
        
        let username = UILabel(frame: CGRect(x: profileImage.frame.maxX + 10, y: fullname.frame.maxY, width: screenWidth/2, height: 20))
        
        username.textColor = UIColor.black
        username.font = UIFont(name: username.font.fontName, size: 9)
        username.textAlignment = NSTextAlignment.left
        username.contentMode = UIViewContentMode.scaleAspectFit
        
        UserManager.sharedInstance.getUser(userId: userId) { (response) in
            if(response.0){
                print("getUser query has just run")
                self.user = response.1
                fullname.text = self.user.firstname + " " + self.user.lastname
                username.text = "@" + self.user.username
            }else{
                self.returnToLogin()
            }
        }
        
        vw.addSubview(username)
        
        let posts = UILabel(frame: CGRect(x: profileImage.frame.maxX + 10, y: profileImage.frame.maxY-20, width: 50, height: 20))
        
        posts.textColor = UIColor.black
        posts.font = UIFont(name: username.font.fontName, size: 10)
        posts.textAlignment = NSTextAlignment.left
        posts.contentMode = UIViewContentMode.scaleAspectFit
        posts.attributedText = self.formatText(boldText: String(self.contentArr.count), normalText: " Posts")
        
        vw.addSubview(posts)
        
        let friends = UILabel(frame: CGRect(x: posts.frame.maxX + 10, y: profileImage.frame.maxY-20, width: 50, height: 20))
        
        friends.textColor = UIColor.black
        friends.font = UIFont(name: username.font.fontName, size: 10)
        friends.textAlignment = NSTextAlignment.left
        friends.contentMode = UIViewContentMode.scaleAspectFit
        
        FriendManager.sharedInstance.loadFriendlist(userId: userId) { (response) in
            if(response.0){
                print("friendList query has just run")
                self.friendArray = response.1
                friends.attributedText = self.formatText(boldText: String(self.friendArray.count), normalText: " Friends")
            }else{
                self.returnToLogin()
            }
        }
        
        vw.addSubview(friends)
        
        let editButton = UIButton(frame: CGRect(x: screenWidth-70, y: 10, width: 60, height: 20))
        editButton.layer.borderWidth = 1.0
        editButton.layer.borderColor = UIColor.lightGray.cgColor
        editButton.layer.cornerRadius = 4
        editButton.layer.masksToBounds = true
        editButton.titleLabel?.font = UIFont(name: username.font.fontName, size: 12)
        editButton.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        
        let currenctUserId : String? = UserManager.sharedInstance.getUserId()
        if currenctUserId == userId {
            
            editButton.setTitle("Edit", for: .normal)
            editButton.tintColor = UIColor.purple
            editButton.setTitleColor(UIColor.black, for: .normal)
            editButton.backgroundColor = UIColor.white
            
        }else{
            let found = FriendManager.sharedInstance.isMyFriend(userId: userId)
            
            if(found == false){
                let customColor = UIColor(red: 72.0 / 255.0, green: 61.0 / 255.0, blue: 139.0 / 255.0, alpha: 0.5)
                
                editButton.setTitle("Add", for: UIControlState())
                editButton.setTitleColor(UIColor.white, for: UIControlState())
                editButton.backgroundColor = customColor
                
            }else{
                editButton.setTitle("Remove", for: UIControlState())
                editButton.setTitleColor(UIColor.black, for: UIControlState())
                editButton.backgroundColor = UIColor.white
            }
        }
        vw.addSubview(editButton)
        
        // tap friends
        let friendsTap = UITapGestureRecognizer(target: self, action: #selector(self.friendsTap))
        friendsTap.numberOfTapsRequired = 1
        friends.isUserInteractionEnabled = true
        friends.addGestureRecognizer(friendsTap)
        
        // tap posts
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(self.postTap))
        postsTap.numberOfTapsRequired = 1
        posts.isUserInteractionEnabled = true
        posts.addGestureRecognizer(postsTap)
        
        return vw
    }
    
    func formatText(boldText: String, normalText: String) -> NSMutableAttributedString{
        let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 12)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
        let normalString = NSMutableAttributedString(string:normalText)
        
        attributedString.append(normalString)
        
        return attributedString
    }
    
    func editAction(sender: UIButton!) {
        
        let currentUserId = UserManager.sharedInstance.getUserId()
        
        if currentUserId == userId {
            let storyboard = UIStoryboard(name: "Main", bundle:nil)
            let home = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! NavigationVC
            self.present(home, animated: true, completion: nil)
            
        } else {
            let friend = FriendManager.sharedInstance.isMyFriend(userId: userId)
            if(friend == true) {
                
                FriendManager.sharedInstance.removeFriend(userId: userId){ (response) in
                    if(response){
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                    }
                }
                
            }else{
                
                FriendManager.sharedInstance.addFriend(userId: userId){ (response) in
                    if(response){
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                    }
                }
            }
        }
    }
    
    func postTap() {
        if !contentArr.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.tableView.scrollToRow(at: index, at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    func friendsTap() {
        userToListFriend = user.id
        friendArrayToBelListed = friendArray
        
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FriendsTVC") as! FriendsTVC
        
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    func refresh() {
        ContentManager.sharedInstance.loadContentlist(userId: userId, type: "SPECIFIED"){ (response) in
            if(response.0){
                self.contentArr = response.1
                self.tableView?.reloadData()
            }else{
                self.returnToLogin()
            }
        }
        refresher.endRefreshing()
    }
    
    // reloading func after received notification
    func reload(_ notification:Notification) {
        tableView?.reloadData()
    }
    
    // reloading func after received notification
    func uploaded(_ notification:Notification) {
        ContentManager.sharedInstance.loadContentlist(userId: userId, type: "SPECIFIED"){ (response) in
            if(response.0){
                self.contentArr = response.1
                self.tableView.reloadData()
            }else{
                self.returnToLogin()
            }
        }
    }
    
    func returnToLogin() {
        UserManager.sharedInstance.clearUserInfo()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.present(vc, animated: true, completion: nil)
    }
}
