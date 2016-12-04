//
//  TabBarVC.swift
//  semnet
//
//  Created by ceyda on 04/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tabBar.tintColor = .white
        
        
        self.tabBar.barTintColor = UIColor(red: 37.0 / 255.0, green: 39.0 / 255.0, blue: 42.0 / 255.0, alpha: 1)
        
        // disable translucent
        //self.tabBar.translucent = false
        
        
    }

}
