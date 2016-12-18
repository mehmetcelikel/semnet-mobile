//
//  SemanticLabel.swift
//  semnet
//
//  Created by ceyda on 14/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation

struct SemanticLabel {

    let tag: String!
    let clazz: String!
    var count: Int!
    
    init(tag: String, clazz: String!) {
        self.tag = tag
        self.clazz = clazz
    }
}
