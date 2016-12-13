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
                    
                    labelArray.append(SemanticLabel(label: label, clazz: clazz))
                    
                }
                callback(true, labelArray)
        }
    }
}
