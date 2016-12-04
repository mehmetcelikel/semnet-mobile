//
//  FriendsTVCell.swift
//  semnet
//
//  Created by ceyda on 02/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class FriendsTVCell: UITableViewCell {

    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addRemoveButton: UIButton!
    var userId:String!
    var friend:Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.friendImage.frame = CGRect(x: 10, y: 10, width: screenWidth/7, height: screenWidth/7)
        self.usernameLabel.frame = CGRect(x: friendImage.frame.maxX, y: friendImage.frame.maxY/2, width: 4*screenWidth/7, height: 20)
        self.addRemoveButton.frame = CGRect(x: usernameLabel.frame.maxX, y: friendImage.frame.maxY/2, width: (2*screenWidth/7)-20, height: 30)
        
        friendImage.layer.cornerRadius = friendImage.frame.size.width / 2
        friendImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    @IBAction func addRemoveButtonAction(_ sender: Any) {
               // to follow
        if self.friend == false {
            
            let customColor = UIColor(red: 72.0 / 255.0, green: 61.0 / 255.0, blue: 139.0 / 255.0, alpha: 0.5)
            
            FriendManager.sharedInstance.addFriend(userId: self.userId){ (response) in
                if(response){
                    self.friend = true
                    
                    self.addRemoveButton.setTitle("Remove", for: UIControlState())
                    self.addRemoveButton.setTitleColor(UIColor.white, for: UIControlState())
                    self.addRemoveButton.backgroundColor = customColor
                    self.addRemoveButton.layer.cornerRadius = 8
                    self.addRemoveButton.layer.masksToBounds = true
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                }
            }
            
        } else {
            
            FriendManager.sharedInstance.removeFriend(userId: self.userId){ (response) in
                if(response){
                    self.friend = false
                    
                    self.addRemoveButton.setTitle("Add", for: UIControlState())
                    self.addRemoveButton.setTitleColor(UIColor.black, for: UIControlState())
                    self.addRemoveButton.backgroundColor = UIColor.white
                    self.addRemoveButton.layer.borderWidth = 1.0
                    self.addRemoveButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.addRemoveButton.layer.cornerRadius = 8
                    self.addRemoveButton.layer.masksToBounds = true
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                }
            }
        }
    }
}
