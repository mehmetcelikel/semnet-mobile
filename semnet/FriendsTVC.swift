//
//  FriendsTVC.swift
//  semnet
//
//  Created by ceyda on 02/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

var userToListFriend = String()
var friendArrayToBelListed = [SemNetUser]()

class FriendsTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Friend List".uppercased()
        
        self.tableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(FriendsTVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(FriendsTVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendArrayToBelListed.count
    }

    // selected some user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let cell = tableView.cellForRow(at: indexPath) as! FriendsTVCell
        
        profileUserId.append(cell.userId)
        let guest = self.storyboard?.instantiateViewController(withIdentifier: "ProfileCVC") as! ProfileCVC
        self.navigationController?.pushViewController(guest, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FriendsTVCell
        
        let followUser = friendArrayToBelListed[indexPath.row]
        
        cell.usernameLabel.text = followUser.username
        cell.friendImage.image = nil
        
        var found:Bool!;
        for object in UserManager.sharedInstance.myFriendArray {
            if(followUser.id == object.id) {
                found = true;
                break;
            }
        }
        
        if cell.userId == UserManager.sharedInstance.getUserId() {
            cell.addRemoveButton.isHidden = true
        }
        
        if found == true {
            cell.addRemoveButton.setTitleColor(UIColor.black, for: UIControlState())
            cell.addRemoveButton.backgroundColor = UIColor.lightGray
            cell.addRemoveButton.setTitle("Remove Friend", for: UIControlState())
        } else {
            cell.addRemoveButton.setTitleColor(UIColor.red, for: UIControlState())
            cell.addRemoveButton.backgroundColor = UIColor.gray
            cell.addRemoveButton.setTitle("Add Friend", for: UIControlState())
        }
        
        return cell
    }
    
    func back(_ sender : UITabBarItem) {
        self.navigationController?.popViewController(animated: true)
    }

}
