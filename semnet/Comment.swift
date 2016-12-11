//
//  Comment.swift
//  semnet
//
//  Created by ceyda on 11/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation

struct Comment {
    let id: String
    let comment: String
    let ownerId: String
    let ownerName: String
    let date: String
    
    
    init(id: String, comment: String, ownerId: String, ownerName: String, date: Int) {
        self.id = id
        self.comment = comment
        self.ownerId = ownerId
        self.ownerName = ownerName
        
        let millis: UnixTime = date
        
        self.date = millis.toDay
    }
}
