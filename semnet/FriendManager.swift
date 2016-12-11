//
//  FriendManager.swift
//  semnet
//
//  Created by ceyda on 04/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation
import Alamofire

class FriendManager: NSObject {
    static let sharedInstance = FriendManager()
    
    var myFriendArray = [SemNetUser]()
    
    func isMyFriend(userId: String) -> Bool{
        var found=false;
        for object in myFriendArray {
            if(userId == object.id) {
                found = true;
                break;
            }
        }
        return found
    }
    
    func loadFriendlist(userId: String, callback: @escaping (Bool,Array<SemNetUser>) -> ()) {
        
        let parameters: Parameters = [
            "authToken": UserManager.sharedInstance.getToken(),
            "id": userId
        ]
        
        Alamofire.request(friendListEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                var friendArray = [SemNetUser]()
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false, friendArray)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    print(json)
                    callback(false, friendArray)
                    return
                }
                
                guard let friendList = json["userList"] as? NSArray else {
                    callback(true, friendArray)
                    return
                }
                
                if friendList.count == 0 {
                    callback(true, friendArray)
                    return
                }
                
                for anItem in friendList as! [Dictionary<String, AnyObject>] {
                    let personName = anItem["username"] as! String
                    let personID = anItem["id"] as! String
                    let firstname = anItem["firstname"] as! String
                    let lastname = anItem["lastname"] as! String
                    
                    friendArray.append(SemNetUser(id: personID, username: personName, firstname: firstname, lastname: lastname))
                }
                callback(true, friendArray)
        }
    }
    
    func addFriend(userId: String, callback: @escaping (Bool) -> ()) {
        
        let authToken = UserManager.sharedInstance.getToken() as String
        
        let parameters: Parameters = [
            "authToken": authToken,
            "friendId": userId
        ]
        
        Alamofire.request(friendAddEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    print(json)
                    callback(false)
                    return
                }
                
                var u = SemNetUser()
                u.id = userId
                
                self.myFriendArray.append(u)
                callback(true)
        }
    }
    
    func removeFriend(userId: String, callback: @escaping (Bool) -> ()) {
        
        let authToken = UserManager.sharedInstance.getToken() as String
        
        let parameters: Parameters = [
            "authToken": authToken,
            "friendId": userId
        ]
        
        Alamofire.request(friendRemoveEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    print(json)
                    callback(false)
                    return
                }
                
                var newArr = [SemNetUser]()
                for object in self.myFriendArray {
                    if(userId == object.id) {
                        continue;
                    }
                    newArr.append(object)
                }
                self.myFriendArray = newArr
                
                callback(true)
        }
    }
}
