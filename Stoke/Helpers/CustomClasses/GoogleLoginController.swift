
//  GoogleLoginController.swift
//  GoogleLogin
//
//  Created by Appinventiv on 10/09/17.
//  Copyright © 2017 Appinventiv. All rights reserved.

import GoogleSignIn
import UIKit

class GoogleLoginController : NSObject {
    
    // MARK: Variables and properties...
    static let shared = GoogleLoginController()
    fileprivate(set) var currentGoogleUser: GoogleUser?
    fileprivate weak var contentViewController:UIViewController!
    
    
    var success : ((_ googleUser : GoogleUser) -> ())?
    var failure : ((_ error : Error) -> ())?
    
    private override init() {}
    
    func configure(withClientId clientId:String){
        
        GIDSignIn.sharedInstance().clientID = clientId
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func handleUrl(_ url: URL, options: [UIApplication.OpenURLOptionsKey : Any])->Bool{
        
        return GIDSignIn.sharedInstance().handle(url)
    }
    // MARK: - Method for google login...
    // MARK: ============================
    func login(fromViewController viewController : UIViewController = (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController!,
               success : @escaping(_ googleUser : GoogleUser) -> (),
               failure : @escaping(_ error : Error) -> ()) {
        
        //GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
                
        contentViewController = viewController
        self.success = success
        self.failure = failure
    }
    
    func logout(){
        GIDSignIn.sharedInstance().signOut()
    }
}

// MARK: - GIDSignInUIDelegate and GIDSignInDelegate delegare methods...
// MARK: ===============================================================
extension GoogleLoginController : GIDSignInDelegate {
    
    // MARK: To get user details like name, email etc.
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if (error == nil) {
            
            let googleUser = GoogleUser(user)
            currentGoogleUser = googleUser
            success?(googleUser)
            
        } else {
            failure?(error)
        }
        success = nil
        failure = nil
    }
    
    // MARK: - To present to your controller
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        contentViewController.present(viewController, animated: true, completion: nil)
    }
    
    // MARK: - To dismiss from your controller
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        contentViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Model class to store the user information...
// MARK: ==============================================
class GoogleUser {
    
    let id: String
    let name: String
    let email: String
    let image: URL?
    let firstname: String
    let lastname: String
    
    required init(_ googleUser: GIDGoogleUser) {
        
        id = googleUser.userID
        name = googleUser.profile.name
        firstname = String(name.split(separator: " ").first ?? "")
        lastname = String(name.split(separator: " ").last ?? "")
        email = googleUser.profile.email
        image = googleUser.profile.imageURL(withDimension: 200)
    }
    
    var dictionaryObject: [String:Any] {
        var dictionary          = [String:Any]()
        dictionary["_id"]       = id
        dictionary["email"]     = email
        dictionary["image"]     = image?.absoluteString ?? ""
        dictionary["name"]      = name
        return dictionary
    }
}

