//
//  FAQModel.swift
//  Stoke
//
//  Created by Admin on 29/10/21.
//

import Foundation
import SwiftyJSON

struct FAQList {
    var faqList: [FAQModel]?
    
    init(_ json:JSON){
        faqList = getFAQList(json)
    }
    
    func getFAQList(_ json: JSON)->[FAQModel]{
        let list = json.arrayValue.map{FAQModel($0)}
        return list
    }
}

struct FAQModel {
    var isOpen: Bool = false
    var id:String
    let status:String
    var question:String
    var answer:String
    init(_ json:JSON){
        question = json["question"].stringValue
        status = json["status"].stringValue
        id = json["_id"].stringValue
        answer = json["answer"].stringValue
    }
}
