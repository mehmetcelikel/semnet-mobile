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
    var email: String!
    var phone: String!
    var password: String!
    
    init(id: String, username: String, firstname: String, lastname: String, email: String!, phone: String!) {
        self.id = id
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.phone = phone
    }
    
    init(){
    }
}
