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

    let baseURL = "http://107.170.24.239:9000/v1/user/"
    
    func login(user: String, password: String, onCompletion: @escaping (JSON) -> Void) {
        let loginParams : [String: Any] = ["username" : user, "password" : password]
        
        let route = baseURL + "login"
        RestApiManager.sharedInstance.makeHTTPPostRequest(path: route, body: loginParams as [String : AnyObject], onCompletion: { json, err in onCompletion(json as JSON)
        })
    }
    
    func create(user: String, password: String, firstname: String, lastname: String, onCompletion: @escaping (JSON) -> Void) {
        let createParams : [String: Any] = ["username" : user, "password" : password, "firstname" : firstname, "lastname" : lastname]
        
        let route = baseURL + "create"
        RestApiManager.sharedInstance.makeHTTPPostRequest(path: route, body: createParams as [String : AnyObject], onCompletion: { json, err in onCompletion(json as JSON)
        })
    }
    
    func get(userId: String, onCompletion: @escaping (JSON) -> Void) {
        
        let authToken : String? = UserDefaults.standard.string(forKey: "authToken")
        
        let getParams : [String: Any] = ["id" : userId, "authToken" : authToken ?? ""]
        
        let route = baseURL + "get"
        RestApiManager.sharedInstance.makeHTTPPostRequest(path: route, body: getParams as [String : AnyObject], onCompletion: { json, err in onCompletion(json as JSON)
        })
    }
}
