//
//  AppHomeTVCell.swift
//  semnet
//
//  Created by ceyda on 06/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class AppHomeTVCell: UITableViewCell {

    var liked:Bool!
    var contentId:String!
    
    @IBOutlet weak var contentImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func commentButtonAction(_ sender: Any) {
    }
    
    @IBAction func likeButtonAction(_ sender: Any) {
        
        self.likeButton.isEnabled = false
        
        ContentManager.sharedInstance.likeContent(contentId: contentId, like: !liked) { (response) in
            if(response.0){
                self.likeCount.text = "\(response.1)"
                self.setLikeButtonBackground(likeAction: !self.liked)
                
                self.liked = !self.liked
                
                // send notification if  liked to refresh TableView
                NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
            }
        }
    }
    
    func setLikeButtonBackground(likeAction: Bool){
        
        var imageName = "unlike.png"
        if(likeAction){
            imageName = "like.png"
        }
        self.likeButton.setTitle("like", for: UIControlState())
        self.likeButton.setBackgroundImage(UIImage(named: imageName), for: UIControlState())
        self.likeButton.setImage(UIImage(named: imageName), for: UIControlState())
        
        self.likeButton.isEnabled = true
    }
}
