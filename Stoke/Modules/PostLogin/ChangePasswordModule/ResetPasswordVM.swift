//
//  ResetPasswordVM.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import Foundation
import SwiftyJSON

class ResetPasswordVM{
    
    private let web:NetworkLayer!
    var currentPwd = ""
    var newPwd = ""
    var cnfPwd = ""
    
    
    init(_ web:NetworkLayer){
        self.web = web
    }
    
    func vaildate() -> Bool {
        var msg = ""
        if currentPwd.isEmpty{
            msg = "Please enter the current password"
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else if newPwd.count < 8{
            msg = "Password must have 8 characters"
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else if newPwd.count > 30{
            msg = "Password can not be grater than 30 characters"
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else if newPwd == currentPwd{
            msg = "New password cannot be the same as current password."
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else if newPwd != cnfPwd{
            msg = "Passwords do not match."
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else{
            return true
        }
    }
    
    func hitChangePassword(completion:@escaping()->()){
        guard vaildate() else {
            return
        }
        let param:JSONDictionary = ["oldPassword":currentPwd,"password":newPwd]
        web.request(from: WebService.changePassword, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            guard let d = data else { CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
                return }
            Parser.shared.getJSONData(data: d) { (json) in
                if let code = json[ApiKey.code].int, code == 400{
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                }else{
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                    completion()
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }

        }
    }
}
