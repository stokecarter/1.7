//
//  PersonalInfoVM.swift
//  Stoke
//
//  Created by Admin on 28/05/21.
//

import Foundation
import SwiftyJSON


class PersonalInfoVM{
    
    let web:NetworkLayer!
    
    var model:UserProfileModel!
    
    var countryCode = "+1"
    var mobile = ""
    var email = ""
    
    var update:(()->())?
    
    init(_ web:NetworkLayer,model:UserProfileModel){
        self.web = web
        self.model = model
        getProfile()
    }
    
    
    func resendVerificaitionmale(completion:@escaping ()->()){
        web.request(from: WebService.resendVerificationmale, method: .POST) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { [weak self](json) in
                if json[ApiKey.code].intValue >= 400{
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                }else{
                    self?.getProfile()
                    completion()
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }

        }
    }
    
    func resendOtp(completion:@escaping()->()){
        let param:JSONDictionary = ["countryCode": "+1","mobileNo": model.mobileNo,"userId": model._id]
        web.request(from: WebService.resendOtp, param: param, method: .POST, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                if json[ApiKey.code].intValue >= 400{
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                }else{
                    completion()
//                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }

        }
    }
    
    func validate(_ isEmail:Bool) -> Bool{
        if isEmail{
            if email.isEmpty{
                CommonFunctions.showToastWithMessage("Please enter the email address")
                return false
            }else if email.checkIfInvalid(.email){
                CommonFunctions.showToastWithMessage("Please enter a valid email.")
                return false
            }else{
                return true
            }
        }else{
            let actualNo = mobile.replace(string: "-", withString: "").byRemovingLeadingTrailingWhiteSpaces
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
    }
    
    func getProfile(){
        let param:JSONDictionary = ["toUserId":model._id]
        web.request(from: WebService.userProfile,param: param, method: .GET, header: [:], loader: true) { (data, err) in
            guard let d = data else { CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { [weak self](json) in
                DispatchQueue.main.async {
                    self?.model = UserProfileModel(json[ApiKey.data])
                    AppUserDefaults.save(value: UserProfileModel(json[ApiKey.data]).email, forKey: .email)
                    if let u = self?.update { u()}
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    
    func updateInfo(_ isEmail:Bool,completion:@escaping()->()){
        guard validate(isEmail) else {
            return
        }
        var param:JSONDictionary = [:]
        if isEmail{
            param["type"] = "email"
            param["email"] = email.byRemovingLeadingTrailingWhiteSpaces
        }else{
            param["type"] = "mobile"
            param["mobileNo"] = mobile.replace(string: "-", withString: "").byRemovingLeadingTrailingWhiteSpaces
            param["countryCode"] = countryCode.byRemovingLeadingTrailingWhiteSpaces
        }
        web.request(from: WebService.updateInfo, param: param, method: .PUT, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                if json[ApiKey.code].intValue >= 400{
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                }else{
//                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                    completion()
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }

        }
    }
}
