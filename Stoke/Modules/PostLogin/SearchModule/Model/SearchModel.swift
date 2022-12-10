//
//  SearchModel.swift
//  Stoke
//
//  Created by Admin on 18/03/21.
//

import Foundation
import SwiftyJSON

enum RequestStatus:String{
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
    
    init(_ val:String){
        switch val {
        case "accepted":
            self = .accepted
        case "declined":
            self = .declined
        default:
            self = .pending
        }
    }
}

struct User {
    var id:String
    var firstName:String
    var lastName:String
    var userName:String
    var image:String
    var userType:String
    var fullName:String
    var isInvited:Bool = false
    var isFollowed:Bool
    var status:RequestStatus
    var isCelebrity:Bool
    var requestId:String
    var isGuest:Bool
    var isTrusted:Bool
    var name:String
    var followStatus:FollowStatus
    var isPrivateAccount:Bool
    
    
    init(_ json:JSON){
        id = json["_id"].stringValue
        firstName = json["firstName"].stringValue
        lastName = json["lastName"].stringValue
        userName = json["userName"].stringValue
        image = json["image"].stringValue
        userType = json["userType"].stringValue
        fullName = firstName + " " + lastName
        isInvited = json["isInvited"].boolValue
        isFollowed = json["isFollow"].boolValue
        status =  RequestStatus(json["status"].stringValue)
        isCelebrity = json["isCelebrity"].boolValue
        requestId = json["requestId"].stringValue
        isGuest = json["isGuest"].boolValue
        isTrusted = json["isTrusted"].boolValue
        name = json["name"].stringValue
        followStatus = FollowStatus(rawValue: json["followStatus"].stringValue) ?? .none
        isPrivateAccount = json["isPrivateAccount"].boolValue
    }

    
    static func returnUsers(_ json:JSON) -> [User]{
        return json.arrayValue.map { User($0)}
    }
}

struct UserListModel {
    var totalCount:Int
    let page:Int
    let limit:Int
    let nextPage:Int
    var data:[User]
    
    init(_ json:JSON){
        totalCount = json["totalCount"].intValue
        page = json["page"].intValue
        limit = json["limit"].intValue
        nextPage = json["nextPage"].intValue
        data = json[ApiKey.data].arrayValue.map { User($0)}
    }
}

struct Tag {
    let id:String
    let name:String
    let image:String
    var isSaved:Bool
    
    init(_ json:JSON){
        id = json["_id"].stringValue
        name = json["name"].stringValue
        image = json["image"].stringValue
        isSaved = json["isSaved"].boolValue
    }
    
    static func returnTag(_ json:JSON) -> [Tag]{
        return json.arrayValue.map { Tag($0)}
    }
}

struct TagListModel {
    let totalCount:Int
    let page:Int
    let limit:Int
    let nextPage:Int
    var data:[Tag]
    
    init(_ json:JSON){
        totalCount = json["totalCount"].intValue
        page = json["page"].intValue
        limit = json["limit"].intValue
        nextPage = json["nextPage"].intValue
        data = json[ApiKey.data].arrayValue.map { Tag($0)}
    }
}
