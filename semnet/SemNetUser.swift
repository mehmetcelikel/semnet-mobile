//
//  SemNetUser.swift
//  semnet
//
//  Created by ceyda on 03/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation

struct SemNetUser {
    let id: String
    let username: String
    let firstname: String
    let lastname: String
    
    init(id: String, username: String, firstname: String, lastname: String) {
        self.id = id
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
    }
}
