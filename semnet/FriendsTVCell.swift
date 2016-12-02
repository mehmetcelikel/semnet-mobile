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
    
    
    
    
    @IBAction func addRemoveButtonAction(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
