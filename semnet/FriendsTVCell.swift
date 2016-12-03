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
        let title = addRemoveButton.title(for: UIControlState())
        
        // to follow
        if title == "Add Friend" {
            
            
            self.addRemoveButton.setTitle("Add Friend", for: UIControlState())
            self.addRemoveButton.setTitleColor(UIColor.red, for: UIControlState())
            self.addRemoveButton.backgroundColor = UIColor.gray
            
        } else {
            
            self.addRemoveButton.setTitle("Remove Friend", for: UIControlState())
            self.addRemoveButton.setTitleColor(UIColor.black, for: UIControlState())
            self.addRemoveButton.backgroundColor = UIColor.green

            
        }
    }
}
