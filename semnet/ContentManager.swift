//
//  ContentManager.swift
//  semnet
//
//  Created by ceyda on 03/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

class ContentManager: NSObject {
    static let sharedInstance = ContentManager()
    
    var location:CLLocation!
    
    func didILike(content: Content) -> Bool{
        let userId = UserManager.sharedInstance.getUserId()
        
        var found=false;
        for object in content.likers {
            if(userId == object) {
                found = true;
                break;
            }
        }
        return found
    }
    
    func createContent(description: String, hasImage: Bool, callback: @escaping (Bool, String) -> ())  {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let createParams : [String: Any] =
            ["authToken" : authToken!,
             "description" : description,
             "hasImage": hasImage,
             "longitude": location.coordinate.longitude,
             "latitude": location.coordinate.latitude
        ]
        
        Alamofire.request(contentCreateEndpoint, method: .post, parameters: createParams, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                var contentId = ""
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false, contentId)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    print(json)
                    callback(false, contentId)
                    return
                }
                contentId = (json["id"] as! String?)!
                
                callback(true, contentId)
        }
    }
    
    func tagContent(contentId: String, tagList: Array<SemanticLabel>, callback: @escaping (Bool) -> ())  {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        var tList = [Dictionary<String, String>]()
        
        for object in tagList {
            var tags = [String:String]()
            tags["tag"]=object.tag
            tags["clazz"]=object.clazz
            
            tList.append(tags)
        }
        
        let createParams : [String: Any] =
            ["authToken" : authToken!,
             "tag" : tList,
             "entityId": contentId,
             "add": true
        ]
        
        Alamofire.request(commentTagEndpoint, method: .post, parameters: createParams, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    print(json)
                    callback(false)
                    return
                }
                
                callback(true)
        }
    }
    
    func uploadContent(image: UIImage!, contentId: String, callback: @escaping (Bool) -> ()){
        
        let authToken = UserManager.sharedInstance.getToken()
        
        if image == nil {
            callback(true)
            return
        }
        
        let imageData = UIImageJPEGRepresentation(image!, 0.4)
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData!, withName: "file", fileName: "imageFileName.jpg", mimeType: "image/jpeg")
                multipartFormData.append((authToken!.data(using: String.Encoding.utf8)!), withName :"authToken")
                multipartFormData.append((contentId.data(using: String.Encoding.utf8)!), withName :"contentId")
        },
            to: contentUploadEndpoint,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { (JSON) in
                        callback(true)
                    }
                    
                case .failure:
                    //Show Alert in UI
                    callback(false)
                }
        }
        );
    }
    
    func loadContentlist(userId: String, type: String, callback: @escaping (Bool,Array<Content>) -> ()) {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters!
        if(location == nil){
            parameters =  [
                "authToken": authToken!,
                "userId": userId,
                "type": type
                ]
        }else{
            parameters = [
                "authToken": authToken!,
                "userId": userId,
                "type": type,
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
                ]
        }
        
        Alamofire.request(contentListEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    return
                }
                
                var contentArr = [Content]()
                
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
                    let distance = anItem["distance"] as? Int
                    
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
                    content.distance = distance
                    
                    contentArr.append(content)
                }
                
                callback(true, contentArr)
        }
    }
    
    func loadCommentlist(contentId: String, callback: @escaping (Bool,Array<Comment>) -> ()) {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken!,
            "id": contentId
        ]
        
        Alamofire.request(commentListEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    return
                }
                
                var commentArr = [Comment]()
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    print(json)
                    callback(false, commentArr)
                    return
                }
                
                guard let commentList = json["commentList"] as? NSArray else {
                    callback(true, commentArr)
                    return
                }
                
                if commentList.count == 0 {
                    callback(true, commentArr)
                    return
                }
                
                for anItem in commentList as! [Dictionary<String, AnyObject>] {
                    let contentId = anItem["id"] as! String
                    let description = anItem["description"] as! String
                    let ownerId = anItem["ownerId"] as! String
                    let ownerName = anItem["ownerUsername"] as! String
                    let dateDiff = anItem["dateDiff"] as! String
                    
                    commentArr.append(Comment(id: contentId, comment: description, ownerId: ownerId, ownerName: ownerName, dateDiff: dateDiff))
                    
                }
                callback(true, commentArr)
        }
    }
    
    func downloadContent(contentId: String, callback: @escaping (Bool,UIImage) -> ()){
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken!,
            "contentId": contentId
        ]
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask, true)[0]
            let documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: true)
            let fileURL = documentsURL.appendingPathComponent("content.jpg")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories]) }
        
        Alamofire.download(contentDownloadEndpoint, parameters: parameters, to: destination)
            .responseData { resp in
                guard let data = resp.result.value else {
                    return
                }
                
                if let image = UIImage(data: data) {
                    callback(true, image)
                }else{
                    callback(true, UIImage())
                }
        }
    }
    
    func likeContent(contentId: String, like: Bool, callback: @escaping (Bool,Int) -> ())  {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let createParams : [String: Any] =
            ["authToken" : authToken!,
             "id" : contentId
        ]
        
        var url = contentUnlikeEndpoint
        if(like){
            url = contentLikeEndpoint
        }
        
        Alamofire.request(url, method: .post, parameters: createParams, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false,0)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    print(json)
                    callback(false,0)
                    return
                }
                let likeCount = json["likeCount"] as! Int
                
                callback(true,likeCount)
        }
    }
    
    func createComment(contentId: String, comment: String, callback: @escaping (Bool,String) -> ())  {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let createParams : [String: Any] =
            ["authToken" : authToken!,
             "contentId" : contentId,
             "description" : comment
        ]
        
        Alamofire.request(commentAddEndpoint, method: .post, parameters: createParams, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false,"")
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    print(json)
                    callback(false,"")
                    return
                }
                let commentId = json["id"] as! String
                
                callback(true, commentId)
        }
    }
    
    func deleteComment(contentId: String, commentId: String, callback: @escaping (Bool) -> ())  {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let createParams : [String: Any] =
            ["authToken" : authToken!,
             "contentId" : contentId,
             "commentId" : commentId
        ]
        
        Alamofire.request(commentDeleteEndpoint, method: .post, parameters: createParams, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    callback(false)
                    return
                }
                
                let errorCode = json["errorCode"] as! String?
                if errorCode != "SNET_0" {
                    print(json)
                    callback(false)
                    return
                }
                callback(true)
        }
    }
}
