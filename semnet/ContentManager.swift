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
    
    func loadContentlist(userId: String, callback: @escaping (Bool,Array<Content>) -> ()) {
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken,
            "userId": userId,
            "type": "SPECIFIED"
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
                    contentArr.append(Content(id: contentId, description: description))
                }
                callback(true, contentArr)
        }
    }
    
    func fetchContentsOfFriends(contentArr: [Content], callback: @escaping (Bool,Array<UIImage>) -> ()){
        
        var contentImageArr = [UIImage]()
        
        for object in FriendManager.sharedInstance.myFriendArray {
            downloadContent(contentId: object.id){ (response) in
                if(response.0){
                    contentImageArr.append(response.1)
                }
            }
        }
        callback(true, contentImageArr)
    }
    
    func downloadContent(contentId: String, callback: @escaping (Bool,UIImage) -> ()){
        
        let authToken = UserManager.sharedInstance.getToken()
        
        let parameters: Parameters = [
            "authToken": authToken,
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
                    callback(true, UIImage(named: "pp.jpg.gif")!)
                }
        }
    }
}
