//
//  SignupVM.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import Foundation
import SwiftyJSON

protocol SignupProtocol:AnyObject {
    func verifyUsername()
    
}

class SignupVM : SignupProtocol{
    
    enum VerifyBy{
        case phone
        case email
    }
    
    var isUsernamevailable:Bool = false
    var enteredOtp:String = ""
    var type:VerifyBy = .email
    var proceedToOtp:((String)->())?
    var showEmailVerifyPopup:(()->())?
    
    var userName = "" {
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.verifyUsername()
            }
        }
    }
    var password:String = ""
    var email = ""
    var phoneNo = ""
    
    private var web:NetworkLayer!
    var verified:((Bool,String)->())?
    
    
    init(_ web:NetworkLayer){
        self.web = web
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
    
    func validateEmail() -> Bool {
        if email.isEmpty{
            CommonFunctions.showToastWithMessage("Please enter the email address.")
            return false
        }else if email.checkIfInvalid(.email){
            CommonFunctions.showToastWithMessage("Please enter a valid email.")
            return false
        }else{
            return true
        }
    }
    
    func validatePhone() -> Bool {
        let actualNo = phoneNo.replace(string: "-", withString: "")
        if actualNo.isEmpty{
            CommonFunctions.showToastWithMessage("Please enter the phone number.")
            return false
        }else if actualNo.count<6{
            CommonFunctions.showToastWithMessage("Number should be at least 6 digits")
            return false
        } else if actualNo.checkIfInvalid(.mobileNumber){
            CommonFunctions.showToastWithMessage("Please enter a valid phone mumber")
            return false
        }else{
            return true
        }
    }
    
    func vaildatePageOne() ->Bool{
        var msg = ""
        if password.isEmpty{
            msg = "Please enter the password"
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else if password.count < 8{
            msg = "Password must be 8 characters."
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else if password.count > 30{
            msg = "Password can not be grater than 30 characters"
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else if userName.isEmpty{
            msg = "Please enter a valid username"
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else if userName.count < 3{
            msg = "Username must have at-least 3 characters"
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else if userName.checkIfInvalid(.userName){
            msg = "Username must not only contain digits and avoid using @"
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else if userName.count > 30{
            msg = "Username can not be grater than 30 characters"
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else if userName.isNumeric {
            msg = "Username must not only contain digits and avoid using @"
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else if !isUsernamevailable{
            msg = "Username is already taken."
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else{
            return true
            
        }
    }
    
    
    func verifyUsername(){
        guard validateUsername() else {
            if let verify = verified { verify(true,"") }
            return }
        guard CommonFunctions.checkForInternet() else {
            if let verify = verified { verify(true,"") }
            return }
        let param:JSONDictionary = ["userName":userName,"userId":UserModel.main.userId]
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
                    self?.isUsernamevailable = false
                    if let verify = self?.verified { verify(true,"") }
                }
            }
        }
    }
    
    func hitForSignup(){
        var param:JSONDictionary = [:]
        if type == .email{
            param["email"] = email
        }else{
            param["mobileNo"] = phoneNo.replace(string: "-", withString: "")
            param["countryCode"] = "+1"
        }
        param["password"] = password
        param["deviceId"] = DeviceDetail.deviceId
        param["deviceToken"] = DeviceDetail.deviceToken
        param["latitude"] = 0
        param["longitude"] = 0
        param["userName"] = userName
        param["address"] = "India"
        param["userId"] = UserModel.main.userId
        
        web.request(from: WebService.signup, param: param, method: .POST, header: [:]) { [weak self](data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let self = self else { return }
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        let code = json[ApiKey.code].intValue
                        switch code{
                        case 201:
                            if self.type == .email{
                                UserModel.main  = UserModel(json["data"])
                                if let pop = self.showEmailVerifyPopup { pop()}
                            }else{
                                UserModel.main  = UserModel(json["data"])
                                DispatchQueue.main.async {
                                    if let otpscreen = self.proceedToOtp { otpscreen(self.phoneNo)}
                                    SocketIOManager.instance.initializeSocket()
                                    SocketIOManager.instance.connectSocket()
                                }
                            }
                        case 400:
                            let errormsg = json["message"].stringValue 
                            CommonFunctions.showToastWithMessage(errormsg)
                        default:
                            CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                        }
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    /// Method to check for Google user in our DB
    /// - Parameters:
    ///   - model: Google user data model
    ///   - isAvailabel: Bool flag
    /// - Returns: Return true/false depending on conditions
    func checkGoogleUser(_ model:GoogleUser,isAvailabel: @escaping (Bool)->()){
        let param:JSONDictionary = [ApiKey.email:model.email,
                                    "socialId":model.id,
                                    "socialLoginType":"google"]
        checkForExixting(param: param) { (flag) in
            isAvailabel(flag)
        }
    }
    
    /// Method to check for facebook user in our DB
    /// - Parameters:
    ///   - model: FB user data model
    ///   - isAvailabel: Bool flag
    /// - Returns: Return true/false depending on conditions
    func checkFBUser(_ model:FacebookModel, isAvailabel: @escaping (Bool)->()){
        let param:JSONDictionary = [ApiKey.email:model.email,
                                    "socialId":model.id,
                                    "socialLoginType":"facebook"]
        checkForExixting(param: param) { (flag) in
            isAvailabel(flag)
        }
    }
    
    /// Method to check for Google user in our DB
    /// - Parameters:
    ///   - model: Google user data model
    ///   - isAvailabel: Bool flag
    /// - Returns: Return true/false depending on conditions
    func checkAppleUser(_ model:AppleModel,isAvailabel: @escaping (Bool)->()){
        let param:JSONDictionary = [ApiKey.email:model.email,
                                    "socialId":model.id,
                                    "socialLoginType":"apple"]
        checkForExixting(param: param) { (flag) in
            isAvailabel(flag)
        }
    }
    
    /// Method to check if the user exist in our DB.
    /// - Parameters:
    ///   - param: JSONDictionary
    ///   - sucess: JSON response
    /// - Returns: Return bool flag
    private func checkForExixting(param:JSONDictionary,sucess:@escaping (Bool)->()){
        web.request(from: WebService.checkSocail, param: param, method: .POST, header: [:]) { (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        let code = json[ApiKey.code].intValue
                        if code == 410{
                            sucess(false)
                        }else{
                            sucess(true)
                        }
                    } failure: { (e) in
                        sucess(false)
                    }
                }
            }
        }
    }
}

extension Character {
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }

    var containsEmoji: Bool { contains { $0.isEmoji } }

    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }

    var emojiString: String { emojis.map { String($0) }.reduce("", +) }

    var emojis: [Character] { filter { $0.isEmoji } }

    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}
