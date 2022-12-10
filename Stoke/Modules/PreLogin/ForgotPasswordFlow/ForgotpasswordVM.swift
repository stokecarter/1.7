//
//  ForgotpasswordVM.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import Foundation
import SwiftyJSON


class ForgotPassword {
    
    enum ResetBy{
        case phone
        case email
    }
    
    let web:NetworkLayer!
    var email = ""
    var phone = ""
    var resetBy:ResetBy = .email
    var goToOtpSccreen:((String)->())?
    var showEmailSucess:((String) ->())?
    init(_ web:NetworkLayer){
        self.web = web
    }
    
    func validateEmail() -> Bool{
        if email.isEmpty{
            CommonFunctions.showToastWithMessage("Please enter the registered email.")
            return false
        }else if email.checkIfInvalid(.email){
            CommonFunctions.showToastWithMessage("Please enter a valid email.")
            return false
        }else{
            return true
        }
    }
    
    func validatePhone() -> Bool{
        if phone.isEmpty{
            CommonFunctions.showToastWithMessage("Please enter the registered phone numbe.r")
            return false
        }else if phone.replace(string: "-", withString:"").count<6{
            CommonFunctions.showToastWithMessage("Number should be at least 6 digits.")
            return false
        }else if phone.replace(string: "-", withString:"").checkIfInvalid(.mobileNumber){
            CommonFunctions.showToastWithMessage("Please enter a valid phone number.")
            return false
        }else{
            return true
        }
    }
    
    func hitResetPassword(){
        let param:JSONDictionary = ["type": resetBy == .email ? "email" : "mobile",
                                    "email": email,
                                    "countryCode": "+1",
                                    "mobileNo":phone.replace(string: "-", withString: "")]
        web.request(from: WebService.forgotPassword, param: param, method: .POST, header: [:]) { (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        if let code = json[ApiKey.code].int, code == 200{
                            if self.resetBy == .email{
                                if let show = self.showEmailSucess { show(json[ApiKey.message].stringValue)}
                            }else{
                                DispatchQueue.main.async {
                                    UserModel.main = UserModel(json[ApiKey.data])
                                    if let tap = self.goToOtpSccreen{ tap("")}
                                }
                            }
                        }else{
                            CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                        }
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
}
