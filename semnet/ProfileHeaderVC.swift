//
//  ProfileHeaderVC.swift
//  semnet
//
//  Created by ceyda on 30/11/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class ProfileHeaderVC: UICollectionReusableView {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var postsTitle: UILabel!
    @IBOutlet weak var friendsTitle: UILabel!
    
    var parentVC: ProfileCVC!
    var friend:Bool!
    
    @IBAction func editButtonClick(_ sender: Any) {
        
        let userId = UserManager.sharedInstance.getUserId()
        
        if parentVC.userId == userId {
            let storyboard = UIStoryboard(name: "Main", bundle:nil)
            let home = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! NavigationVC
            parentVC.present(home, animated: true, completion: nil)
            
        } 
    }
    
}
