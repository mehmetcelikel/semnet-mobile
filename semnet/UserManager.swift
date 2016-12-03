//
//  UserManager.swift
//  semnet
//
//  Created by ceyda on 28/11/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation
import Alamofire

class UserManager: NSObject {
    static let sharedInstance = UserManager()
    
    var myFriendArray = [SemNetUser]()
    
    func saveUserInfo(authToken:String, userId:String, username:String){
        UserDefaults.standard.set(authToken, forKey: "authToken")
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(username, forKey: "username")
        
        UserDefaults.standard.synchronize()
    }
    
    func clearUserInfo(){
        UserDefaults.standard.set(nil, forKey: "authToken")
        UserDefaults.standard.set(nil, forKey: "userId")
        UserDefaults.standard.set(nil, forKey: "username")
        
        UserDefaults.standard.synchronize()
    }
    
    func getToken() -> String{
        return UserDefaults.standard.string(forKey: "authToken")!
    }
    
    func getUsername() -> String{
        return UserDefaults.standard.string(forKey: "username")!
    }
    
    func getUserId() -> String{
        return UserDefaults.standard.string(forKey: "userId")!
    }
    
    
    func getUser(userId: String, callback: @escaping (Bool,SemNetUser) -> ()) {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken,
            "id": userId
        ]
        
        Alamofire.request(userGetEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                var u:SemNetUser!
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false, u)
                    return
                }
                print(json)
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    callback(false, u)
                    return
                }
                
                let fname = json["firstname"] as! String?
                let lname = json["lastname"] as! String?
                let uname = json["username"] as! String?
                
                u = SemNetUser(id: userId, username: uname!, firstname: fname!, lastname: lname!)
                
                callback(true, u)
        }
    }
    
    func loadFriendlist(token: String, callback: @escaping (Bool,Array<SemNetUser>) -> ()) {
        
        let parameters: Parameters = [
            "authToken": token
        ]
        
        Alamofire.request(friendListEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                var friendArray = [SemNetUser]()
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false, friendArray)
                    return
                }
                print(json)
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
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
    
    func downloadImage(userId: String, callback: @escaping (Bool,UIImage) -> ()){
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken,
            "userId": userId
        ]
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask, true)[0]
            let documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: true)
            let fileURL = documentsURL.appendingPathComponent("image.png")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories]) }
        
        Alamofire.download(userImageDownloadEndpoint, parameters: parameters, to: destination)
            .responseData { resp in
                guard let data = resp.result.value else {
                    return
                }
                
                callback(true, UIImage(data: data)!)
        }
    }
}
