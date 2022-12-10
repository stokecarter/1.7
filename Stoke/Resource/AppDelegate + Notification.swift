//
//  AppDelegate + Notification.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import Foundation
import UserNotifications
import SwiftyJSON

extension AppDelegate: UNUserNotificationCenterDelegate{
    
    
    
    static func callForRegisterNotification(isForced:Bool = false,_ completion:@escaping (Bool)->()){
        AppDelegate.shared.registerForRemoteNotification() { flag in
            completion(flag)
        }
    }
    
    private func alertPromptToAllowNotificationViaSetting(_ message: String,_ completion:@escaping ()->()) {
        
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
        alert.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: { (action) in
            
            completion()
        }))
        AppDelegate.shared.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    func registerForRemoteNotification(isForced:Bool = true,_ completion:@escaping (Bool)->()){
        checkPermission { (flag) in
            if flag{
                
                completion(flag)
            }else{
                if isForced{
                DispatchQueue.main.async { [weak self] in
                    self?.alertPromptToAllowNotificationViaSetting("Change Privacy Setting And Allow to send Push Notifications."){
                        completion(flag)
                    }
                }
                }else{
                    
                }
            }
        }
    }
    
    func checkPermission(completion:@escaping((Bool)->())){
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
            if (granted)
            {
                DispatchQueue.main.async { // Correct //change for ios11
                    UIApplication.shared.registerForRemoteNotifications()
                    completion(true)
                }
            }
            else{
                completion(false)
            }
        })
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        printDebug("Successfully Registered")
        let tat = deviceToken.map{ data in String(format: "%02.2hhx", data) }.joined()
        DeviceDetail.deviceToken = tat
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        CommonFunctions.showToastWithMessage("Failed to register for push notification: \(error)")
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as NSDictionary
        let d = JSON(dict)
        if UserModel.main.isAdmin{
            AppRouter.goToNotifications()
        }else{
            if (PushTypes(rawValue: d["data"]["notificationType"].intValue) ?? .requestToJoin) == .celebrityPush{
                AppUserDefaults.save(value: d["data"]["data"]["typeData"]["isCelebrity"].boolValue, forKey: .isCelibrity)
                NotificationCenter.default.post(name: Notification.Name("celebrityApproval"), object: nil)
            }else{
                if let vc = AppDelegate.shared.window?.rootViewController as? UINavigationController, let visibleVC = vc.visibleViewController{
                    
                    NotificationHandler.shared.handelNavigation(d)
                }
            }
        }
        completionHandler(.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        if UserModel.main.isUserLogin{
            completionHandler([.alert,.sound,.badge])
            
        }
    }
    
}
