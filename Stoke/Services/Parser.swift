//
//  Parser.swift
//  Covid-19 Dependecy_Injection
//
//  Created by Arpit Srivastava on 04/02/21.
//  Copyright © 2021 Arpit Srivastava. All rights reserved.
//

import Foundation
import SwiftyJSON
class Parser{
    
    static let shared = Parser()
    private init(){}
    
    func decodeParser<T:Decodable>(type:T.Type,from:Data?) -> [T]?{
        let decoder = JSONDecoder()
        guard let d = from, let response = try? decoder.decode([T].self, from: d) else {
            return nil
        }
        return response
    }
    
    private func dataToJSON(data: Data, completion:@escaping (AnyObject?) ->(),failure:@escaping (Error) ->()) {
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
            completion(jsonDict)
        } catch let myJSONError {
            failure(myJSONError)
        }
    }
    
    func getJSONData(data:Data, completion:@escaping (JSON) ->(), failure:@escaping (Error) ->()){
        dataToJSON(data: data) { (dict) in
            let json = JSON(dict ?? [:])
            printDebug("JSON RESPONCE ----------------")
            printDebug(json)
            let code = json[ApiKey.code].intValue
            switch code{
            case 419:
                DispatchQueue.main.async {
                    UserModel.main = UserModel(JSON())
                    RealmController.shared.deleteDatabase()
                    CommonFunctions.showToastWithMessage("Unauthorised User")
                    AppRouter.goToWelcomeScreen()
                }
            case 401:
                DispatchQueue.main.async {
                    UserModel.main = UserModel(JSON())
                    RealmController.shared.deleteDatabase()
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                    AppRouter.goToWelcomeScreen()
                }
            case  0...400,410,418,420: /// Special cases.
                DispatchQueue.main.async {
                    completion(json)
                }
            default:
                CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
            }
        } failure: { (e) in
            CommonFunctions.showToastWithMessage(e.localizedDescription)
        }
    }
}
