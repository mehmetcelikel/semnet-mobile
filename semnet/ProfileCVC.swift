//
//  ProfileCVC.swift
//  semnet
//
//  Created by ceyda on 30/11/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit
import Alamofire

class ProfileCVC: UICollectionViewController {

    var userId:String!
    var firstname:String!
    var lastname:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        collectionView?.backgroundColor = .white
        
        
        self.collectionView?.alwaysBounceVertical = true
        
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    // header config
    override func collectionView(_ collectionView: UICollectionView,
                                  viewForSupplementaryElementOfKind kind: String,
                                  at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath as IndexPath) as! ProfileHeaderVC
        
        let currenctUserId : String? = UserDefaults.standard.string(forKey: "userId")
        if userId == nil {
           userId = currenctUserId
        }
        let authToken = UserDefaults.standard.string(forKey: "authToken")
        
        let parameters: Parameters = [
            "authToken": authToken!,
            "id": userId!
        ]
        
        loadUserDetail(parameters: parameters, completionHandler:{(UIBackgroundFetchResult) -> Void in
            header.nameLabel.text = self.firstname! + " " + self.lastname!
        })
        
        if currenctUserId == userId {
            
            let customColor = UIColor(red: 72.0 / 255.0, green: 61.0 / 255.0, blue: 139.0 / 255.0, alpha: 0.5)
            
            header.editButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            header.editButton.backgroundColor = customColor
            header.editButton.setTitle("Edit", for: .normal)
        }
        
        return header
    }
    
    func loadUserDetail(parameters: Parameters, completionHandler: ((UIBackgroundFetchResult)     -> Void)!) {
        Alamofire.request(userGetEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    self.returnToLogin()
                    return
                }
                print(json)
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    self.returnToLogin()
                    return
                }
                
                self.firstname = json["firstname"] as! String?
                self.lastname = json["lastname"] as! String?
                
                completionHandler(UIBackgroundFetchResult.newData)
        }
    }
    /*
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
    
        return cell
    }*/

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    func presentAlert(alertMessage : String){
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "Warning", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func returnToLogin() {
        UserDefaults.standard.set(nil, forKey: "authToken")
        UserDefaults.standard.set(nil, forKey: "userId")
        UserDefaults.standard.synchronize()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.present(vc, animated: true, completion: nil)
    }
}
