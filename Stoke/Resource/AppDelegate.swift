//
//  AppDelegate.swift
//  Stoke
//
//  Created by Admin on 23/02/21.
//

import UIKit
import IQKeyboardManagerSwift
import FBSDKCoreKit
import GoogleSignIn
import Stripe
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let shared = UIApplication.shared.delegate as! AppDelegate
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Thread.sleep(forTimeInterval: 3.0)
        AppNetworkDetector.sharedInstance.observeReachability()
        AppRouter.checkUserFlow()
        setupIQKeyboard()
        StripeAPI.defaultPublishableKey = "pk_live_51ItEh0D5W8jUwMyfUvpq9VHbuOjAjZdoJZImIwIPhiCCh1hJlHh6AvnkweqiqAHHVhoKpSV6MSw1yANywCmmf2nT00HdlwTgj3"//"pk_test_fJGQNkP8kBhUNliDBMWK1FPG"
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        GoogleLoginController.shared.configure(withClientId: AppConstants.googleApiKey)
        AWSController.setupAWS()
        FirebaseApp.configure()
        if UserModel.main.isUserLogin{
            SocketIOManager.instance.connectSocket {
                printDebug("Socket conncted...")
            }
        }
        AppDelegate.callForRegisterNotification { (flag) in
            printDebug("Permission granted....")
        }
        CommonFunctions.updateBadgeTo = 0
        return true
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
//        NotificationCenter.default.post(name: NSNotification.Name.reconnectChat, object: nil)
        
//        SocketIOManager.instance.initializeSocket()
//        SocketIOManager.instance.connectSocket {
//            let param = ["chatroomId":"6260e4a286044d0e7fa53691"]
//            SocketIOManager.instance.emit(with: .joinRoom,param)
//        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
//        NotificationCenter.default.post(name: NSNotification.Name.reconnectChat, object: nil)
        if let rootVC = AppDelegate.shared.window?.rootViewController as? UINavigationController {
            var vcArray = rootVC.viewControllers
            for vc in vcArray where vc is ChatRoomVC {
                vcArray.removeObject(vc)
                break
            }
            rootVC.viewControllers = vcArray
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
//        SocketIOManager.instance.emit(with: .didDisConnect, [:])
        
    }
    
    
    ///    Exit from all the chatrooms
    func applicationWillTerminate(_ application: UIApplication) {
        SocketIOManager.instance.emit(with: .didDisConnect, [:])
    }

    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        let scema = url.absoluteString
        if scema.contains(s: "com.stoke.beta"){
            let queryItems = URLComponents(string: url.absoluteString)?.queryItems
            let token = queryItems?.filter({$0.name == "token"}).first?.value ?? ""
            let type = queryItems?.filter({$0.name == "type"}).first
            let chatroomId = queryItems?.filter({$0.name == "chatroomId"}).first
            let checkType = type?.value ?? ""
            if checkType == "2"{
                AppRouter.openRestPassword(token)
            }else if checkType == "4"{
                if UserModel.main.isUserLogin{
                    let userId = queryItems?.filter({$0.name == "userId"}).first?.value ?? ""
                    if userId == UserModel.main.userId{
                        AppRouter.openMyProfile()
                    }else{
                        AppRouter.openUserProfile(userId)
                    }
                }
            }else if checkType == "3"{
                let roomId = chatroomId?.value ?? ""
                NotificationHandler.shared.goToRoomFromOutside(roomId)
            }
            return true
        }else{
            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
            return GoogleLoginController.shared.handleUrl(url, options: options)
        }
    }
    
    func setupIQKeyboard() {
           
           IQKeyboardManager.shared.enable = true
           IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
           IQKeyboardManager.shared.shouldResignOnTouchOutside = true
           IQBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: AppColors.themeColor,
                                                                .font: AppFonts.Regular.withSize(12)],
                                                               for: .normal)
           IQKeyboardManager.shared.toolbarTintColor = AppColors.themeColor
           UITextField.appearance().tintColor = AppColors.themeColor
           UITextView.appearance().tintColor = AppColors.themeColor
       }

}

