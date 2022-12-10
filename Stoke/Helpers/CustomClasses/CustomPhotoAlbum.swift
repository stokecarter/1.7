//
//  CustomPhotoAlbum.swift
//  Gospic
//
//  Created by Appinventiv on 27/09/17.
//
import Foundation
import Photos
import UIKit

class CustomPhotoAlbum: NSObject {
    
    // MARK:- Static Variables
    //==========================
    static let albumName = LocalizedString.appTitle.localized.uppercased()
    static let shared = CustomPhotoAlbum()
    
    // MARK:- Variables
    //===================
    private var assetCollection: PHAssetCollection!
    
    // MARK:- Initializer
    //===================
    private override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    ///Save Image in PHOTOS
    func saveImage(imageFileUrl: URL) {
        self.requestPermissions { (success) in
            if success {
                if let assetCollection = self.fetchAssetCollectionForAlbum() {
                    // Album already exists
                    self.assetCollection = assetCollection
                    PHPhotoLibrary.shared().performChanges({
                        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: imageFileUrl)
                        let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                        let enumeration: NSArray = [assetPlaceHolder!]
                        albumChangeRequest!.addAssets(enumeration)
                        DispatchQueue.main.async {
                            CommonFunctions.showToastWithMessage(LocalizedString.successfullySaved.localized)
                        }
                    }, completionHandler: nil)
                } else {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
                    }) { success, error in
                        if success {
                            self.assetCollection = self.fetchAssetCollectionForAlbum()
                            PHPhotoLibrary.shared().performChanges({
                                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: imageFileUrl)
                                let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
                                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                                let enumeration: NSArray = [assetPlaceHolder!]
                                albumChangeRequest!.addAssets(enumeration)
                                DispatchQueue.main.async {
                                    CommonFunctions.showToastWithMessage(LocalizedString.successfullySaved.localized)
                                }
                            }, completionHandler: nil)
                        } else {
                            // Unable to create album
                        }
                    }
                }
            }
        }
    }
    
    ///Save Video in PHOTOS
    func saveVideo(videoFileUrl: URL) {
        self.requestPermissions { (success) in
            if success {
                if let assetCollection = self.fetchAssetCollectionForAlbum() {
                    // Album already exists
                    self.assetCollection = assetCollection
                    PHPhotoLibrary.shared().performChanges({
                        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoFileUrl)
                        let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                        let enumeration: NSArray = [assetPlaceHolder!]
                        albumChangeRequest!.addAssets(enumeration)
                        DispatchQueue.main.async {
                            CommonFunctions.showToastWithMessage(LocalizedString.successfullySaved.localized)
                        }
                    }, completionHandler: nil)
                } else {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
                    }) { success, error in
                        if success {
                            self.assetCollection = self.fetchAssetCollectionForAlbum()
                            PHPhotoLibrary.shared().performChanges({
                                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoFileUrl)
                                let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
                                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                                let enumeration: NSArray = [assetPlaceHolder!]
                                albumChangeRequest!.addAssets(enumeration)
                                DispatchQueue.main.async {
                                    CommonFunctions.showToastWithMessage(LocalizedString.successfullySaved.localized)
                                }
                            }, completionHandler: nil)
                        } else {
                            // Unable to create album
                        }
                    }
                }
            }
        }
    }
}

// MARK:- Private Functions
//===========================
extension CustomPhotoAlbum {
    
    /// Request Permission for PHPhotoLibrary
    public func requestPermissions(completion: @escaping ((_ isAuthorized: Bool) -> Void)) {
        
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            
            switch status {
            case .authorized: completion(true)
            case .restricted, .denied:
                
                let cancelBtn = UIAlertAction(title: LocalizedString.cancel.localized, style: .cancel, handler: nil)
                let settingBtn = UIAlertAction(title: LocalizedString.settings.localized, style: .default, handler: { (action) in
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                })
                
                let alertController = UIAlertController(title: LocalizedString.sorry.localized, message: LocalizedString.restrictedFromUsingLibrary.localized, preferredStyle: .alert)
                
                alertController.addAction(cancelBtn)
                alertController.addAction(settingBtn)
                
                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alertController, animated: true, completion: nil)
                
                completion(false)
            case .notDetermined: self?.requestPermissions(completion: completion)
            @unknown default:
                printDebug("Do nothing...")
            }
        }
    }

    /// Fetch Asset Collection For Album
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
}
