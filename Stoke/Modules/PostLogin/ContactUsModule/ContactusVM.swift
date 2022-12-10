//
//  ContactusVM.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import Foundation


class ContactusVM {
    
    private let web:NetworkLayer!
    var type:String = ""
    var desc = ""
    init(_ web:NetworkLayer){
        self.web = web
    }
    
    var popBack:(()->())?
    
    func validate()->Bool{
        if type.isEmpty{
            CommonFunctions.showToastWithMessage("Please select the type of the query")
            return false
        }else if desc.isEmpty || desc.count < 5{
            CommonFunctions.showToastWithMessage("Must be at least 5 characters.")
            return false
        }else{
            return true
        }
    }
    
    func hitConatctus(){
        guard validate() else { return }
        let param:JSONDictionary = [
            "query": desc,
            "type": type,
            "email": UserModel.main.email
        ]
        web.request(from: WebService.contact, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            guard let d = data else { CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { [weak self](json) in
                if json[ApiKey.code].intValue == 201{
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                    if let p = self?.popBack { p()}
                }else{
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                }
            } failure: { (err) in
                CommonFunctions.showToastWithMessage(err.localizedDescription)
            }
        }
    }
}
