//
//  AppleController.swift
//  BrightsiteBeta
//
//  Created by Arpit Srivastava on 11/05/20.
//  Copyright © 2020 Arpit Srivastava. All rights reserved.
//

import Foundation
import AuthenticationServices
import SwiftyJSON

struct AppleModel {
    var id:String = ""
    var fName:String = ""
    var lastName:String = ""
    var email:String = ""
}

struct VerifyAccModel {
    var id:String = ""
    var mobileNumber:String = ""
    var countryCode:String = ""
    var email:String = ""
    
    init(_ json:JSON){
        mobileNumber = json["mobileNumber"].stringValue
        id = json["id"].stringValue
        countryCode = json["countryCode"].stringValue
        email = json["email"].stringValue
    }
}

class AppleController:NSObject{
    
    static let shared = AppleController()
    
    private override init(){}
    
    var gettingData:((AppleModel)->())?
    
    func handelAuthentication(){
        if #available(iOS 13.0, *) {
            CommonFunctions.showActivityLoader()
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
            CommonFunctions.showToastWithMessage("Required iOS version 13 or more")
        }
    }
}

extension AppleController : ASAuthorizationControllerDelegate{
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        CommonFunctions.hideActivityLoader()
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = (appleIDCredential.fullName?.givenName ?? "") + " " + (appleIDCredential.fullName?.familyName ?? "")
            var ob = AppleModel()
            ob.email = appleIDCredential.email ?? ""
            ob.fName = appleIDCredential.fullName?.givenName ?? ""
            ob.lastName = appleIDCredential.fullName?.familyName ?? ""
            ob.id = appleIDCredential.user
            if let data = gettingData { data(ob)}        
        }
        
        @available(iOS 13.0, *)
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            CommonFunctions.hideActivityLoader()
            CommonFunctions.showToastWithMessage(error.localizedDescription)
        }
    }
}
