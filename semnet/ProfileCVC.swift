//
//  ProfileCVC.swift
//  semnet
//
//  Created by ceyda on 30/11/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit
import Alamofire

class ProfileCVC: UICollectionViewController {

    var refresher : UIRefreshControl!
    
    var userId:String!
    var firstname:String!
    var lastname:String!
    var username:String!
    var friendCount = 0
    var contentIdArr = [String]()
    var contentImageArr = [UIImage]()
    
    var profileImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        collectionView?.backgroundColor = .white
        
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ProfileCVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        self.collectionView?.alwaysBounceVertical = true
        
    }

    func refresh() {
        loadContentlist()
        refresher.endRefreshing()
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
        
        let currenctUserId : String? = UserManager.sharedInstance.getUserId()
        if userId == nil {
           userId = currenctUserId
        }
        
        loadUserDetail(completionHandler:{(UIBackgroundFetchResult) -> Void in
            header.nameLabel.text = self.firstname! + " " + self.lastname!
        })
        
        loadFriendlist(completionHandler:{(UIBackgroundFetchResult) -> Void in
            header.friendsLabel.text = String(self.friendCount)
        })

        downloadProfileImage(completionHandler:{(UIBackgroundFetchResult) -> Void in
            header.profileImage.image = self.profileImage
        })
        
        loadContentlist()
        
        if currenctUserId == userId {
            
            let customColor = UIColor(red: 72.0 / 255.0, green: 61.0 / 255.0, blue: 139.0 / 255.0, alpha: 0.5)
            
            header.editButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            header.editButton.backgroundColor = customColor
            header.editButton.setTitle("Edit", for: .normal)
            
            self.navigationItem.title = UserManager.sharedInstance.getUsername().uppercased();
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
    
    func loadUserDetail(completionHandler: ((UIBackgroundFetchResult)     -> Void)!) {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken,
            "id": userId!
        ]
        
        Alamofire.request(userGetEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    self.returnToLogin()
                    return
                }
                print(json)
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    self.returnToLogin()
                    return
                }
                
                self.firstname = json["firstname"] as! String?
                self.lastname = json["lastname"] as! String?
                self.username = json["username"] as! String?
                
                self.navigationItem.title = self.username.uppercased();
                
                completionHandler(UIBackgroundFetchResult.newData)
        }
    }
    
    func loadFriendlist(completionHandler: ((UIBackgroundFetchResult)     -> Void)!) {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken
        ]
        
        Alamofire.request(friendListEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    return
                }
                print(json)
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    self.returnToLogin()
                    return
                }
                
                guard let friendList = json["userList"] as? NSArray else {
                    return
                }
                
                if friendList.count == 0 {
                    return
                }
                self.friendCount = friendList.count
                
                for anItem in friendList as! [Dictionary<String, AnyObject>] {
                    let personName = anItem["username"] as! String
                    let personID = anItem["id"] as! Int
                
                    print(personName)
                    print(personID)
                }
                completionHandler(UIBackgroundFetchResult.newData)
        }
    }
    
    func loadContentlist() {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken,
            "userId": userId,
            "type": "SPECIFIED"
        ]
        
        Alamofire.request(contentListEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    return
                }
                print(json)
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    self.returnToLogin()
                    return
                }
                
                guard let contentList = json["contentList"] as? NSArray else {
                    return
                }
                
                if contentList.count == 0 {
                    return
                }
                
                for anItem in contentList as! [Dictionary<String, AnyObject>] {
                    let contentId = anItem["id"] as! String
                    self.contentIdArr.append(contentId)
                    self.getContent(contentId: contentId, completionHandler:{(UIBackgroundFetchResult) -> Void in
                    })
                }
    
        }
    }
    
    func downloadProfileImage(completionHandler: ((UIBackgroundFetchResult)     -> Void)!){
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken,
            "userId": userId
        ]
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask, true)[0]
            let documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: true)
            let fileURL = documentsURL.appendingPathComponent("image.png")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories]) }
        
            Alamofire.download(userImageDownloadEndpoint, parameters: parameters, to: destination)
            .responseData { resp in
                guard let data = resp.result.value else {
                    return
                }
                self.profileImage = UIImage(data: data)
                
                completionHandler(UIBackgroundFetchResult.newData)
        }
    }
    
    func getContent(contentId:String, completionHandler: ((UIBackgroundFetchResult)     -> Void)!){
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken,
            "contentId": contentId
        ]
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask, true)[0]
            let documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: true)
            let fileURL = documentsURL.appendingPathComponent("content.jpg")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories]) }
        
        Alamofire.download(contentDownloadEndpoint, parameters: parameters, to: destination)
            .responseData { resp in
                guard let data = resp.result.value else {
                    return
                }
                self.contentImageArr.append(UIImage(data: data)!)
                
                completionHandler(UIBackgroundFetchResult.newData)
        }
    }

    func postTap() {
        if !contentImageArr.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    func friendsTap() {
        userToListFriend = username!
        
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
