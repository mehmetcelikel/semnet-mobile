//
//  NewProfileVC.swift
//  semnet
//
//  Created by ceyda on 06/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit

class NewProfileVC: UIViewController {

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

extension NewProfileVC:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewProfileTVCell
        
        cell.usernameLbl.text = dataSource[indexPath.item].upper
        cell.descriptionLbl.text = dataSource[indexPath.item].lower
        
        cell.contentImage.image = UIImage(named: "pp.jpg.gif")
        
        if ( indexPath.row != 1){
            cell.contentHeightConstraint.constant = 0
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }
     
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
     
        vw.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 100)
        vw.backgroundColor = UIColor.white
        vw.layer.borderWidth = 1.0
        vw.layer.borderColor = UIColor.lightGray.cgColor
     
        let profileImage = UIImageView(image: UIImage(named: "pp.jpg.gif"))
        profileImage.frame = CGRect(x: 10, y: 10, width: 80, height: 80)
        profileImage.layer.cornerRadius = 4
        profileImage.layer.masksToBounds = true
        
        vw.addSubview(profileImage)
        
        let fullname = UILabel(frame: CGRect(x: profileImage.frame.maxX + 10, y: 5, width: screenWidth/2, height: 20))
        
        fullname.textColor = UIColor.black
        fullname.font = UIFont(name: fullname.font.fontName, size: 12)
        fullname.text = "Fullname"
        fullname.textAlignment = NSTextAlignment.left
        fullname.contentMode = UIViewContentMode.scaleAspectFit
        
        vw.addSubview(fullname)
        
        let username = UILabel(frame: CGRect(x: profileImage.frame.maxX + 10, y: fullname.frame.maxY, width: screenWidth/2, height: 20))
        
        username.textColor = UIColor.black
        username.font = UIFont(name: username.font.fontName, size: 8)
        username.text = "@Username"
        username.textAlignment = NSTextAlignment.left
        username.contentMode = UIViewContentMode.scaleAspectFit
        
        vw.addSubview(username)
        
        let posts = UILabel(frame: CGRect(x: profileImage.frame.maxX + 10, y: profileImage.frame.maxY-20, width: 50, height: 20))
        
        posts.textColor = UIColor.black
        posts.font = UIFont(name: username.font.fontName, size: 10)
        posts.textAlignment = NSTextAlignment.left
        posts.contentMode = UIViewContentMode.scaleAspectFit
        posts.attributedText = formatText(boldText: "12", normalText: " Posts")
        vw.addSubview(posts)
        
        let friends = UILabel(frame: CGRect(x: posts.frame.maxX + 10, y: profileImage.frame.maxY-20, width: 50, height: 20))
        
        friends.textColor = UIColor.black
        friends.font = UIFont(name: username.font.fontName, size: 10)
        friends.textAlignment = NSTextAlignment.left
        friends.contentMode = UIViewContentMode.scaleAspectFit
        friends.attributedText = formatText(boldText: "5", normalText: " Friends")
        
        vw.addSubview(friends)
        
        let editButton = UIButton(frame: CGRect(x: screenWidth-70, y: 10, width: 60, height: 20))
        editButton.setTitle("Edit", for: .normal)
        editButton.titleLabel?.font = UIFont(name: username.font.fontName, size: 12)
        editButton.tintColor = UIColor.purple
        editButton.setTitleColor(UIColor.black, for: .normal)
        editButton.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        
        editButton.backgroundColor = UIColor.white
        editButton.layer.borderWidth = 1.0
        editButton.layer.borderColor = UIColor.lightGray.cgColor
        editButton.layer.cornerRadius = 4
        editButton.layer.masksToBounds = true
        
        
        vw.addSubview(editButton)
        
        return vw
    }
    
    func formatText(boldText: String, normalText: String) -> NSMutableAttributedString{
        let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 12)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
        let normalString = NSMutableAttributedString(string:normalText)
        
        attributedString.append(normalString)
        
        return attributedString
    }
    
    func editAction(sender: UIButton!) {
        print("Button tapped")
    }
}
