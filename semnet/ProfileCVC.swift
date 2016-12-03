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
    var contentImageArr = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileCVC.reload), name: NSNotification.Name(rawValue: "reload"), object: nil)
    }

    func refresh() {
        loadContentList()
        refresher.endRefreshing()
    }
    
    // reloading func after received notification
    func reload(_ notification:Notification) {
        collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentImageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProfileCVCCell
        
        cell.image.image = contentImageArr[indexPath.row]
        
        return cell
    }
    
    // header config
    override func collectionView(_ collectionView: UICollectionView,
                                  viewForSupplementaryElementOfKind kind: String,
                                  at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath as IndexPath) as! ProfileHeaderVC
        
        header.parentVC = self
        
        UserManager.sharedInstance.getUser(userId: userId) { (response) in
            if(response.0){
                self.user = response.1
                self.navigationItem.title = self.user.username.uppercased();
                header.nameLabel.text = self.user.firstname + " " + response.1.lastname
            }else{
                self.returnToLogin()
            }
        }
        let token = UserManager.sharedInstance.getToken()
        
        UserManager.sharedInstance.loadFriendlist(token: token) { (response) in
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
        
        loadContentList();
        
        let currenctUserId : String? = UserManager.sharedInstance.getUserId()
        if currenctUserId == userId {
            
            let customColor = UIColor(red: 72.0 / 255.0, green: 61.0 / 255.0, blue: 139.0 / 255.0, alpha: 0.5)
            
            header.editButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            header.editButton.backgroundColor = customColor
            header.editButton.setTitle("Edit", for: .normal)
            
            self.navigationItem.title = UserManager.sharedInstance.getUsername().uppercased();
        }else{
            var found=false;
            for object in UserManager.sharedInstance.myFriendArray {
                if(userId == object.id) {
                    found = true;
                    break;
                }
            }
            
            if(found == false){
                header.friend = false
                header.editButton.setTitle("Add Friend", for: UIControlState())
                header.editButton.setTitleColor(UIColor.black, for: UIControlState())
                header.editButton.backgroundColor = UIColor.gray
            }else{
                header.friend = true
                header.editButton.setTitle("Remove Friend", for: UIControlState())
                header.editButton.setTitleColor(UIColor.black, for: UIControlState())
                header.editButton.backgroundColor = UIColor.green
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
    
    func loadContentList(){
        ContentManager.sharedInstance.loadContentlist(userId: userId){ (response) in
            if(response.0){
                self.contentArr = response.1
                
                ContentManager.sharedInstance.fetchContents(contentArr: self.contentArr){ (response) in
                    if(response.0){
                        self.contentImageArr = response.1
                    }else{
                        self.returnToLogin()
                    }
                }
            }else{
                self.returnToLogin()
            }
        }
    }

    func postTap() {
        if !contentImageArr.isEmpty {
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
