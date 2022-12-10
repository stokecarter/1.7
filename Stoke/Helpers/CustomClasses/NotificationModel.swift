//
//  NotificationModel.swift
//  Stoke
//
//  Created by Admin on 21/05/21.
//

import Foundation
import SwiftyJSON

enum AdminPushType:String{
    case newRoomCreated = "1"
    case commentReported = "2"
    case feedback = "3"
    case userReported = "4"
}

/*
 
 {
   "_id" : "60c09dd8b5a69e0830b8a2b5",
   "notificationType" : 1,
   "fromUser" : {
     "followStatus" : "none",
     "isTrusted" : false,
     "_id" : "60c042f9d333cb3713b8c6bd",
     "isPrivateAccount" : true,
     "name" : "anuj",
     "image" : "https:\/\/s3.us-east-1.amazonaws.com\/appinventiv-development\/1623213425.png"
   },
   "isRead" : false,
   "createdAt" : 1623236056110,
   "message" : "anuj has started following you",
   "typeData" : {
     "roomType" : "",
     "_id" : "60c042f9d333cb3713b8c6bd",
     "isInvitedByCreator" : true,
     "image" : "https:\/\/s3.us-east-1.amazonaws.com\/appinventiv-development\/1623213425.png",
     "name" : "anuj"
   },
   "title" : ""
 }
 
 
 {
     "nextPage" : -1,
     "page" : 1,
     "limit" : 100,
     "unreadCount" : 14,
     "data" : [
     {
     "createdAt" : 1621535421371,
     "fromUser" : {
     
     },
     "typeData" : {
     "image" : "https:\/\/appinventiv-development.s3.amazonaws.com\/chatrooms\/1621534715105.png",
     "_id" : "60a6a82b4c8ef573afa668d5",
     "name" : "chat 1"
     },
     "isRead" : false,
     "_id" : "60a6aabdea96d2086a98817b",
     "title" : "Follower active in chatroom",
     "message" : "nirmal570 active in chatroom chat 1",
     "notificationType" : 2
     },
     {
     "createdAt" : 1621535421358,
     "fromUser" : {
     
     },
     "typeData" : {
     "image" : "https:\/\/appinventiv-development.s3.amazonaws.com\/chatrooms\/1621534715105.png",
     "_id" : "60a6a82b4c8ef573afa668d5",
     "name" : "chat 1"
     },
     "isRead" : false,
     "_id" : "60a6aabdea96d2086a988179",
     "title" : "Follower active in chatroom",
     "message" : "nirmal570 active in chatroom chat 1",
     "notificationType" : 2
     },
     {
     "notificationType" : 6,
     "_id" : "60a6a9184c8ef573afa668df",
     "title" : "Chatroom creation by follower",
     "fromUser" : {
     
     },
     "createdAt" : 1621535000076,
     "isRead" : false,
     "message" : "chatroom 4",
     "typeData" : {
     "_id" : "60a6a9184c8ef573afa668dd",
     "image" : "https:\/\/appinventiv-development.s3.amazonaws.com\/chatrooms\/1621534932606.png",
     "name" : "chatroom 4"
     }
     },
     {
     "notificationType" : 6,
     "_id" : "60a6a82b4c8ef573afa668d7",
     "title" : "Chatroom creation by follower",
     "fromUser" : {
     
     },
     "createdAt" : 1621534763768,
     "isRead" : false,
     "message" : "chat 1",
     "typeData" : {
     "_id" : "60a6a82b4c8ef573afa668d5",
     "image" : "https:\/\/appinventiv-development.s3.amazonaws.com\/chatrooms\/1621534715105.png",
     "name" : "chat 1"
     }
     },
     {
     "notificationType" : 9,
     "_id" : "60a696a90f328f41c08bec8d",
     "title" : "Title test",
     "fromUser" : {
     
     },
     "createdAt" : 1621530281389,
     "message" : "description Test",
     "isRead" : false,
     "typeData" : {
     "_id" : "60a696a80f328f41c08bec8c",
     "image" : "https:\/\/appinventiv-development.s3.amazonaws.com\/admin_icon_notification%403x.png",
     "name" : "Title test"
     }
     },
     {
     "createdAt" : 1621526743473,
     "fromUser" : {
     
     },
     "typeData" : {
     "image" : "https:\/\/appinventiv-development.s3.amazonaws.com\/chatrooms\/1621514824828.png",
     "_id" : "60a65a5bc46ee3631466c225",
     "name" : "chag"
     },
     "isRead" : false,
     "_id" : "60a688d719705a46149cb9a5",
     "title" : "Follower active in chatroom",
     "message" : "nirmal570 active in chatroom chag",
     "notificationType" : 2
     },
     {
     "_id" : "60a69a9f418d6d5a7049c5d2",
     "status" : "delete",
     "isRead" : true,
     "recipientId" : "608fb3b0e912642391d964b2",
     "typeData" : {
     "_id" : "60a69951418d6d5a7049c5c7",
     "name" : "test ayu",
     "image" : "https://appinventiv-development.s3.amazonaws.com/chatrooms/1621530915928.png"
     },
     "fromUser" : {
     "_id" : "60a49da49510ab6746e34822",
     "name" : "ayu-fb-05",
     "image" : "https://appinventiv-development.s3.amazonaws.com/cropped4313487489393456604.jpg1621438383933.null",
     "requestId" : "60a69a9f418d6d5a7049c5d1"
     },
     "title" : "New chatroom invite",
     "message" : "test ayu",
     "notificationType" : 3,
     "createdAt" : "2021-05-20T22:51:35.433+05:30",
     "updatedAt" : "2021-05-20T23:32:56.969+05:30"
     },
     {
     "createdAt" : 1621526466557,
     "fromUser" : {
     
     },
     "typeData" : {
     "image" : "https:\/\/appinventiv-development.s3.amazonaws.com\/chatrooms\/1621514824828.png",
     "_id" : "60a65a5bc46ee3631466c225",
     "name" : "chag"
     },
     "isRead" : false,
     "_id" : "60a687c2e2bbfa40d4db1676",
     "title" : "Follower active in chatroom",
     "message" : "arpit active in chatroom chag",
     "notificationType" : 2
     },
     {
     "createdAt" : 1621512236011,
     "fromUser" : {
     
     },
     "typeData" : {
     "image" : "https:\/\/appinventiv-development.s3.amazonaws.com\/Icon-App-20x20%401x.png",
     "_id" : "60a6502a66774838ec4ade92",
     "name" : "Title1"
     },
     "isRead" : false,
     "_id" : "60a6502c66774838ec4ade93",
     "title" : "Title1",
     "message" : "Title1",
     "notificationType" : 9
     },
     {
     "createdAt" : 1621440266884,
     "fromUser" : {
     
     },
     "typeData" : {
     "image" : "https:\/\/appinventiv-development.s3.amazonaws.com\/Icon-App-20x20%401x.png",
     "_id" : "60a53709dc8daa016c3463cd",
     "name" : "Admin Title"
     },
     "isRead" : false,
     "_id" : "60a5370adc8daa016c3463ce",
     "title" : "Admin Title",
     "message" : "Admin Title",
     "notificationType" : 9
     },
     {
     "createdAt" : 1621440120904,
     "fromUser" : {
     
     },
     "typeData" : {
     "image" : "https:\/\/appinventiv-development.s3.amazonaws.com\/Icon-App-20x20%401x.png",
     "_id" : "60a536783b196524a877c891",
     "name" : "Admin Title"
     },
     "isRead" : false,
     "_id" : "60a536783b196524a877c892",
     "title" : "Admin Title",
     "message" : "Admin Title",
     "notificationType" : 9
     },
     {
     "createdAt" : 1621439207028,
     "fromUser" : {
     
     },
     "typeData" : {
     "image" : "https:\/\/appinventiv-development.s3.amazonaws.com\/Icon-App-20x20%401x.png",
     "_id" : "60a532e6c24b7d04b04ac940",
     "name" : "Admin Title"
     },
     "isRead" : false,
     "_id" : "60a532e7c24b7d04b04ac941",
     "title" : "Admin Title",
     "message" : "Admin Title",
     "notificationType" : 9
     },
     {
     "createdAt" : 1621426966209,
     "fromUser" : {
     
     },
     "typeData" : {
     "image" : "",
     "_id" : "60409068dd57521bbf505803",
     "name" : "nirmal"
     },
     "isRead" : false,
     "_id" : "60a503164525fd7038ebd3d7",
     "title" : "Follow user",
     "message" : "nirmal Follow user ",
     "notificationType" : 2
     },
     {
     "createdAt" : 1621426749055,
     "fromUser" : {
     
     },
     "typeData" : {
     "image" : "",
     "_id" : "60409068dd57521bbf505803",
     "name" : "nirmal"
     },
     "isRead" : false,
     "_id" : "60a5023d4525fd7038ebd3d5",
     "title" : "Follow user",
     "message" : "nirmal Follow user ",
     "notificationType" : 2
     },
     {
     "createdAt" : 1621426663371,
     "fromUser" : {
     
     },
     "typeData" : {
     "image" : "",
     "_id" : "60409068dd57521bbf505803",
     "name" : "nirmal"
     },
     "isRead" : false,
     "_id" : "60a501e74525fd7038ebd3cc",
     "title" : "Follow user",
     "message" : "nirmal Follow user ",
     "notificationType" : 2
     }
     ],
     "totalCount" : 14
 
 
 "typeData" : {
   "roomType" : "private",
   "image" : "https:\/\/appinventiv-development.s3.amazonaws.com\/chatrooms\/1622166548307.png",
   "name" : "Private",
   "_id" : "60b0d2a82f45c438185463fd",
   "isInvitedByCreator" : false
 }
 }
 */
struct FromUser{
    var image:String
    var requestId:String
    var name:String
    var inviteStatus:RequestStatus
    var followStatus:FollowStatus
    var _id:String
    var isPrivateAccount:Bool
    var isTrusted:Bool
    init(_ json:JSON){
        image = json["image"].stringValue
        requestId = json["requestId"].stringValue
        name = json["name"].stringValue
        inviteStatus = RequestStatus(json["inviteStatus"].stringValue)
        _id = json["_id"].stringValue
        followStatus = FollowStatus(rawValue: json["followStatus"].stringValue) ?? .none
        isPrivateAccount = json["isPrivateAccount"].boolValue
        isTrusted = json["isTrusted"].boolValue
    }
}


struct NotificationModel {
    
    var roomId:String
    var userId:String
    var isRead:Bool
    var _id:String
    var notificationType:PushTypes
    var title:String
    var message:String
    var fromUser:FromUser?
    var createdAt:Double
    var userImage:String
    var chatroomImage:String
    var roomType:RoomType = ._public
    var isInvitedByCreator:Bool  = false
    var eventname:String
    var tagImage:String
    
    var timeStamp:String{
        return Date(timeIntervalSince1970: createdAt/1000).timeAgoSince
    }
    
    init(_ json:JSON){
        notificationType = PushTypes(rawValue: json["notificationType"].intValue) ?? .adminNotification
        switch notificationType{
        case .newFollow,.adminNotification:
            userId = json["typeData"]["_id"].stringValue
            userImage = json["typeData"]["image"].stringValue
            roomId = ""
            chatroomImage = ""
        case .newChatroomInvite,.requestToJoin:
            roomId = json["typeData"]["_id"].stringValue
            chatroomImage = json["typeData"]["image"].stringValue
            userId  = ""
            userImage = ""
            roomType = RoomType(val: json["typeData"]["roomType"].stringValue)
            isInvitedByCreator = json["typeData"]["isInvitedByCreator"].boolValue
        case .followersActiveInChatroom,.savedChatroomLive,.chatroomCreatedByFollower,.recapAvailabel,.chatroomStarted,.celebrityApprovesCommnets,.requestAccepted,.eventStarted:
            roomId = json["typeData"]["_id"].stringValue
            chatroomImage = json["typeData"]["image"].stringValue
            userId  = ""
            userImage = ""
            
        case .newFollowRequest:
            userId = json["typeData"]["_id"].stringValue
            userImage = json["typeData"]["image"].stringValue
            roomId = ""
            chatroomImage = ""
        case .newFollowRequestAccept:
            userId = json["typeData"]["_id"].stringValue
            userImage = json["typeData"]["image"].stringValue
            roomId = ""
            chatroomImage = ""
        case .replyOnCommnet:
            chatroomImage = json["typeData"]["image"].stringValue
            roomId = json["typeData"]["_id"].stringValue
            userId  = ""
            userImage = ""
        case .engagementPoping:
            chatroomImage = json["typeData"]["image"].stringValue
            roomId = json["typeData"]["_id"].stringValue
            userId  = ""
            userImage = ""
        case .eventReminder:
            chatroomImage = json["typeData"]["image"].stringValue
            roomId = json["typeData"]["_id"].stringValue
            userId  = ""
            userImage = ""
        default:
            userId  = ""
            userImage = ""
            roomId = ""
            chatroomImage = ""
        }
        _id = json["_id"].stringValue
        fromUser = FromUser(json["fromUser"])
        createdAt = json["createdAt"].doubleValue
        title = json["title"].stringValue
        message = json["message"].stringValue
        isRead = json["isRead"].boolValue
        eventname = json["typeData"]["name"].stringValue
        tagImage = json["typeData"]["tagImage"].stringValue
    }
    
    init(withDb:NotificationDBM){
        roomId = withDb.roomId
        userId = withDb.userId
        isRead = withDb.isRead
        _id = withDb._id
        notificationType = withDb.notificationType
        title = withDb.title
        message = withDb.message
        fromUser = withDb.fromUser
        createdAt = withDb.createdAt
        userImage = withDb.userImage
        chatroomImage = withDb.chatroomImage
        roomType = withDb.roomType
        isInvitedByCreator = withDb.isInvitedByCreator
        eventname = withDb.eventname
        tagImage = withDb.tagImage
    }
    
    static func returnNotificatiosn(_ json:JSON) -> [NotificationModel]{
        return json.arrayValue.map { NotificationModel($0)}
    }
    
}

struct AdminNotificationModel {
    var isRead:Bool
    var createdAt:Double
    var user:User
    var message:String
    var _id:String
    var title:String
    var image:String
    var type:AdminPushType
    var typeId:String
    
    var timeStamp:String{
        return Date(timeIntervalSince1970: createdAt/1000).timeAgoSince
    }
    
    init(_ json:JSON){
        isRead = json["isRead"].boolValue
        createdAt = json["createdAt"].doubleValue
        user = User(json["user"])
        isRead = json["isRead"].boolValue
        message = json["description"].stringValue
        title = json["title"].stringValue
        image = json["image"].stringValue
        _id = json["_id"].stringValue
        type = AdminPushType(rawValue: json["type"].stringValue) ?? .newRoomCreated
        typeId = json["typeId"].stringValue
    }
    
    static func returnAdminNotifications(_ json:JSON) -> [AdminNotificationModel]{
        return json.arrayValue.map { AdminNotificationModel($0)}
    }
}


struct AdminNotificationList{
    var unreadCount:Int
    var totalCount:Int
    var data:[AdminNotificationModel]
    
    init(_ json:JSON){
        unreadCount = json["unreadCount"].intValue
        totalCount = json["totalCount"].intValue
        data = AdminNotificationModel.returnAdminNotifications(json["data"])
    }
}

struct NotificationList{
    var unreadCount:Int
    var totalCount:Int
    var data:[NotificationModel]
    
    init(_ json:JSON){
        unreadCount = json["unreadCount"].intValue
        totalCount = json["totalCount"].intValue
        data = NotificationModel.returnNotificatiosn(json["data"])
    }
    
    init(withDb n:NotificationListDBM){
        unreadCount = n.unreadCount
        totalCount = n.list.count
        var list = [NotificationModel]()
        for i in n.list{
            list.append(NotificationModel(withDb: i))
        }
        data = list
    }
}
