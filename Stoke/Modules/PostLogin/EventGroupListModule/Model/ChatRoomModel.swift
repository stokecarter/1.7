//
//  ChatRoomModel.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import Foundation
import SwiftyJSON


enum RoomRequestStatus:Int{
    case none = 0
    case requestedByMe = 1
    case requestedByCreatoe = 2
    case readyToJoin = 3
}

enum PaymentStatus:String{
    case success
    case pending
    case failed
    case none
    
    var title:String{
        switch self {
        case .success:
            return "Successful"
        case .failed:
            return "Failed"
        case .pending:
            return "Pending"
        default:
            return ""
        }
    }
}

enum RoomType:String{
    case _public = "public"
    case _private = "private"
    
    init(val:String){
        if val == "public"{
            self = ._public
        }else{
            self = ._private
        }
    }
}

struct ChatRoom {
//    let noOfUsers:String
    var _id:String
    let createdBy:User
    let event:Event
//    let noOfFollowings:String
    let image:String
    let roomType:RoomType
    let isLive:Bool
    var name:String
    let createdAt:String
    let description:String
    var isSaved:Bool
    let inviteString:String
    let amount:Double
    let paidType:String
    let tags:[Tags]
    let isFree:Bool
    var requestId:String
    var requestStatus:RoomRequestStatus
    var paymentStatus:PaymentStatus
    var priority:Int
    var isInvitedByCreator:Bool
    let category:Categories
    let isConcluded:Bool
    
    
    init(_ json:JSON){
        isInvitedByCreator = json["isInvitedByCreator"].boolValue
//        noOfUsers = json["noOfUsers"].stringValue
        _id = json["_id"].stringValue
        createdBy = User(json["createdBy"])
        event = Event(json["event"])
//        noOfFollowings = json["noOfFollowings"].stringValue
        image = json["image"].stringValue
        roomType = RoomType(val: json["roomType"].stringValue)
        isLive = json["isLive"].boolValue
        name = json["name"].stringValue
        createdAt = json["createdAt"].stringValue
        category = Categories(json["category"])
        description = json["description"].stringValue
        isSaved = json["isSaved"].boolValue
        inviteString = json["inviteString"].stringValue
        amount = json["amount"].doubleValue
        paidType = json["paidType"].stringValue
        isFree = paidType == "free"
        tags = Tags.returnTaggsArray(json["tags"])
        requestId = json["requestId"].stringValue
        requestStatus = RoomRequestStatus(rawValue: json["requestStatus"].intValue) ?? .none
        priority = json["priority"].intValue
        paymentStatus = PaymentStatus(rawValue: json["paymentStatus"].stringValue) ?? .none
        isConcluded = event.isEventExtendedIndefinately ? false : Date().isGreaterThan(event.endDate)
    }
    
    init(withDB c:ChatRoomDBM){
        isInvitedByCreator = c.isInvitedByCreator
//        noOfUsers = c.noOfUsers
        _id = c._id
        var u = User(JSON())
        u.fullName = c.createdByUserFullname
        u.id = c.createdByUserId
        u.userName = c.createdByUserName
        u.image = c.createdByUserImage
        createdBy = u
        var e = Event(JSON())
        e.name = c.eventName
        e.id = c.eventId
        e.image = c.eventImage
        e.isEventExtendedIndefinately = c.eventIsExtented
        e.endTime = c.endTime
        event = e
//        noOfFollowings = c.noOfFollowings
        image = c.image
        roomType = c.roomType
        isLive = c.isLive
        name = c.name
        createdAt = c.createdAt
        var cat = Categories(JSON())
        cat.id = c.categoryId
        cat.name = c.categoryName
        category = cat
        description = c._description
        isSaved = c.isSaved
        inviteString = c.inviteString
        amount = c.amount
        paidType = c.paidType
        isFree = paidType == "free"
        tags = []
        requestId = c.requestId
        requestStatus = c.requestStatus
        priority = c.priority
        paymentStatus = c.paymentStatus
        isConcluded = c.eventIsExtented ? false : Date().isGreaterThan(event.endDate)
    }

    
    var isCreatedByMe:Bool{
        return createdBy.id == UserModel.main.userId
    }
    
    var startDateObject:Date{
        return event.chatRoomStartDate
    }
    
    var isToday:Bool{
        return Calendar.current.isDateInToday(startDateObject)
    }
    
    static func returnArray(_ json:JSON) -> [ChatRoom]{
        return json.arrayValue.map { ChatRoom($0)}
    }
}

struct ChatRoomModel {
    let page:Int
    let limit:Int
    let totalCount:Int
    let nextPage:Int
    var chatRooms:[ChatRoom]
    var liveRoom:[ChatRoom]
    var upcoming:[ChatRoom]
    var ended:[ChatRoom]
    
    init(_ json:JSON){
        page = json["page"].intValue
        limit = json["limit"].intValue
        totalCount = json["totalCount"].intValue
        nextPage = json["nextPage"].intValue
        chatRooms = ChatRoom.returnArray(json[ApiKey.data])
        liveRoom = chatRooms.filter {$0.priority == 1}
        upcoming = chatRooms.filter {$0.priority == 2}
        ended = chatRooms.filter {$0.priority == 3}
    }
    
    init(withSavedChatroomsDb r:SavedChatrooms){
        liveRoom = r.liveRoom.map { ChatRoom(withDB: $0)}
        upcoming = r.upcoming.map { ChatRoom(withDB: $0)}
        ended = r.ended.map { ChatRoom(withDB: $0)}
        chatRooms = []
        page = 1
        limit = 100
        totalCount = 1
        nextPage = -1
    }
    
    init(withCreatedChatroomsDb r:CreatedChatrooms){
        liveRoom = r.liveRoom.map { ChatRoom(withDB: $0)}
        upcoming = r.upcoming.map { ChatRoom(withDB: $0)}
        ended = r.ended.map { ChatRoom(withDB: $0)}
        chatRooms = []
        page = 1
        limit = 100
        totalCount = 1
        nextPage = -1
    }

}
