//
//  FriendsTVC.swift
//  semnet
//
//  Created by ceyda on 02/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

var userToListFriend = String()

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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    func back(_ sender : UITabBarItem) {
        self.navigationController?.popViewController(animated: true)
    }

}
