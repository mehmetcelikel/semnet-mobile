//
//  Content.swift
//  semnet
//
//  Created by ceyda on 03/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation

struct Content {
    let id: String
    let description: String
    let ownerId: String
    let ownerName: String
    let dateDiff: String
    let likeCount: Int
    let hasImage: Bool
    var likers = [String]()
    
    init(id: String, description: String, ownerId: String, ownerName: String, dateDiff: String, hasImage: Bool, likeCount: Int, likers: [String]) {
        self.id = id
        self.description = description
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.hasImage = hasImage
        self.likeCount = likeCount
        self.likers = likers
        self.dateDiff = dateDiff
    }
}
