//
//  LoginVM.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import Foundation
import SwiftyJSON

class LoginVM{
    
    
    
    
    var userName = ""
    var password = ""
    
    
    let web : NetworkLayer!
    
    init(_ web:NetworkLayer){
        self.web = web
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
            msg = "Password can not be grater than 30 characters."
            CommonFunctions.showToastWithMessage(msg)
            return false
        }else{
            return true
            
        }
    }
    
    
    func hitLogin(){
        let param:JSONDictionary = ["loginId":userName,
                                    "password":password,
                                    "deviceId":DeviceDetail.deviceId,
                                    "deviceToken":DeviceDetail.deviceToken,
                                    "latitude":0,
                                    "longitude":0]
        web.request(from: WebService.login, param: param, method: .POST, header: [:]) { (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        if json[ApiKey.code].intValue >= 400{
                            CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                            return
                        }
                        UserModel.main  = UserModel(json[ApiKey.data])
                        DispatchQueue.main.async{
                            StokeAnalytics.shared.updateUserOnLogin()
                            AppRouter.goToHome()
                            
                        }
                        DispatchQueue.main.async {
                            SocketIOManager.instance.initializeSocket()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                SocketIOManager.instance.connectSocket()
                            }
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
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
}
