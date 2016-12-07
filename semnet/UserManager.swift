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
    
    func getToken() -> String!{
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    func getUsername() -> String!{
        return UserDefaults.standard.string(forKey: "username")
    }
    
    func getUserId() -> String!{
        return UserDefaults.standard.string(forKey: "userId")
    }
    
    
    func getUser(userId: String, callback: @escaping (Bool,SemNetUser) -> ()) {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken!,
            "id": userId
        ]
        
        Alamofire.request(userGetEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                var u = SemNetUser()
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false, u)
                    return
                }
                
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
    
    func createUser(user: SemNetUser, callback: @escaping (Bool) -> ())  {
        
        let createParams : [String: Any] =
            ["username" : user.username,
             "password" : user.password!,
             "firstname" : user.firstname!,
             "lastname" : user.lastname!
        ]
        
        Alamofire.request(userCreateEndpoint, method: .post, parameters: createParams, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    callback(false)
                    return
                }
                
                UserManager.sharedInstance.saveUserInfo(authToken: (json["token"] as! String?)!, userId: (json["id"] as! String?)!, username: user.username!)
                
                callback(true)
        }
    }
    
    func uploadUserImage(image: UIImage!, callback: @escaping (Bool) -> ()){
        
        let authToken = UserManager.sharedInstance.getToken()
        let userId = UserManager.sharedInstance.getUserId()
        
        if image == nil {
            callback(true)
            return
        }
        
        let imageData = UIImageJPEGRepresentation(image!, 0.5)
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData!, withName: "file", fileName: "imageFileName.jpg", mimeType: "image/jpeg")
                multipartFormData.append((authToken!.data(using: String.Encoding.utf8)!), withName :"authToken")
                multipartFormData.append((userId!.data(using: String.Encoding.utf8)!), withName :"userId")
        },
            to: userImageUploadEndpoint,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { (JSON) in
                        callback(true)
                    }
                    
                case .failure:
                    //Show Alert in UI
                    callback(false)
                }
        }
        );
    }
    
    func updateUser(user: SemNetUser, callback: @escaping (Bool) -> ()) {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken!,
            "id": user.id!,
            "firstname": user.firstname,
            "lastname": user.lastname
        ]
        
        Alamofire.request(userUpdateEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    callback(false)
                    return
                }
                
                callback(true)
        }
    }
    
    func searchUsers(queryString: String, callback: @escaping (Bool,Array<SemNetUser>) -> ()) {
        
        let parameters: Parameters = [
            "authToken": getToken(),
            "queryString": queryString
        ]
        
        Alamofire.request(userSearchEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                var userArray = [SemNetUser]()
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false, userArray)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    callback(false, userArray)
                    return
                }
                
                guard let userList = json["userList"] as? NSArray else {
                    callback(true, userArray)
                    return
                }
                
                if userList.count == 0 {
                    callback(true, userArray)
                    return
                }
                
                for anItem in userList as! [Dictionary<String, AnyObject>] {
                    let personName = anItem["username"] as! String
                    let personID = anItem["id"] as! String
                    let firstname = anItem["firstname"] as! String
                    let lastname = anItem["lastname"] as! String
                    
                    userArray.append(SemNetUser(id: personID, username: personName, firstname: firstname, lastname: lastname))
                }
                callback(true, userArray)
        }
    }
    
    func loadUserlist(token: String, callback: @escaping (Bool,Array<SemNetUser>) -> ()) {
        
        let parameters: Parameters = [
            "authToken": token
        ]
        
        Alamofire.request(userListAllEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                var userArray = [SemNetUser]()
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false, userArray)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    callback(false, userArray)
                    return
                }
                
                guard let userList = json["userList"] as? NSArray else {
                    callback(true, userArray)
                    return
                }
                
                if userList.count == 0 {
                    callback(true, userArray)
                    return
                }
                
                for anItem in userList as! [Dictionary<String, AnyObject>] {
                    let personName = anItem["username"] as! String
                    let personID = anItem["id"] as! String
                    let firstname = anItem["firstname"] as! String
                    let lastname = anItem["lastname"] as! String
                    
                    userArray.append(SemNetUser(id: personID, username: personName, firstname: firstname, lastname: lastname))
                }
                callback(true, userArray)
        }
    }
    
    func downloadImage(userId: String, callback: @escaping (Bool,UIImage) -> ()){
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken!,
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
                
                if let image = UIImage(data: data) {
                    callback(true, image)
                }else{
                    callback(true, UIImage(named: "pp.jpg.gif")!)
                }
        }
    }
}
