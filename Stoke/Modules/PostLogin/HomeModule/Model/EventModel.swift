//
//  EventModel.swift
//  Stoke
//
//  Created by Admin on 17/03/21.
//

import Foundation
import SwiftyJSON


struct Tags : Codable{
    
    var isSaved:Bool
    let image:String
    let status:String
    let id:String
    let name:String
    
    
    init(_ json:JSON){
        image = json["image"].stringValue
        status = json["status"].stringValue
        id = json["_id"].stringValue
        name = json["name"].stringValue
        isSaved = json["isSaved"].boolValue
    }
    
    static func returnTaggsArray(_ json:JSON) -> [Tags]{
        return json.arrayValue.map { Tags($0) }
    }
}

struct Categories {
    var image:String
    let status:String
    var id:String
    var name:String
    init(_ json:JSON){
        image = json["image"].stringValue
        status = json["status"].stringValue
        id = json["_id"].stringValue
        name = json["name"].stringValue
    }
}

struct Event {
    var id:String
    var image:String
//    let noOfUsers:Int
    var name:String
    let startTime:Double
    var endTime:Double
    let isLive:Bool
    let category:Categories
    let squareImage:String
    let tags:[Tags]
    let backendCreatedDate:String
    var isEventExtendedIndefinately:Bool
    var liveChatroomTime:Double
    var priority:Int
    
    init(_ json:JSON) {
        id = json["_id"].stringValue
        image = json["image"].stringValue
//        noOfUsers = json["noOfUsers"].intValue
        name = json["name"].stringValue
        isLive = json["isLive"].boolValue
        startTime = json["startTime"].doubleValue
        endTime = json["endTime"].doubleValue
        category = Categories(json["category"])
        tags = Tags.returnTaggsArray(json["tags"])
        backendCreatedDate = json["isLive"].stringValue
        isEventExtendedIndefinately = json["isEventExtendedIndefinately"].boolValue
        squareImage = json["squareImage"].stringValue
        liveChatroomTime = json["liveChatroomTime"].doubleValue
        priority = json["priority"].intValue
    }
    
    init(_ m:NotificationModel){
        id = m._id
        image = m.chatroomImage
//        noOfUsers = 0
        name = m.eventname
        startTime = 0
        endTime = 0
        isLive = false
        category = Categories(JSON())
        squareImage = ""
        tags = []
        backendCreatedDate = ""
        isEventExtendedIndefinately = false
        liveChatroomTime = 0
        priority = 1
    }
    init(e:NotificationModel){
        id = e.roomId
        image = e.chatroomImage
//        noOfUsers = 0
        name = e.eventname
        startTime = 0
        endTime = 0
        isLive = false
        category = Categories(JSON())
        squareImage = ""
        tags = []
        backendCreatedDate = ""
        isEventExtendedIndefinately = false
        liveChatroomTime = 0
        priority = 1
    }
    
    
    var isEventConcluded:Bool{
        return Date().isGreaterThan(endDate)
    }
    
    static func returnEventArray(_ json:JSON) -> [Event]{
        return json.arrayValue.map { Event($0)}
    }
    
    var isHistory:Bool{
        return isEventConcluded && !isEventExtendedIndefinately
    }
}

extension Event:Comparable{
    
    var weakDay:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: startDate)
        return weekDay
    }
    
    var chatRoomStartDate:Date{
        return Date(timeIntervalSince1970: liveChatroomTime/1000)
    }
    
    var startDate:Date{
        return Date(timeIntervalSince1970: startTime/1000)
    }
    var endDate:Date{
        return Date(timeIntervalSince1970: endTime/1000)
    }
    
    var chatroomStartDateTimeFormat:String{
        let dt = DateFormatter()
        dt.dateFormat = "h:mm a"
        return dt.string(from: chatRoomStartDate)
    }
    
    var startDateTimeFormat:String{
        let dt = DateFormatter()
        dt.dateFormat = "h:mm a"
        return dt.string(from: startDate)
    }
    var endDateTimeFormat:String{
        let dt = DateFormatter()
        dt.dateFormat = "h:mm a"
        return dt.string(from: endDate)
    }
    
    static func == (lhs:Event,rhs:Event) -> Bool{
        return lhs.startDate == rhs.startDate
    }
    
    static func < (lhs:Event, rhs:Event) -> Bool{
        return lhs.startDate < lhs.startDate
    }
    
}

struct SortedEvents {
    let count:Int
    let startTimeStamp:Double
    let events:[Event]
    let isMoreAvailable:Bool
    let dateString:String
    
    init(_ json:JSON){
        count = json["count"].intValue
        startTimeStamp = json["startTimeStamp"].doubleValue
        events = Event.returnEventArray(json["events"])
        isMoreAvailable = json["isMoreAvailable"].boolValue
        dateString = json["dateString"].stringValue
    }
    static func returnSortedEvents(_ json:JSON) ->[SortedEvents]{
        return json.arrayValue.map { SortedEvents($0)}
    }
    var startDate:Date{
        printDebug(Date(timeIntervalSince1970: startTimeStamp/1000))
        return Date(timeIntervalSince1970: startTimeStamp/1000)
    }
    var weakDay:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let weekDay = dateFormatter.string(from: startDate)
        return weekDay
    }
    
}



struct FeaturedList{
    let totalCount:Int
    let page:Int
    let limit:Int
    var data:[Event]
    let nextPage:Int
    var liveEvents:[Event]
    var upcoming:[Event]
    var ended:[Event]
    
    mutating func clearAll() ->Bool{
        liveEvents.removeAll()
        upcoming.removeAll()
        ended.removeAll()
        return true
    }
    
    init(_ json:JSON){
        totalCount = json["totalCount"].intValue
        page = json["page"].intValue
        limit = json["limit"].intValue
        nextPage = json["nextPage"].intValue
        data = Event.returnEventArray(json["data"])
        liveEvents = data.filter { $0.priority == 1}
        upcoming = data.filter { $0.priority == 2}
        ended = data.filter { $0.priority == 3}
    }
    
}

// MARK: - DataClass
struct PostList {
    let limit: Int
    var data: [HotTake]
    var page, totalCount, nextPage: Int
    var isLoaded:Bool = true
    
    init(_ json: JSON) {
        limit = json["limit"].intValue
        data = HotTake.returnHotTakeArray(json["data"])
        page = json["page"].intValue
        totalCount = json["totalCount"].intValue
        nextPage = json["nextPage"].intValue
    }
}

// MARK: - Datum
struct HotTake {
    let createdAt: Double
    let text, id: String
    var isVoted: Bool
    var vote: Int
    let isOwnPost: Bool
    var ownVote: Int
    
    init(_ json: JSON) {
        createdAt = json["createdAt"].doubleValue
        text = json["text"].stringValue
        id = json["_id"].stringValue
        isVoted = json["isVoted"].boolValue
        vote = json["vote"].intValue
        isOwnPost = json["isOwnPost"].boolValue
        ownVote = json["ownVote"].intValue
    }

    enum CodingKeys: String, CodingKey {
        case createdAt, text
        case id = "_id"
        case isVoted, vote
        case isOwnPost, ownVote
    }
    
    static func returnHotTakeArray(_ json:JSON) -> [HotTake]{
        return json.arrayValue.map { HotTake($0)}
    }
}
