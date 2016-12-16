//
//  NewSearchTVC.swift
//  semnet
//
//  Created by ceyda on 16/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class NewSearchTVC: UITableViewController, UISearchBarDelegate {

    var searchBar = UISearchBar()
    
    var allUsersArray = [SemNetUser]()//user
    
    var userArray = [SemNetUser]()//user
    var semanticLabelArray = [SemanticLabel]()
    
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
                self.allUsersArray = response.1
                self.userArray = self.allUsersArray
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userArray.count + semanticLabelArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! NewSearchTVCell
        
        var upperLabel = ""
        var lowerLabel = ""
        
        if(indexPath.row < semanticLabelArray.count){
            let semLabel = semanticLabelArray[indexPath.row]
            
            upperLabel = semLabel.tag + "(" + semLabel.clazz + ")"
            
            cell.searchImageView.image = UIImage(named: "users.png")!
        }else{
            let object = userArray[indexPath.row-semanticLabelArray.count]
            
            lowerLabel = object.username
            upperLabel = object.firstname + " " + object.lastname
            
            cell.user = object
            
            UserManager.sharedInstance.downloadImage(userId: object.id){ (response) in
                
                if(response.0){
                    cell.searchImageView.image=response.1
                }
            }
        }
        
        cell.usernameLabel.text = lowerLabel
        cell.fullNameLabel.text = upperLabel
        
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
        
        self.userArray = self.allUsersArray
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let resultArray = filterUsers(searchText: searchText)
        userArray = resultArray
        
        SearchManager.sharedInstance.getTags(queryString: searchText){ (response) in
            if(response.0){
                self.semanticLabelArray=response.1
            }else{
                self.semanticLabelArray.removeAll()
            }
            self.tableView.reloadData()
        }
    }

    func filterUsers(searchText: String) -> [SemNetUser]{
        var resultArray = [SemNetUser]()
        
        for object in allUsersArray {
            
            if(searchText.characters.count == 0){
                resultArray.append(object)
            }else{
                
                let result1 = Tools.levenshtein(aStr: searchText.uppercased(), bStr: object.username.uppercased())
                let r1 = result1+(searchText.characters.count) - object.username.characters.count
                if(r1 <= 0) {
                    resultArray.append(object)
                }else{
                    let fullname = object.firstname + " " + object.lastname
                    let result2 = Tools.levenshtein(aStr: searchText.uppercased(), bStr: fullname.uppercased())
                    
                    let r2 = result2+(searchText.characters.count) - fullname.characters.count
                    
                    if(r2 <= 0) {
                        resultArray.append(object)
                    }
                }
            }
        }
        return resultArray
    }
}
