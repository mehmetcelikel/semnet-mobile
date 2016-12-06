//
//  AppHomeVC.swift
//  semnet
//
//  Created by ceyda on 06/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class AppHomeVC: UIViewController {

    var dataSource:[(upper:String,lower:String)] = [("Subscription Groups","Subscription groups consist of varying subscription levels and durations. All auto-renewable subscriptions are required to be part of a subscription group. Customers can move between subscription durations within a group, but cannot be subscribed to more than one subscription product within a group."),
                                                    ("Duration","The length of time between auto-renewals. The duration can be 7 days, 1 month, 2 months, 3 months, 6 months, or 1 year."),
                                                    ("Subscription Levels","You can assign every in-app purchase within a subscription group to a subscription level. Subscription levels are given a default rank, but you can reorder them by dragging and dropping each in-app purchase into the appropriate rank. Your subscription levels should be listed in descending order, starting with the one that offers the highest level of service. You can add more than one subscription to each level if the service provided is determined to be equal. Customers can move between subscription levels."),
                                                    ("Upgrade","When a customer switches from a subscription in a lower level to a subscription in a higher level. This change goes into effect immediately."),
                                                    ("Marketing Incentive Duration","The length of an auto-renewable subscription extension if customers choose to opt-in to share contact information. This property is only available to Magazines & Newspapers developers who have implemented Newsstand Kit.\n\nUsers’ contact information is available in the Sales and Trends module of iTunes Connect.\n\nNote: The opt-in incentive is not available for macOS.")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AppHomeVC:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AppHomeTVCell
        
        cell.usernameLbl.text = dataSource[indexPath.item].upper
        cell.descriptionLbl.text = dataSource[indexPath.item].lower
        cell.profileImage.image = UIImage(named: "pp.jpg.gif")
        
        cell.contentImage.image = UIImage(named: "pp.jpg.gif")
        
        if ( indexPath.row != 1){
            cell.contentImageHeightConstraint.constant = 0
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /*
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        
        vw.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        vw.backgroundColor = UIColor.red
        
        return vw
    }*/
    
}
