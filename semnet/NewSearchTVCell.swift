//
//  NewSearchTVCell.swift
//  semnet
//
//  Created by ceyda on 16/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class NewSearchTVCell: UITableViewCell {

    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user:SemNetUser!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
