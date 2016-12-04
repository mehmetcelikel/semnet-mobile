//
//  PhotoLibManager.swift
//  semnet
//
//  Created by ceyda on 04/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PhotoLibManager: NSObject {
    static let sharedInstance = PhotoLibManager()

    func getImages(assetThumbnailSize: CGSize) -> (images: [UIImage], asset: PHFetchResult<PHAsset>){
    
        var assetCollection: PHAssetCollection!//album icin
        var photosAsset: PHFetchResult<PHAsset>!//albumdeki photolar icin
        
        let fetchOptions = PHFetchOptions()
        
        
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .moment, subtype: .any, options: fetchOptions)
        
        assetCollection = collection.firstObject// camera roll's data
        
        
        
        //- albumdeki fotolar
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "modificationDate",
                                                    ascending: false)]//en yenisi en tepede gozuksun
        
        
        photosAsset = PHAsset.fetchAssets(in: assetCollection, options: options)
        let imageManager = PHCachingImageManager()
        
        var images = [UIImage]()
        
        photosAsset.enumerateObjects({(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            
            if object is PHAsset{
                let asset = object as! PHAsset
                
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .fastFormat
                options.isSynchronous = true
                imageManager.requestImage(for: asset,
                                          targetSize: assetThumbnailSize,
                                          contentMode: .aspectFill,
                                          options: options,
                                          resultHandler: {
                                            image, info in
                                            images.append(image!)
                })
            }
        })
        return (images, photosAsset)
    }
}
