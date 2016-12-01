//
//  UserManager.swift
//  semnet
//
//  Created by ceyda on 28/11/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation

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
    
    func getToken() -> String{
        return UserDefaults.standard.string(forKey: "authToken")!
    }
    
    func getUsername() -> String{
        return UserDefaults.standard.string(forKey: "username")!
    }
    
    func getUserId() -> String{
        return UserDefaults.standard.string(forKey: "userId")!
    }
}
