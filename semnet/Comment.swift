//
//  Comment.swift
//  semnet
//
//  Created by ceyda on 11/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation
import UIKit

struct Comment {
    let id: String
    let comment: String
    let ownerId: String
    let ownerName: String
    let dateDiff: String
    
    init(id: String, comment: String, ownerId: String, ownerName: String, dateDiff: String) {
        self.id = id
        self.comment = comment
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.dateDiff = dateDiff
    }
}
