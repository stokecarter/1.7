//
//  FeedbackVm.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import Foundation
import SwiftyJSON

class FeedbackVm{
    
    private let web:NetworkLayer!
    var desc = ""
    
    init(_ web:NetworkLayer){
        self.web = web
    }
    
    var popBack:(()->())?
    
    func hitForFeedback(){
        guard !desc.isEmpty else {
            CommonFunctions.showToastWithMessage("Please write something before submitting your feedback.")
            return
        }
        let param:JSONDictionary = ["feedback":desc]
        web.request(from: WebService.feedback, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            guard let d = data else { CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { [weak self](json) in
                if json[ApiKey.code].intValue == 201{
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue, theme: .success)
                    if let p = self?.popBack { p()}
                }else{
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }

        }
    }
}
