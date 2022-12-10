//
//  UIViewControllerExtension.swift
//  WashApp
//
//  Created by Saurabh Shukla on 19/09/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary
import AVFoundation
import Photos
import MobileCoreServices
import NVActivityIndicatorView

extension UIViewController  {
    
    typealias ImagePickerDelegateController = (UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate)
    
    func captureImage(delegate controller: ImagePickerDelegateController,
                      photoGallery: Bool = true,
                      camera: Bool = true,
                      mediaType : [String] = [kUTTypeImage as String]) {
        
        self.checkAndOpenLibrary(delegate: controller, mediaType: mediaType)
        
//        let chooseOptionText =  "Select option"
//        let alertController = UIAlertController(title: chooseOptionText, message: nil, preferredStyle: .actionSheet)
//
//        if photoGallery {
//
//            let chooseFromGalleryText =  "Open Gallery"
//            let alertActionGallery = UIAlertAction(title: chooseFromGalleryText, style: .default) { _ in
//                self.checkAndOpenLibrary(delegate: controller, mediaType: mediaType)
//            }
//            alertController.addAction(alertActionGallery)
//        }
        
//        if camera {
//
//            let takePhotoText =  "Open Camera"
//            let alertActionCamera = UIAlertAction(title: takePhotoText, style: .default) { action in
//                self.checkAndOpenCamera(delegate: controller, mediaType: mediaType)
//            }
//            alertController.addAction(alertActionCamera)
//        }
        
//        let cancelText =  "Cancel"
//        let alertActionCancel = UIAlertAction(title: cancelText, style: .cancel) { _ in
//        }
//        alertController.addAction(alertActionCancel)
//        controller.present(alertController, animated: true, completion: nil)
    }
    
    func checkAndOpenCamera(delegate controller: ImagePickerDelegateController,mediaType : [String] = [kUTTypeImage as String]) {
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
            
        case .authorized:
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = controller
            imagePicker.mediaTypes = mediaType
            imagePicker.videoMaximumDuration = 15
            let sourceType = UIImagePickerController.SourceType.camera
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                
                imagePicker.sourceType = sourceType
                imagePicker.allowsEditing = false
                
                if imagePicker.sourceType == .camera {
                    imagePicker.showsCameraControls = true
                }
                controller.present(imagePicker, animated: true, completion: nil)
                
            } else {
                
                let cameraNotAvailableText = "Camera Not Available"
                self.showAlert(title: "Error", msg: cameraNotAvailableText)
            }
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
                
                if granted {
                    
                    DispatchQueue.main.async {
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = controller
                        imagePicker.mediaTypes = mediaType
                        imagePicker.videoMaximumDuration = 15
                        
                        let sourceType = UIImagePickerController.SourceType.camera
                        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                            
                            imagePicker.sourceType = sourceType
                            if imagePicker.sourceType == .camera {
                                imagePicker.allowsEditing = false
                                imagePicker.showsCameraControls = true
                            }
                            controller.present(imagePicker, animated: true, completion: nil)
                            
                        } else {
                            let cameraNotAvailableText = "Camera Not Available"
                            self.showAlert(title: "Error", msg: cameraNotAvailableText)
                        }
                    }
                }
            })
            
        case .restricted:
            alertPromptToAllowCameraAccessViaSetting("Restricted From Using Camera")
            
        case .denied:
            alertPromptToAllowCameraAccessViaSetting("Change Privacy Setting And Allow Access To Camera")
        }
    }
    
    func checkAndOpenLibrary(delegate controller: ImagePickerDelegateController,mediaType : [String] = [kUTTypeImage as String]) {
        
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
            
        case .notDetermined:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = controller
            imagePicker.mediaTypes = mediaType
            let sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = false
            imagePicker.videoMaximumDuration = 15
            
            controller.present(imagePicker, animated: true, completion: nil)
            
        case .restricted:
            alertPromptToAllowCameraAccessViaSetting("Restricted From Using Library")
            
        case .denied:
            alertPromptToAllowCameraAccessViaSetting("Change Privacy Setting And Allow Access To Library")
            
        case .authorized:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = controller
            let sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = false
            imagePicker.mediaTypes = mediaType
            imagePicker.videoMaximumDuration = 15
            
            controller.present(imagePicker, animated: true, completion: nil)
        @unknown default:
            printDebug("Unknown case ---------->>>>>>")
        }
    }
    
    private func alertPromptToAllowCameraAccessViaSetting(_ message: String) {
        
        let alertText = "Alert"
        let cancelText = "Cancel"
        let settingsText = "Settings"
        
        let alert = UIAlertController(title: alertText, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: settingsText, style: .default, handler: { (action) in
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    ///Adds Child View Controller to Parent View Controller
    func add(childViewController:UIViewController){
        
        self.addChild(childViewController)
        childViewController.view.frame = self.view.bounds
        self.view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }
    
    ///Removes Child View Controller From Parent View Controller
    var removeFromParent:Void{
        
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    ///Updates navigation bar according to given values
    func updateNavigationBar(withTitle title:String? = nil, leftButton:UIBarButtonItem? = nil, rightButton:UIBarButtonItem? = nil, tintColor:UIColor? = nil, barTintColor:UIColor? = nil, titleTextAttributes: [NSAttributedString.Key : Any]? = nil){
        
        self.navigationController?.isNavigationBarHidden = false
        if let tColor = barTintColor{
            self.navigationController?.navigationBar.barTintColor = tColor
        }
        if let tColor = tintColor{
            self.navigationController?.navigationBar.tintColor = tColor
        }
        if let button = leftButton{
            self.navigationItem.leftBarButtonItem = button;
        }
        if let button = rightButton{
            self.navigationItem.rightBarButtonItem = button;
        }
        if let ttle = title{
            self.title = ttle
        }
        if let ttleTextAttributes = titleTextAttributes{
            self.navigationController?.navigationBar.titleTextAttributes =   ttleTextAttributes
        }
    }
    ///Not using static as it won't be possible to override to provide custom storyboardID then
    class var storyboardID : String {
        
        return "\(self)"
    }
    
    //function to pop the target from navigation Stack
    @objc func pop(animated:Bool = true) {
        _ = self.navigationController?.popViewController(animated: animated)
    }
    
    func popToSpecificViewController(atIndex index:Int, animated:Bool = true) {
        
        if let navVc = self.navigationController, navVc.viewControllers.count > index{
            
            _ = self.navigationController?.popToViewController(navVc.viewControllers[index], animated: animated)
        }
    }
    
    func showAlert( title : String = "", msg : String,_ completion : (()->())? = nil) {
        
        let alertViewController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action : UIAlertAction) -> Void in
            
            alertViewController.dismiss(animated: true, completion: nil)
            completion?()
        }
        
        alertViewController.addAction(okAction)
        
        self.present(alertViewController, animated: true, completion: nil)
        
    }
    
    /// Start Loader
    // Start Loader
    func startNYLoader() {
        self.view.addSubview(CommonFunctions.loader)
        CommonFunctions.loader.startAnimating()
    }
    
    func stopNYLoader(){
        CommonFunctions.loader.stopAnimating()
        CommonFunctions.loader.removeFromSuperview()
       
    }
}
