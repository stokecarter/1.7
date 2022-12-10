//
//  OtpVerificationVM.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import Foundation
import SwiftyJSON


class OtpVerificationVM{
    
    var phoneNo:String = ""
    var countryCode:String = "+1"
    var userId:String = ""
    var enteredOtp = ""
    let web:NetworkLayer!
    
    var openResetPwdScreen:((String) -> ())?
    var popBackTosettings:(()->())?
    init(_ web:NetworkLayer){
        self.web = web
    }
    
    func hitToVerifyOtp(_ isFromSetting:Bool){
        let param:JSONDictionary = ["otp": enteredOtp,
                                    "countryCode": countryCode,
                                    "mobileNo": phoneNo.replace(string: "-", withString: ""),
                                    "userId": userId]
        web.request(from: WebService.otp, param: param, method: .POST, header: [:]) { [weak self](data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        if json[ApiKey.code].intValue >= 400{
                            CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                            return
                        }else{
                            CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                            if isFromSetting{
                                if let t = self?.popBackTosettings { t()}
                            }else{
                                DispatchQueue.main.async {
                                    AppRouter.goToHome()
                                }
                            }
                        }
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    func hitVerifyRestOtp(){
        let param:JSONDictionary = ["otp": enteredOtp,
                                    "countryCode": "+1",
                                    "mobileNo": phoneNo.replace(string: "-", withString: "")]
        web.request(from: WebService.verifyResetOtp, param: param, method: .POST, header: [:]) { (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        DispatchQueue.main.async {
                            let token = json[ApiKey.data]["accessToken"].stringValue
                            if let link = self.openResetPwdScreen { link(token)}
                        }
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    func hitResendOtp(){
        let param:JSONDictionary = ["countryCode": "+1",
                                    "mobileNo": phoneNo.replace(string: "-", withString: ""),
                                    "userId": UserModel.main.userId]
        web.request(from: WebService.resendOtp, param: param, method: .POST, header: [:]) { (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        
                            DispatchQueue.main.async {
//                                CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                            }
                        
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    func hitResendForgotOtp(){
        let param:JSONDictionary = ["countryCode": "+1",
                                    "mobileNo": phoneNo.replace(string: "-", withString: ""),
                                    "userId": UserModel.main.userId]
        web.request(from: WebService.resendForgotOtp, param: param, method: .POST, header: [:]) { (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        DispatchQueue.main.async {
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
