//
//  CategoryListModel.swift
//  Stoke
//
//  Created by Admin on 18/03/21.
//

import Foundation
import SwiftyJSON

struct CategoryListModel {
    let totalCount:Int
    let page:Int
    let limit:Int
    var data:[Categories]
    
    init(_ json:JSON){
        totalCount = json["totalCount"].intValue
        page = json["page"].intValue
        limit = json["limit"].intValue
        data = json["data"].arrayValue.map { Categories($0)}
    }
}
