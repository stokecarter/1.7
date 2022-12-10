//
//  NetworkLayer.swift
//  Covid-19 Dependecy_Injection
//
//  Created by Arpit Srivastava on 01/11/20.
//  Copyright © 2020 Arpit Srivastava. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum HttpMethodsType:String{
    case GET
    case POST
    case DELETE
    case PUT
}
typealias JSONDictionary = [String : Any]

protocol Networking {
    
    typealias CompletionHandler = (Data?,Swift.Error?)->Void
    func request(from:Endpoint,param:JSONDictionary,method:HttpMethodsType,header:JSONDictionary,loader:Bool,completion:@escaping CompletionHandler)
}

class NetworkLayer: Networking {
    
    func request(from: Endpoint,param:JSONDictionary = [:],method:HttpMethodsType,header:JSONDictionary = [:],loader:Bool = true,completion: @escaping CompletionHandler) {
        guard let url = URL(string: from.path) else { return }
        let AFmethod = HTTPMethod(rawValue: method.rawValue)
        let encoding:ParameterEncoding = method == .GET ? URLEncoding.default : JSONEncoding.default
        makeAPIRequest(from: url, param: param, method: AFmethod,encoding:encoding,loader:loader, completion: completion)
        
        
    }
    
    func requestString(from: String,param:JSONDictionary = [:],method:HttpMethodsType,header:JSONDictionary = [:],loader:Bool = true,completion: @escaping CompletionHandler) {
        guard let url = URL(string: from) else { return }
        let AFmethod = HTTPMethod(rawValue: method.rawValue)
        let encoding:ParameterEncoding = method == .GET ? URLEncoding.default : JSONEncoding.default
        makeAPIRequest(from: url, param: param, method: AFmethod,encoding:encoding,loader:loader, completion: completion)
        
        
    }
    
    
    private func makeAPIRequest(from url:URL,
                                param:JSONDictionary,
                                method:HTTPMethod,
                                encoding:ParameterEncoding = JSONEncoding.default,
                                loader:Bool,
                                completion: @escaping CompletionHandler){
        if loader{
            CommonFunctions.showActivityLoader()
        }
        var header:HTTPHeaders!
        if !UserModel.main.isUserLogin || url.absoluteString.contains(s: "signup") || url.absoluteString.contains(s: "check-username"){
            header = ["Content-Type":"application/json",
                      "platform":"2",
                      "offset":"\((TimeZone.current.secondsFromGMT()/60) * -1)",
                      "api_key":"1234",
                      "Authorization":"Basic Y2hhdHJvb21zOmNoYXRyb29tc0AxMjM="]
        }else{
            header = ["Content-Type":"application/json",
                      "platform":"2",
                      "offset":"\((TimeZone.current.secondsFromGMT()/60) * -1)",
                      "api_key":"1234",
                      "Authorization":"Bearer \(UserModel.main.accessToken)"]
        }
        
        let req = AF.request(url,
                             method:method,
                             parameters: param,
                             encoding: encoding,
                             headers: header)
        req.response { (responce) in
            printDebug("===========API RESPONSE===========")
            printDebug("URL ============    \(url)")
            printDebug("PARAMS ==========    \(param)")
            printDebug("METHOD =============  \(method)")
            printDebug("ENCODING =============  \(encoding)")
            printDebug("Header ========== \(header)")
            if loader{
                CommonFunctions.hideActivityLoader()
            }
            switch responce.result{
            case let .success(result):
                completion(result,nil)
            case let .failure(error):
//                if error.isSessionTaskError{
//                    CommonFunctions.showToastWithMessage("The Internet connection appears to be offline.")
//                }else{
                    completion(nil,error)
//                }
            }
        }
    }
}


