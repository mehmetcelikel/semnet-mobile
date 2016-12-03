//
//  NavigationVC.swift
//  semnet
//
//  Created by ceyda on 03/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class NavigationVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //title
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        //button
        self.navigationBar.tintColor = .white
        
        
        
        
        //mor
        self.navigationBar.barTintColor = UIColor(red: 72.0 / 255.0, green: 61.0 / 255.0, blue: 139.0 / 255.0, alpha: 1)
        
        
        
        // disable translucent
        //self.navigationBar.translucent = false
    }
    
    // white status bar function
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

}
