//
//  ContentManager.swift
//  semnet
//
//  Created by ceyda on 03/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation
import Alamofire

class ContentManager: NSObject {
    static let sharedInstance = ContentManager()
    
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
             "hasImage": hasImage
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
        
        let parameters: Parameters = [
            "authToken": authToken!,
            "userId": userId,
            "type": type
        ]
        
        Alamofire.request(contentListEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    print("Error: \(response.result.error)")
                    return
                }
                print(json)
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
                    let date = anItem["creationDate"] as! Int
                    let hasImage = anItem["hasImage"] as! Bool
                    let likeCount = anItem["likeCount"] as! Int
                    
                    var likers = [String]()
                    
                    guard let likerList = anItem["likerList"] as? [Dictionary<String, AnyObject>] else {
                        contentArr.append(Content(id: contentId, description: description, ownerId: ownerId, ownerName: ownerName, date: date, hasImage: hasImage, likeCount: likeCount, likers: likers))
                        
                        continue
                    }
                    
                    for likerItem in likerList  {
                        let likerId = likerItem["id"] as! String
                        likers.append(likerId)
                    }
                    
                    contentArr.append(Content(id: contentId, description: description, ownerId: ownerId, ownerName: ownerName, date: date, hasImage: hasImage, likeCount: likeCount, likers: likers))
                    
                }
                callback(true, contentArr)
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
                print(json)
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
}
