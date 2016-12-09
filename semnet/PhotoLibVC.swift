//
//  PhotoLibVC.swift
//  semnet
//
//  Created by ceyda on 04/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit
import Photos

class PhotoLibVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var headerToolbar: UIToolbar!
    @IBOutlet weak var footerToolbar: UIToolbar!
    
    var images = [UIImage]()// all photos from library
    var photosAsset: PHFetchResult<PHAsset>!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        self.picker.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.headerToolbar.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 50)
        self.headerToolbar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.headerToolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
        self.headerToolbar.isTranslucent = true
        self.headerToolbar.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let closeBtn = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(PhotoLibVC.close_click(_:)))
        closeBtn.width = screenWidth / 8
        closeBtn.tintColor = UIColor.white
        
        
        let useBtn = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(PhotoLibVC.choose_click(_:)))
        useBtn.width = screenWidth / 8
        useBtn.tintColor = UIColor.white
        
        let negativeSpacer:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeSpacer.width = (5 * screenWidth) / 8;
        
        
        headerToolbar.setItems([closeBtn, negativeSpacer, useBtn], animated: true)
        headerToolbar.sizeToFit()
        
        
        let cameraBtn = UIBarButtonItem(title: "Camera", style: .plain, target: self, action: #selector(PhotoLibVC.camera_click(_:)))
        cameraBtn.width = screenWidth / 8
        cameraBtn.tintColor = UIColor.white
        
        
        self.footerToolbar.frame = CGRect(x: 0, y: screenHeight-50, width: screenWidth, height: 50)
        self.footerToolbar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        //self.footerToolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.Any)
        //self.footerToolbar.translucent = true
        self.footerToolbar.backgroundColor = UIColor.black
        
        self.footerToolbar.setItems([cameraBtn], animated: true)
        
        self.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        self.imageView!.layer.masksToBounds = true
        self.imageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth)
        self.imageView.isUserInteractionEnabled = true
        
        self.collectionView.frame = CGRect(x: 0, y: (self.imageView.frame.maxY), width: screenWidth, height: (self.view.frame.height / 2) - 50)
        
        var assetThumbnailSize:CGSize!
        
        // Get cell size in order to fit photo into cell
        if let layout = self.collectionView!.collectionViewLayout as? UICollectionViewFlowLayout{
            layout.itemSize = CGSize(width: self.view.frame.size.width / 6, height: self.view.frame.size.width / 6)
            
            let cellSize = layout.itemSize
            
            assetThumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
        }
        
        let photoResult = PhotoLibManager.sharedInstance.getImages(assetThumbnailSize: assetThumbnailSize)
        self.images = photoResult.images
        self.photosAsset = photoResult.asset
        
        self.collectionView!.reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count;
    }
    
    //Set preview image when user clicks into a cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        getFromLibAndSetToPreviewImage(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PhotoLibCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoLibCell
        
        //!!!
        cell.imageView.image = images[indexPath.item]
        
        //Set first photo in library to preview image
        if indexPath.item == 0 {
            getFromLibAndSetToPreviewImage(indexPath.item)
        }
        return cell
    }
    
    func getFromLibAndSetToPreviewImage(_ index:Int){
        let imageSize = self.imageView.frame.size;
        
        let asset: PHAsset = self.photosAsset[index]
        
        PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
            if let image = result {
                self.imageView.image = image
            }
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //cekilen fotoyu albume kaydet
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //pickedimage kamera tarafindan cekilen foto
        if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            let selectorToCall = #selector(PhotoLibVC.imageWasSavedSuccessfully(_:didFinishSavingWithError:context:))
            //cekilen tum fotoları albume kaydeder
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, selectorToCall, nil)
            //self.previewImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imageWasSavedSuccessfully(_ image: UIImage, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer){
        if let theError = error {
            print("An error happened while saving the image = \(theError)")
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
                self.imageView.image = image
            })
        }
    }
    
    @IBAction func camera_click(_ sender: AnyObject) {
        //rear means arka kamera acar
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            present(picker, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }

    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(alertVC,
                animated: true,
                completion: nil)
    }
    
    func choose_click(_ sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        let home = storyboard.instantiateViewController(withIdentifier: "NewPostVC") as! NewPostVC
        
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Selection", message: nil, preferredStyle: .actionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let whatAction: UIAlertAction = UIAlertAction(title: "Choose Photo?", style: .default) { action -> Void in
            
            home.image = self.imageView.image
            self.present(home, animated: true, completion: nil)
        }
        actionSheetController.addAction(whatAction)
        //Create and add a second option action
        let whereAction: UIAlertAction = UIAlertAction(title: "Continue without a photo?", style: .default) { action -> Void in
            
            home.image = nil
            self.present(home, animated: true, completion: nil)
        }
        actionSheetController.addAction(whereAction)
        
        
        // need to provide a popover
        actionSheetController.popoverPresentationController?.sourceView = sender as AnyObject as? UIView;
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    
    }
    
    func close_click(_ sender: AnyObject) {
        
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "tabBar") as! TabBarVC
        
        
        self.navigationController?.pushViewController(followings, animated: true)
        
        //performSegueWithIdentifier("returnFromPhotoToNav", sender: nil)
    }
}
