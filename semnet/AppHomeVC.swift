//
//  AppHomeVC.swift
//  semnet
//
//  Created by ceyda on 06/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class AppHomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var action:String!
    var selectedTag:SemanticLabel!
    
    var contentArr = [Content]()
    
    var refresher : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: (screenHeight-tabBarHeight-CGFloat(100)))
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(uploaded(_:)), name: NSNotification.Name(rawValue: "friendAction"), object: nil)
    }
    
    func returnToLogin() {
        UserManager.sharedInstance.clearUserInfo()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.present(vc, animated: true, completion: nil)
    }

    func uploaded(_ notification:Notification) {
        loadData()
    }
    
    func loadData() {
        refresher.beginRefreshing()
        
        if(action == "SemanticSearch"){
            SearchManager.sharedInstance.searchContent(param: selectedTag!){ (response) in
                if(response.0){
                    self.contentArr = response.1
                    
                    self.refresher.endRefreshing()
                    self.tableView?.reloadData()
                }else{
                    self.returnToLogin()
                }
            }
            return;
        }
        
        loadContents()
        
        return
    }
    
    func loadContents(){
        let userId = UserManager.sharedInstance.getUserId()
        ContentManager.sharedInstance.loadContentlist(userId: userId!, type: action){ (response)in
            if(response.0){
                self.contentArr = response.1
                
                self.refresher.endRefreshing()
                self.tableView?.reloadData()
            }else{
                self.returnToLogin()
            }
        }
    }
}

extension AppHomeVC:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AppHomeTVCell
        
        cell.parentVC = self
        
        let content = contentArr[indexPath.item]
        
        
        var distance = ""
        if(content.distance != nil && action == "LOCATION"){
            distance = " (" + String(content.distance) + " meters)"
        }
        cell.usernameLbl.attributedText = formatText(boldText: "@" + content.ownerName, normalText: distance)
        cell.descriptionLbl.attributedText = formatTagText(normalText: content.description, tagList: content.tagList)
        cell.dateLbl.text = content.dateDiff
        cell.content = content
        cell.likeCount.text = String(content.likeCount)
        cell.liked = ContentManager.sharedInstance.didILike(content: content)
        
        cell.setLikeButtonBackground(likeAction: cell.liked)
        
        if(content.hasImage){
            
            let activityIndicator = createActivityIndicator(point: cell.contentImage.center)
            cell.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
            
            ContentManager.sharedInstance.downloadContent(contentId: content.id){ (response) in
                if(response.0){
                    print("content has been downloaded")
                    cell.contentImage.image = response.1
                }else{
                    self.returnToLogin()
                }
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }else{
            cell.contentImageHeightConstraint.constant = 0
        }
        
        cell.profileImage.layer.cornerRadius = 4
        cell.profileImage.layer.masksToBounds = true
        
        UserManager.sharedInstance.downloadImage(userId: content.ownerId){ (response) in
            if(response.0){
                print("profile image has been loaded")
                cell.profileImage.image = response.1
            }else{
                self.returnToLogin()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
}
