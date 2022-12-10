//
//  CommonClasses.swift
//  DittoFashionMarketBeta
//
//  Created by Bhavneet Singh on 23/11/17.
//  Copyright © 2017 Bhavneet Singh. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import MobileCoreServices
import SwiftMessages
import SwiftyJSON
import PassKit
import AudioToolbox


enum RequestActionType:String{
    case accept
    case decline
    case cancel
}

class CommonFunctions {
    
    static var isGuestLogin:Bool{
        return UserModel.main.isGuestAccount
    }
    static let web = NetworkLayer()
    static var isFromSignUp = false
    static var navigationTitleImageView = UIImageView()
    
    static var updateBadgeTo:Int = 0{
        didSet{
            UIApplication.shared.applicationIconBadgeNumber = updateBadgeTo
        }
    }
    
    static func checkForInternet() -> Bool{
        let flag = isNetworkReachable()
        if flag{
            return true
        }else{
            CommonFunctions.showToastWithMessage("Please check your internet connection!")
            return false
        }
    }
    
    static let loader = NVActivityIndicatorView(frame: CGRect(x: UIDevice.width/2 - 25, y: UIDevice.height/2 - 25, width: 50, height: 50), type: .circleStrokeSpin, color: AppColors.themeColor, padding: 10)
    
    /// Show Toast With Message
    static func showToastWithMessage(_ msg: String,theme:Theme = .error) {
        
        DispatchQueue.mainQueueAsync {
            
            let warning = MessageView.viewFromNib(layout: .messageView)
            warning.configureTheme(theme)
            warning.frame = CGRect(x: 0, y: 0, width: 20, height: 90)
            warning.layoutIfNeeded()
            warning.configureDropShadow()
            warning.configureContent(title: "", body: msg)
            warning.button?.isHidden = true
            var warningConfig = SwiftMessages.defaultConfig
            warning.bodyLabel?.textColor = .white
            warning.bodyLabel?.font = AppFonts.Regular.withSize(16)
            warningConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: warningConfig, view: warning)
        }
    }
    
    /// Delay Functions
    class func delay(delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when) {
            closure()
            
        }
    }
    
    /// Show Action Sheet With Actions Array
    class func showActionSheetWithActionArray(_ title: String?, message: String?,
                                              viewController: UIViewController,
                                              alertActionArray : [UIAlertAction],
                                              preferredStyle: UIAlertController.Style)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        alertActionArray.forEach{ alert.addAction($0) }
        
        DispatchQueue.mainQueueAsync {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Show Activity Loader
    class func showActivityLoader() {
        DispatchQueue.mainQueueAsync {
            if let vc = AppDelegate.shared.window?.rootViewController {
                vc.startNYLoader()
            }
        }
    }
    
    /// Hide Activity Loader
    class func hideActivityLoader() {
        DispatchQueue.mainQueueAsync {
            if let vc = AppDelegate.shared.window?.rootViewController {
                vc.stopNYLoader()
            }
        }
    }
    
    static func presentTagpopup(_ flag:Bool){
        if flag{
            CommonFunctions.showToastWithMessage("Tag saved successfully.", theme: .success)
        }else{
            CommonFunctions.showToastWithMessage("Tag removed successfully.", theme: .success)
        }
        
    }
    
    static func performActionOnTag(_ id:String,action:Bool,completion:@escaping(()->())){
        let param:JSONDictionary = ["tagId":id,"type":action ? "save" : "remove"]
        web.request(from: WebService.saveUnsaveTags, param: param, method: .PUT, header: [:], loader: false) { (data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                DispatchQueue.main.async {
                    presentTagpopup(action)
                    completion()
                }
            }
        }
    }
    
    
    static func actionOnTags(_ id:String,action:Bool,completion:@escaping(()->())){
        if action{
            performActionOnTag(id, action: action, completion: completion)
        }else{
            let vc = DeleteChatRoomPopupVC.instantiate(fromAppStoryboard: .Events)
            vc.heading = "Remove Tag?"
            vc.subheading = "Are you sure you want to remove tag?"
            vc.deleteBtnTitle = "Remove"
            vc.deleteTapped = {
                performActionOnTag(id, action: action, completion: completion)
            }
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            AppRouter.tabBar.present(vc, animated: false, completion: nil)
        }
    }
    
    
    static func actionOnFollowRequest(_ action:RequestActionType,id:String,completion:@escaping()->()){
        let param:JSONDictionary = ["type":action.rawValue,"toUserId":id]
        web.request(from: WebService.actionFollowRequest, param: param, method: .PUT, header: [:], loader: true) { (data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                    DispatchQueue.main.async {
                        completion()
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    static func deleteChatroom(_ id:String,completion:@escaping()->()){
        let param:JSONDictionary = ["chatroomId":id,"status":"deleted"]
        web.request(from: WebService.getChatRooms, param: param, method: .PUT, header: [:], loader: true) {(data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                    DispatchQueue.main.async {
                        completion()
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }

    static func vaibratePhone(){
        if #available(iOS 13.0, *) {
            Vibration.soft.vibrate()
        } else {
            Vibration.success.vibrate()
        }
    }
    
    static func updateRibbonLogic(){
        web.request(from: WebService.ribbonLogic, param: [:], method: .GET, header: [:], loader: false) { (data, e) in
            printDebug(e)
        }
    }
    
    
    static func navigateToUserProfile(_ id:String,onParent:UIViewController? = nil){
        if id == UserModel.main.userId{
            let vc = ProfileVC.instantiate(fromAppStoryboard: .Home)
            vc.isFromOutside = true
            if let v = onParent{
                v.navigationController?.pushViewController(vc, animated: true)
            }else{
                AppRouter.pushFromTabbar(vc)
            }
        }else{
            let vc = OtherUserProfileVC.instantiate(fromAppStoryboard: .Home)
            vc.userId = id
            if let v = onParent{
                v.navigationController?.pushViewController(vc, animated: true)
            }else{
                AppRouter.pushFromTabbar(vc)
            }
        }
    }
    
    
    
    class func startPaymnet(vc:PKPaymentAuthorizationViewControllerDelegate){
        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
        let paymentItem = PKPaymentSummaryItem.init(label: "Dummy Payment", amount: NSDecimalNumber(value: 1))
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
        let request = PKPaymentRequest()
            request.currencyCode = Locale.current.currencyCode ?? "USA"
            request.countryCode = "US"
            request.merchantIdentifier = "merchant.com.stoke.app" // 3
            request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
            request.supportedNetworks = paymentNetworks // 5
            request.paymentSummaryItems = [paymentItem] // 6
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
                displayDefaultAlert(title: "Error", message: "Unable to present Apple Pay authorization.")
                return
            }
            paymentVC.delegate = vc
            AppRouter.tabBar.present(paymentVC, animated: true, completion: nil)
        }
        
        
    }
    
    class func displayDefaultAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        AppRouter.tabBar.present(alert, animated: true, completion: nil)
    }
    
    
    class func guestLogin(){
        let param:JSONDictionary = ["deviceId":DeviceDetail.deviceId]
        web.request(from: WebService.guestLogin, param: param, method: .POST, header: [:]) { (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        printDebug(json)
                        UserModel.main = UserModel(json[ApiKey.data])
                        DispatchQueue.main.async {
                            AppRouter.goToHome()
                            SocketIOManager.instance.initializeSocket()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                SocketIOManager.instance.connectSocket()
                            }
                        }
                        
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    class func logoutUser(_ completion:@escaping ()->()){
        let param:JSONDictionary = ["deviceToken":""]
        web.request(from: WebService.logout, param: param, method: .POST, header: [:]) { (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        DispatchQueue.main.async {
                            UNUserNotificationCenter.current().removeAllDeliveredNotifications()

                            RealmController.shared.deleteDatabase()
                            UserModel.main = UserModel()
                            SocketIOManager.instance.closeConnection()
                            completion()
                        }
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    class func deleteAccount(_ completion:@escaping ()->()){
        let param:JSONDictionary = ["deviceToken":""]
        web.request(from: WebService.users, param: param, method: .DELETE, header: [:]) { (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        DispatchQueue.main.async {
                            UNUserNotificationCenter.current().removeAllDeliveredNotifications()

                            RealmController.shared.deleteDatabase()
                            UserModel.main = UserModel()
                            SocketIOManager.instance.closeConnection()
                            completion()
                        }
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    static func showUnFollowPopup(_ userId:String,name:String,completion:@escaping(()->())){
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.isForDelete = false
        vc.headingText = "Unfollow \(name)?"
        vc.subheadingTxt = "Are you sure you want to unfollow this user?"
        vc.firstbtnTitle = "Cancel"
        vc.secondbtnTitle = "Unfollow"
        vc.id = userId
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        vc.callback = {
            completion()
        }
        AppRouter.tabBar.present(vc, animated: false, completion: nil)
    }
        
    
    
    class func checkChatroom(_ eventId:String,completion:@escaping(Bool)->()){
        let param:JSONDictionary = ["eventId":eventId]
        web.request(from: WebService.checkChatroom, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        DispatchQueue.main.async {
                            if let code = json["statusCode"].int,code == 200{
                                completion(true)
                            }else{
                                completion(false)
                            }
                        }
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
}
