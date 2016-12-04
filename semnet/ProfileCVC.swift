//
//  ProfileCVC.swift
//  semnet
//
//  Created by ceyda on 30/11/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit
import Alamofire

var profileUserId = [String]()

class ProfileCVC: UICollectionViewController {

    var refresher : UIRefreshControl!
    
    var userId:String!
    var user: SemNetUser!
    
    var friendArray = [SemNetUser]()
    var contentArr = [Content]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        collectionView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        collectionView?.backgroundColor = .white
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ProfileCVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        self.collectionView?.alwaysBounceVertical = true
        
        if profileUserId.last == nil {
            userId = UserManager.sharedInstance.getUserId()
        }else{
            userId = profileUserId.last
        }
        
        ContentManager.sharedInstance.loadContentlist(userId: userId){ (response) in
            if(response.0){
                self.contentArr = response.1
                self.collectionView?.reloadData()
            }else{
                self.returnToLogin()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileCVC.reload(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileCVC.uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
    }

    func refresh() {
        ContentManager.sharedInstance.loadContentlist(userId: userId){ (response) in
            if(response.0){
                self.contentArr = response.1
                self.collectionView?.reloadData()
            }else{
                self.returnToLogin()
            }
        }
        refresher.endRefreshing()
    }
    
    // reloading func after received notification
    func reload(_ notification:Notification) {
        collectionView?.reloadData()
    }
    
    // reloading func after received notification
    func uploaded(_ notification:Notification) {
        ContentManager.sharedInstance.loadContentlist(userId: userId){ (response) in
            if(response.0){
                self.contentArr = response.1
                self.collectionView?.reloadData()
            }else{
                self.returnToLogin()
            }
        }
        collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 4, height: self.view.frame.size.width / 4)
        return size
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProfileCVCCell
        
        ContentManager.sharedInstance.downloadContent(contentId: contentArr[indexPath.row].id){ (response) in
            if(response.0){
                print("content has been downloaded")
                cell.image.image = response.1
            }else{
                print("error occured")
            }
        }
        
        return cell
    }
    
    // header config
    override func collectionView(_ collectionView: UICollectionView,
                                  viewForSupplementaryElementOfKind kind: String,
                                  at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath as IndexPath) as! ProfileHeaderVC
        
        header.parentVC = self
        header.postsLabel.text = String(self.contentArr.count)
        
        UserManager.sharedInstance.getUser(userId: userId) { (response) in
            if(response.0){
                self.user = response.1
                header.nameLabel.text = self.user.firstname + " " + self.user.lastname
                self.navigationItem.title = self.user.username.uppercased();
            }else{
                self.returnToLogin()
            }
        }
        
        FriendManager.sharedInstance.loadFriendlist(userId: userId) { (response) in
            if(response.0){
                self.friendArray = response.1
                header.friendsLabel.text = String(self.friendArray.count)
            }else{
                self.returnToLogin()
            }
        }

        UserManager.sharedInstance.downloadImage(userId: userId){ (response) in
            if(response.0){
                header.profileImage.image = response.1
            }else{
                self.returnToLogin()
            }
        }

        let currenctUserId : String? = UserManager.sharedInstance.getUserId()
        if currenctUserId == userId {
            
            header.editButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            header.editButton.backgroundColor = UIColor.white
            header.editButton.setTitle("Edit", for: .normal)
            header.editButton.layer.borderWidth = 1.0
            header.editButton.layer.borderColor = UIColor.lightGray.cgColor
            header.editButton.layer.cornerRadius = 4
            header.editButton.layer.masksToBounds = true
            
            self.navigationItem.title = UserManager.sharedInstance.getUsername().uppercased();
        }else{
            let found = FriendManager.sharedInstance.isMyFriend(userId: userId)
            
            if(found == false){
                let customColor = UIColor(red: 72.0 / 255.0, green: 61.0 / 255.0, blue: 139.0 / 255.0, alpha: 0.5)
                
                header.friend = false
                header.editButton.setTitle("Add Friend", for: UIControlState())
                header.editButton.setTitleColor(UIColor.white, for: UIControlState())
                header.editButton.backgroundColor = customColor
                header.editButton.layer.borderWidth = 1.0
                header.editButton.layer.borderColor = UIColor.lightGray.cgColor
                header.editButton.layer.cornerRadius = 8
                header.editButton.layer.masksToBounds = true
            }else{
                header.friend = true
                header.editButton.setTitle("Remove Friend", for: UIControlState())
                header.editButton.setTitleColor(UIColor.black, for: UIControlState())
                header.editButton.backgroundColor = UIColor.white
                header.editButton.layer.borderWidth = 1.0
                header.editButton.layer.borderColor = UIColor.lightGray.cgColor
                header.editButton.layer.cornerRadius = 8
                header.editButton.layer.masksToBounds = true
            }
        }
        
        // tap friends
        let friendsTap = UITapGestureRecognizer(target: self, action: #selector(ProfileCVC.friendsTap))
        friendsTap.numberOfTapsRequired = 1
        header.friendsLabel.isUserInteractionEnabled = true
        header.friendsLabel.addGestureRecognizer(friendsTap)
        
        // tap posts
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(ProfileCVC.postTap))
        postsTap.numberOfTapsRequired = 1
        header.postsLabel.isUserInteractionEnabled = true
        header.postsLabel.addGestureRecognizer(postsTap)
        
        
        return header
    }

    func postTap() {
        if !contentArr.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    func friendsTap() {
        userToListFriend = user.id
        friendArrayToBelListed = friendArray
        
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FriendsTVC") as! FriendsTVC
        
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    func presentAlert(alertMessage : String){
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "Warning", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func returnToLogin() {
        UserManager.sharedInstance.clearUserInfo()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.present(vc, animated: true, completion: nil)
    }
}
