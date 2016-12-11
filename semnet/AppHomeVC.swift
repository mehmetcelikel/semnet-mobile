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
    
    var contentArr = [Content]()
    
    var refresher : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let userId = UserManager.sharedInstance.getUserId()
        
        ContentManager.sharedInstance.loadContentlist(userId: userId!, type: "FRIEND"){ (response) in
            if(response.0){
                self.contentArr = response.1
                self.tableView?.reloadData()
            }else{
                self.returnToLogin()
            }
        }
        refresher.endRefreshing()
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
        
        cell.usernameLbl.font = UIFont.boldSystemFont(ofSize: 12.0)
        
        cell.usernameLbl.text = "@" + contentArr[indexPath.item].ownerName
        cell.descriptionLbl.text = contentArr[indexPath.item].description
        cell.dateLbl.text = contentArr[indexPath.item].date
        cell.contentId = contentArr[indexPath.item].id
        cell.likeCount.text = String(contentArr[indexPath.item].likeCount)
        
        if(contentArr[indexPath.item].hasImage){
            
            let activityIndicator = createActivityIndicator(point: cell.contentImage.center)
            cell.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
            
            ContentManager.sharedInstance.downloadContent(contentId: contentArr[indexPath.row].id){ (response) in
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
        
        UserManager.sharedInstance.downloadImage(userId: contentArr[indexPath.item].ownerId){ (response) in
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
