//
//  SocialSignupVM.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import Foundation
import SwiftyJSON

class SocialSignupVM{
    
    var fbmodel:FacebookModel!
    var googlemodel:GoogleUser!
    var appleModel:AppleModel!
    var type:SignupType!
    let web:NetworkLayer!
    var isUsernamevailable:Bool = false
    var userName = "" {
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.verifyUsername()
            }
        }
    }
    var verified:((Bool,String)->())?
    
    init(_ web:NetworkLayer, type:SignupType){
        self.web = web
        self.type = type
    }
    
    
    func validateUsername() -> Bool{
        if userName.isEmpty{
            CommonFunctions.showToastWithMessage("Please enter a valid username")
            return false
        }else if userName.count < 3{
            CommonFunctions.showToastWithMessage("Username must have at-least 3 characters")
            return false
        }else if userName.count > 30{
            CommonFunctions.showToastWithMessage("Username can not be grater than 30 characters")
            return false
        }else if userName.checkIfInvalid(.userName){
            CommonFunctions.showToastWithMessage("Username must not only contain digits and avoid using @")
            return false
        }else{
            return true
        }
    }
    
    func verifyUsername(){
        guard validateUsername() else { return }
        guard CommonFunctions.checkForInternet() else {
            if let verify = verified { verify(true,"") }
            return
        }
        let param:JSONDictionary = ["userName":userName]
        web.request(from: WebService.username, param: param, method: .POST, header: [:],loader:false) { [weak self] (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    self?.isUsernamevailable = json[ApiKey.code].intValue == 200
                    let msg = json[ApiKey.message].stringValue
                    if let verify = self?.verified { verify(self?.isUsernamevailable ?? false,msg) }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitSocail(_ isOld:Bool = false){
        if !isOld{
            guard isUsernamevailable else { CommonFunctions.showToastWithMessage("Username is already taken")
                return
            }
        }
        var param:JSONDictionary = [:]
        switch type {
        case .facebook:
            param["socialLoginType"] = "facebook"
            param["firstName"] = fbmodel.first_name
            param["lastName"] = fbmodel.last_name
            param["socialId"] = fbmodel.id
            param["email"] = fbmodel.email
        case .google:
            param["socialLoginType"] = "google"
            param["firstName"] = googlemodel.firstname
            param["lastName"] = googlemodel.lastname
            param["socialId"] = googlemodel.id
            param["email"] = googlemodel.email
        default:
            param["socialLoginType"] = "apple"
            param["firstName"] = appleModel.fName
            param["lastName"] = appleModel.lastName
            param["socialId"] = appleModel.id
            param["email"] = appleModel.email
        }
        if !isOld{
            param["userName"] = userName
        }
        param["deviceId"] = DeviceDetail.deviceId
        param["deviceToken"] = DeviceDetail.deviceToken
        param["latitude"] = 0
        param["longitude"] = 0
        param["address"] = ""
        web.request(from: WebService.socailLogin, param: param, method: .POST, header: [:]) { (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    UserModel.main = UserModel(json["data"])
                    DispatchQueue.main.async {
                        SocketIOManager.instance.initializeSocket()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            SocketIOManager.instance.connectSocket()
                        }
                    }
                    DispatchQueue.main.async {
                        AppRouter.goToHome()
                    }
                    
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
}
