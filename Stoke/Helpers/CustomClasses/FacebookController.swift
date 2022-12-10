//
//  FacebookController.swift
//  FacebookLogin
//
//  Created by Arpit Srivastava on 28/06/19.
//  Copyright © 2019 Arpit Srivastava. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Social
import Accounts
import SwiftyJSON

class FacebookController {
    
    // MARK:- VARIABLES
    //==================
    static let shared = FacebookController()
    var facebookAccount: ACAccount?
    private init() {}
    
    // MARK:- FACEBOOK LOGIN
    //=========================
    private func loginWithFacebook(fromViewController viewController: UIViewController, completion: @escaping LoginManagerLoginResultBlock) {
        
        if let _ = AccessToken.current {
            
            facebookLogout()
            
        }
        
        let permissions = ["email","public_profile"]//,"user_friends"]
        
        let login = LoginManager()
        //        login.loginBehavior = .
        
        login.logIn(permissions: permissions, from: viewController) { (result, error) in
            if let res = result,res.isCancelled {
                completion(nil,error)
            }else{
                completion(result,error)
            }
        }
    }
    
    // MARK:- GET FACEBOOK USER INFO
    //================================
    func getFacebookUserInfo(fromViewController viewController: UIViewController,
                             success: @escaping ((FacebookModel) -> Void),
                             failure: @escaping ((Error?) -> Void)) {
        
        self.loginWithFacebook(fromViewController: viewController, completion: { (result, error) in
            
            if error == nil,let _ = result?.token {
                self.getInfo(success: { (result) in
                    success(result)
                }, failure: { (e) in
                    failure(e)
                })
                
            }
        })
    }
    
    private func getInfo(success: @escaping ((FacebookModel) -> Void),
                         failure: @escaping ((Error?) -> Void)){
        let params = ["fields": "email, first_name, last_name, gender, picture"]
        _ = GraphRequest(graphPath: "me", parameters: params).start(completionHandler: {
            connection, result, error in
            
            if let result = result as? [String : Any] {
                success(FacebookModel(withDictionary: result))
            } else {
                failure(error)
            }
        })
    }
    
    
//    private func getFacebookFriendList(vc:UIViewController,
//                                       sucess: @escaping (JSON)->(),
//                                       failure: @escaping (Error?)->()){
//        self.loginWithFacebook(fromViewController: vc, completion: { (result, error) in
//            if error == nil,let _ = result?.token {
//                self.getInfo(success: { (result) in
//                    //                    let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
//                    let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
//                    let _ = GraphRequest(graphPath: "\(result.id)/friends", parameters: params).start { (connection, result, error) in
//                        if let result = result as? [String:Any]{
//                            sucess(JSON(result))
//                        }else{
//                            failure(error!)
//                        }
//                    }
//                }, failure: { (e) in
//                    failure(e)
//                })
//            }
//        })
//    }
    
    // 100011902534718
    
    // MARK:- GET IMAGE FROM FACEBOOK
    //=================================
//    private func getProfilePicFromFacebook(userId:String,_ completionBlock:@escaping (UIImage?)->Void){
//
//        guard let url = URL(string:"https://graph.facebook.com/\(userId)/picture?type=large") else {
//            return
//        }
//
//
//        let request = SLRequest(forServiceType: SLServiceTypeFacebook, requestMethod: SLRequestMethod.GET, url: url, parameters: nil)
//        request?.account = self.facebookAccount
//
//        request?.perform(handler: { (responseData: Data?, _, error: Error?) in
//            if let data = responseData{
//                let userImage=UIImage(data: data)
//                completionBlock(userImage)
//            }
//        })
//    }
    
    
    
    
    // MARK:- FACEBOOK LOGOUT
    //=========================
    func facebookLogout(){
        LoginManager().logOut()
        let cooki  : HTTPCookieStorage! = HTTPCookieStorage.shared
        if let strorage = HTTPCookieStorage.shared.cookies{
            for cookie in strorage{
                cooki.deleteCookie(cookie)
            }
        }
    }
    
}
//
//// MARK: FACEBOOK MODEL
////=======================
struct FacebookModel {
    var dictionary : [String:Any]!
    var id = ""
    var email = ""
    var name = ""
    var first_name = ""
    var last_name = ""
    var currency = ""
    var link = ""
    var gender = ""
    var verified = ""
    var picture = ""
    var is_verified : Bool
    var socialType = "1"
    
    init(withDictionary dict: [String:Any]) {
        
        self.dictionary = dict
        
        self.id = "\(dict["id"] ?? "")"
        self.name = "\(dict["name"] ?? "")"
        self.first_name = "\(dict["first_name"] ?? "")"
        self.email = "\(dict["email"] ?? "")"
        self.gender = "\(dict["gender"] ?? "")"
        
        if let currencyDict = dict["currency"] as? [String:Any] {
            
            self.currency = "\(currencyDict["user_currency"] ?? "")"
            
        }
        self.picture = "https://graph.facebook.com/\(self.id)/picture?width=600"
        
        self.link = "\(dict["link"] ?? "")"
        self.last_name = "\(dict["last_name"] ?? "")"
        self.is_verified = "\(dict["is_verified"] ?? "")" == "0" ? false : true
        
    }
}

