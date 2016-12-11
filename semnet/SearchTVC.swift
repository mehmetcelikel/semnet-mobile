//
//  SearchTVC.swift
//  semnet
//
//  Created by ceyda on 03/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit
import Alamofire

class SearchTVC: UITableViewController, UISearchBarDelegate {

    var searchBar = UISearchBar()
    
    var userArray = [SemNetUser]()//user
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.showsCancelButton = true
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.size.width - 34
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem

        let authToken = UserManager.sharedInstance.getToken()
        
        UserManager.sharedInstance.loadUserlist(token: authToken!) { (response) in
            if(response.0){
                self.userArray = response.1
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userArray.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FriendsTVCell
        cell.addRemoveButton.isHidden = true
        let object = userArray[indexPath.row]
        cell.usernameLabel.text = object.username
         cell.userId = object.id
        
        UserManager.sharedInstance.downloadImage(userId: object.id){ (response) in

            if(response.0){
                cell.friendImage.image=response.1
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // calling cell again to call cell data
        let cell = tableView.cellForRow(at: indexPath) as! FriendsTVCell
        
        profileUserId.append(cell.userId)
        let guest = self.storyboard?.instantiateViewController(withIdentifier: "ProfileCVC") as! NewProfileVC
        self.navigationController?.pushViewController(guest, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // scroll down
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
           
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tableView.isHidden = false
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.tableView.isHidden = true
        // dismiss keyboard
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    
        searchBar.text = ""
    
        let authToken = UserManager.sharedInstance.getToken()
        UserManager.sharedInstance.loadUserlist(token: authToken!) { (response) in
            if(response.0){
                self.userArray = response.1
                self.tableView.reloadData()
            }
        }
    }

    // search updated
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        UserManager.sharedInstance.searchUsers(queryString: self.searchBar.text!) { (response) in
            if(response.0){
                self.userArray = response.1
                self.tableView.reloadData()
            }
        }
        
        return true
    }
}
