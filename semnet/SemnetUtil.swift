//
//  SemnetUtil.swift
//  semnet
//
//  Created by ceyda on 16/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation
import UIKit


func formatText(boldText: String, normalText: String) -> NSMutableAttributedString{
    let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 12)]
    let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
    let normalString = NSMutableAttributedString(string:normalText)
    
    attributedString.append(normalString)
    
    return attributedString
}

func formatTagText(normalText: String, tagList: [SemanticLabel]!) -> NSMutableAttributedString{
    
    let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 12)]
    let normalString = NSMutableAttributedString(string:normalText)
    
    var tagSring = " #"
    if(tagList != nil){
        for object in tagList {
            if(tagSring != " #"){
                tagSring += ", "
            }
            tagSring += object.tag + "(" + object.clazz + ")"
        }
    }
    if(tagSring != " #"){
        let attributedString = NSMutableAttributedString(string:tagSring, attributes:attrs)
        normalString.append(attributedString)
    }
    
    
    return normalString
}
