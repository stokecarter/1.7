//
//  Router.swift
//  FirebaseChatDemo
//
//  Created by Bhavneet Singh on 29/07/18.
//  Copyright © 2018 Bhavneet Singh. All rights reserved.
//

import UIKit
import SwiftyJSON

enum AppRouter {
    
    static var tabBar:TabbarVC!
    
    static func checkUserFlow(){
        if !UserModel.main.isUserLogin {
            if AppUserDefaults.value(forKey: .tutorialDisplayed).boolValue{
                goToWelcomeScreen()
            }else{
                goToTutorials()
            }
        }else{
            if UserModel.main.isGuestAccount{
                UserModel.main = UserModel()
                checkUserFlow()
            }else{
                goToHome()
            }
        }
    }
    
    static func logoutUser(){
        UserModel.main = UserModel()
        checkUserFlow()
    }
    
    /// Go To Home Screen
    
    
    static func goToTutorials(){
        let vc = TutorialView.instantiate(fromAppStoryboard: .Main)
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isNavigationBarHidden = true
        UIView.transition(with: AppDelegate.shared.window!, duration: 0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController =  nvc
        }, completion: { (finished) in
            UIApplication.shared.registerForRemoteNotifications()
        })

        AppDelegate.shared.window?.becomeKey()
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
    static func goToWelcomeScreen(){
        let vc = WelcomeVC.instantiate(fromAppStoryboard: .Main)
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isNavigationBarHidden = true

        UIView.transition(with: AppDelegate.shared.window!, duration: 0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController =  nvc
        }, completion: { (finished) in
            UIApplication.shared.registerForRemoteNotifications()
        })

        AppDelegate.shared.window?.becomeKey()
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
    static func goToLoginScreen(){
        let vc = LoginVC.instantiate(fromAppStoryboard: .Main)
        vc.isRoot = true
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isNavigationBarHidden = true
        UIView.transition(with: AppDelegate.shared.window!, duration: 0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController =  nvc
        }, completion: { (finished) in
            UIApplication.shared.registerForRemoteNotifications()
        })
        AppDelegate.shared.window?.becomeKey()
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
    static func goToSignupScreen(){
        let vc = SignUpVC.instantiate(fromAppStoryboard: .Main)
        vc.isRoot = true
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isNavigationBarHidden = true

        UIView.transition(with: AppDelegate.shared.window!, duration: 0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController =  nvc
        }, completion: { (finished) in
            UIApplication.shared.registerForRemoteNotifications()
        })

        AppDelegate.shared.window?.becomeKey()
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
    
    static func openRestPassword(_ token:String){
        let vc = ChangePasswordVC.instantiate(fromAppStoryboard: .Main)
        vc.token = token
        vc.isEmail = true
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isNavigationBarHidden = false

        UIView.transition(with: AppDelegate.shared.window!, duration: 0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController =  nvc
        }, completion: { (finished) in
            UIApplication.shared.registerForRemoteNotifications()
        })

        AppDelegate.shared.window?.becomeKey()
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
    static func openUserProfile(_ id:String){
        let vc = OtherUserProfileVC.instantiate(fromAppStoryboard: .Home)
        vc.userId = id
        vc.isFromLink = true
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isNavigationBarHidden = false
        UIView.transition(with: AppDelegate.shared.window!, duration: 0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController =  nvc
        }, completion: { (finished) in
            UIApplication.shared.registerForRemoteNotifications()
        })
        AppDelegate.shared.window?.becomeKey()
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
    static func openMyProfile(){
        tabBar = TabbarVC.instantiate(fromAppStoryboard: .Home)
        tabBar.selectedIndex = 4
        let nvc = UINavigationController(rootViewController: tabBar)
        nvc.isNavigationBarHidden = false
        UIView.transition(with: AppDelegate.shared.window!, duration: 0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController =  nvc
        }, completion: { (finished) in
            UIApplication.shared.registerForRemoteNotifications()
        })
        AppDelegate.shared.window?.becomeKey()
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
    static func goToMyrooms(){
        tabBar = TabbarVC.instantiate(fromAppStoryboard: .Home)
        tabBar.selectedIndex = 2
        let nvc = UINavigationController(rootViewController: tabBar)
        nvc.isNavigationBarHidden = false
        UIView.transition(with: AppDelegate.shared.window!, duration:0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController =  nvc
        }, completion: { (finished) in
            UIApplication.shared.registerForRemoteNotifications()
        })

        AppDelegate.shared.window?.becomeKey()
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
    static func goToNotifications(){
        tabBar = TabbarVC.instantiate(fromAppStoryboard: .Home)
        tabBar.selectedIndex = 3
        let nvc = UINavigationController(rootViewController: tabBar)
        nvc.isNavigationBarHidden = false
        UIView.transition(with: AppDelegate.shared.window!, duration:0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController =  nvc
        }, completion: { (finished) in
            UIApplication.shared.registerForRemoteNotifications()
        })

        AppDelegate.shared.window?.becomeKey()
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
    static func goToHome() {
        
        tabBar = TabbarVC.instantiate(fromAppStoryboard: .Home)
        let nvc = UINavigationController(rootViewController: tabBar)
        nvc.isNavigationBarHidden = false
        UIView.transition(with: AppDelegate.shared.window!, duration:0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController =  nvc
        }, completion: { (finished) in
            UIApplication.shared.registerForRemoteNotifications()
        })

        AppDelegate.shared.window?.becomeKey()
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
    
    /// Go To Any View Controller
    static func goToVC(viewController: UIViewController) {
        
        let nvc = UINavigationController(rootViewController: viewController)
        nvc.isNavigationBarHidden = true
        nvc.automaticallyAdjustsScrollViewInsets = false
        UIView.transition(with: AppDelegate.shared.window!, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController = nvc
        }, completion: nil)
        AppDelegate.shared.window?.becomeKey()
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
    static func pushViewController(_ fromVC:BaseVC,_ toVC:BaseVC, _ instant: Bool = false ){
        fromVC.navigationController?.pushViewController(toVC, animated: (instant ? false : true))
    }
    
    static func pushFromTabbar(_ toVc:UIViewController,_ instant: Bool = false ){
        AppRouter.tabBar.navigationController?.pushViewController(toVc, animated: instant)
    }
}
