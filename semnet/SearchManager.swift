//
//  SearchManager.swift
//  semnet
//
//  Created by ceyda on 14/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation
import Alamofire

class SearchManager: NSObject {
    static let sharedInstance = SearchManager()
    
    func getLabels(queryString: String, callback: @escaping (Bool,Array<SemanticLabel>) -> ()) {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken!,
            "queryString": queryString
        ]
        
        Alamofire.request(searchLabelEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                var labelArray = [SemanticLabel]()
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false, labelArray)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    print(json)
                    callback(false, labelArray)
                    return
                }
                
                guard let dataList = json["dataList"] as? NSArray else {
                    callback(true, labelArray)
                    return
                }
                
                if dataList.count == 0 {
                    callback(true, labelArray)
                    return
                }
                
                for anItem in dataList as! [Dictionary<String, AnyObject>] {
                    let label = anItem["label"] as! String
                    let clazz = anItem["clazz"] as! String
                    
                    labelArray.append(SemanticLabel(tag: label, clazz: clazz))
                    
                }
                callback(true, labelArray)
        }
    }
    
    func getTags(queryString: String, callback: @escaping (Bool,Array<SemanticLabel>) -> ()) {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken!,
            "queryString": queryString
        ]
        
        Alamofire.request(searchTagsEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                var labelArray = [SemanticLabel]()
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false, labelArray)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    print(json)
                    callback(false, labelArray)
                    return
                }
                
                guard let dataList = json["dataList"] as? NSArray else {
                    callback(true, labelArray)
                    return
                }
                
                if dataList.count == 0 {
                    callback(true, labelArray)
                    return
                }
                
                for anItem in dataList as! [Dictionary<String, AnyObject>] {
                    let label = anItem["label"] as! String
                    let clazz = anItem["clazz"] as! String
                    
                    labelArray.append(SemanticLabel(tag: label, clazz: clazz))
                    
                }
                callback(true, labelArray)
        }
    }
    
    func searchContent(param: SemanticLabel, callback: @escaping (Bool,Array<Content>) -> ()) {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        
        var tagData = [String:String]()
        tagData["tag"]=param.tag
        tagData["clazz"]=param.clazz
        
        
        let parameters: Parameters = [
            "authToken": authToken!,
            "tagData": tagData
        ]
        
        Alamofire.request(searchContentEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                var contentArr = [Content]()
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false, contentArr)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    print(json)
                    callback(false, contentArr)
                    return
                }
                
                guard let contentList = json["contentList"] as? NSArray else {
                    callback(true, contentArr)
                    return
                }
                
                if contentList.count == 0 {
                    callback(true, contentArr)
                    return
                }
                
                for anItem in contentList as! [Dictionary<String, AnyObject>] {
                    let contentId = anItem["id"] as! String
                    let description = anItem["description"] as! String
                    let ownerId = anItem["ownerId"] as! String
                    let ownerName = anItem["ownerUsername"] as! String
                    let dateDiff = anItem["dateDiff"] as! String
                    let hasImage = anItem["hasImage"] as! Bool
                    let likeCount = anItem["likeCount"] as! Int
                    
                    var content = Content(id: contentId, description: description, ownerId: ownerId, ownerName: ownerName, dateDiff: dateDiff, hasImage: hasImage, likeCount: likeCount)
                    
                    var likers = [String]()
                    var tags = [SemanticLabel]()
                    
                    let likerList = anItem["likerList"] as? [Dictionary<String, AnyObject>]
                    if(likerList != nil){
                        for likerItem in likerList!  {
                            let likerId = likerItem["id"] as! String
                            likers.append(likerId)
                        }
                    }
                    
                    
                    let tagList = anItem["tagList"] as? [Dictionary<String, AnyObject>]
                    if(tagList != nil){
                        for tagItem in tagList!  {
                            let tag = tagItem["tag"] as! String
                            let clazz = tagItem["clazz"] as! String
                            tags.append(SemanticLabel(tag: tag, clazz: clazz))
                        }
                    }
                    
                    
                    content.likers = likers
                    content.tagList = tags
                    
                    contentArr.append(content)
                    
                }
                
                
                callback(true, contentArr)
        }
    }
}
