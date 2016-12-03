//
//  SemNetUser.swift
//  semnet
//
//  Created by ceyda on 03/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation

struct SemNetUser {
    var id: String!
    var username: String!
    var firstname: String!
    var lastname: String!
    var password: String!
    
    init(id: String, username: String, firstname: String, lastname: String) {
        self.id = id
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
    }
    
    init(){
    }
}
