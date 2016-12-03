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
                
                callback(true, UIImage(data: data)!)
        }
    }
}
