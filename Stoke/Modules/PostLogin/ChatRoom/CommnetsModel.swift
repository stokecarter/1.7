//
//  CommnetsModel.swift
//  Stoke
//
//  Created by Admin on 20/04/21.
//

import Foundation
import SwiftyJSON

struct Reply {
    let updatedTimestamp:Double
    let chatroomId:String
    var comment:String
    var createdAt:Double
    var noOfDislikes:Int
    var noOfLaughs:Int
    var noOfClaps:Int
    let commentId:String
    var isLiked:Bool
    var isDisliked:Bool
    var isClap:Bool
    var isLaugh:Bool
    var isLikedByCreator:Bool
    var user:User
    var _id:String
    var noOfLikes:Int
    var isApprovedByCelebrity:Bool
    var celebrity:Celebrity
    
    
    init(_ json:JSON){
        updatedTimestamp = json["updatedTimestamp"].doubleValue
        chatroomId = json["chatroomId"].stringValue
        comment = json["comment"].stringValue
        createdAt = json["createdAt"].doubleValue
        noOfDislikes = json["noOfDislikes"].intValue
        noOfLaughs = json["noOfLaughs"].intValue
        noOfLikes = json["noOfLikes"].intValue
        commentId = json["commentId"].stringValue
        noOfClaps = json["noOfClaps"].intValue
        user = User(json["user"])
        _id = json["_id"].stringValue
        isLiked = json["isLiked"].boolValue
        isDisliked = json["isDisliked"].boolValue
        isClap = json["isClap"].boolValue
        isLaugh = json["isLaugh"].boolValue
        isLikedByCreator = json["isLikedByCreator"].boolValue
        isApprovedByCelebrity = json["isApprovedByCelebrity"].boolValue
        celebrity = Celebrity(json["celebrity"])
    }
    
    init(withDB r:ReplyDBM){
        updatedTimestamp = r.updatedTimestamp
        chatroomId = r.chatroomId
        comment = r.comment
        createdAt = r.createdAt
        noOfDislikes = r.noOfDislikes
        noOfLaughs = r.noOfLaughs
        noOfLikes = r.noOfLikes
        commentId = r.commentId
        noOfClaps = r.noOfClaps
        var u = User(JSON())
        u.fullName = r.userFullname
        u.id = r.userId
        u.userName = r.userName
        u.image = r.userId
        user = u
        _id = r._id
        isLiked = r.isLiked
        isDisliked = r.isDisliked
        isClap = r.isClap
        isLaugh = r.isLaugh
        isLikedByCreator = r.isLikedByCreator
        isApprovedByCelebrity = r.isApprovedByCelebrity
        var cel = Celebrity(JSON())
        cel.fullName = r.celebrityName
        cel.isTrusted = r.isCelebrityTrusted
        cel._id = r.celebrityId
        celebrity = cel
    }
    
    static func returnReply(_ json:JSON) -> [Reply]{
        return json.arrayValue.map { Reply($0)}
    }
    
}

struct Celebrity {
    let lastName:String
    let image:String
    var isTrusted:Bool
    var _id:String
    let isCelebrity:Bool
    let userName:String
    let firstName:String
    let userType:String
    var fullName:String
    
    init(_ json:JSON){
        lastName = json["lastName"].stringValue
        image = json["image"].stringValue
        isTrusted = json["isTrusted"].boolValue
        _id = json["_id"].stringValue
        isCelebrity = json["isCelebrity"].boolValue
        userName = json["userName"].stringValue
        firstName = json["firstName"].stringValue
        userType = json["userType"].stringValue
        fullName = firstName + " " + lastName
    }
}


struct Comment {
    let updatedTimestamp:Double
    let commentId:String
    let isMoreThanOneReply:Bool
    let comment:String
    var isDisliked:Bool
    var noOfLikes:Int
    let _id:String
    var totalReactions:Int
    let noOfDislikes:Int
    let isClap:Bool
    let createdAt:Double
    var noOfClaps:Int
    var isLiked:Bool
    var noOfLaughs:Int
    var chatroomId:String
    var user:User
    var isLaugh:Bool
    var user_reply:[Reply]
    var isLikedByCreator:Bool
    var isApprovedByCelebrity:Bool
    var isCommentSaved:Bool
    var celebrity:Celebrity
    var chatroom:ChatRoom
    var event:Event
    
    
    init(_ json:JSON){
        updatedTimestamp = json["updatedTimestamp"].doubleValue
        commentId = json["commentId"].stringValue
        isMoreThanOneReply = json["isMoreThanOneReply"].boolValue
        comment = json["comment"].stringValue
        isDisliked = json["isDisliked"].boolValue
        noOfLikes = json["noOfLikes"].intValue
        _id = json["_id"].stringValue
        totalReactions = json["totalReactions"].intValue
        noOfDislikes = json["noOfDislikes"].intValue
        isClap = json["isClap"].boolValue
        createdAt = json["createdAt"].doubleValue
        noOfClaps = json["noOfClaps"].intValue
        isLiked = json["isLiked"].boolValue
        noOfLaughs = json["noOfLaughs"].intValue
        chatroomId = json["chatroomId"].stringValue
        user = User(json["user"])
        isLaugh = json["isLaugh"].boolValue
        isLikedByCreator = json["isLikedByCreator"].boolValue
        user_reply = Reply.returnReply(json["user_reply"])
        isApprovedByCelebrity = json["isApprovedByCelebrity"].boolValue
        isCommentSaved = json["isCommentSaved"].boolValue
        celebrity = Celebrity(json["celebrity"])
        chatroom = ChatRoom(json["chatroom"])
        event = Event(json["event"])
    }
    
    init(withDB c:CommentDBM){
        updatedTimestamp = c.updatedTimestamp
        commentId = c.commentId
        isMoreThanOneReply = c.isMoreThanOneReply
        comment = c.comment
        isDisliked = c.isDisliked
        noOfLikes = c.noOfLikes
        _id = c._id
        totalReactions = c.totalReactions
        noOfDislikes = c.noOfDislikes
        isClap = c.isClap
        createdAt = c.createdAt
        noOfClaps = c.noOfClaps
        isLiked = c.isLiked
        noOfLaughs = c.noOfLaughs
        chatroomId = c.chatroomId
        var u = User(JSON())
        u.fullName = c.userFullname
        u.id = c.userId
        u.userName = c.userName
        u.image = c.userImage
        u.isTrusted = c.userTrusted
        u.isCelebrity = c.userCelebrity
        user = u
        isLaugh = c.isLaugh
        isLikedByCreator = c.isLikedByCreator
        user_reply = c.replyArray
        isApprovedByCelebrity = c.isApprovedByCelebrity
        isCommentSaved = c.isCommentSaved
        var cel = Celebrity(JSON())
        cel.fullName = c.celebrityName
        cel.isTrusted = c.isCelebrityTrusted
        cel._id = c.celebrityId
        celebrity = cel
        var ch = ChatRoom(JSON())
        ch._id = c.chatroomId
        ch.name = c.chatroomName
        chatroom = ch
        var e = Event(JSON())
        e.id = c.eventId
        e.name = c.eventName
        event = e
    }
    
    init(allComment c:AllRecapCommentDBM){
        updatedTimestamp = c.updatedTimestamp
        commentId = c.commentId
        isMoreThanOneReply = c.isMoreThanOneReply
        comment = c.comment
        isDisliked = c.isDisliked
        noOfLikes = c.noOfLikes
        _id = c._id
        totalReactions = c.totalReactions
        noOfDislikes = c.noOfDislikes
        isClap = c.isClap
        createdAt = c.createdAt
        noOfClaps = c.noOfClaps
        isLiked = c.isLiked
        noOfLaughs = c.noOfLaughs
        chatroomId = c.chatroomId
        var u = User(JSON())
        u.fullName = c.userFullname
        u.id = c.userId
        u.userName = c.userName
        u.image = c.userImage
        u.isTrusted = c.userTrusted
        u.isCelebrity = c.userCelebrity
        user = u
        isLaugh = c.isLaugh
        isLikedByCreator = c.isLikedByCreator
        user_reply = c.replyArray
        isApprovedByCelebrity = c.isApprovedByCelebrity
        isCommentSaved = c.isCommentSaved
        var cel = Celebrity(JSON())
        cel.fullName = c.celebrityName
        cel.isTrusted = c.isCelebrityTrusted
        cel._id = c.celebrityId
        celebrity = cel
        var ch = ChatRoom(JSON())
        ch._id = c.chatroomId
        ch.name = c.chatroomName
        chatroom = ch
        var e = Event(JSON())
        e.id = c.eventId
        e.name = c.eventName
        event = e
    }
    
    init(followingComment c:FollowingRecapCommentDBM){
        updatedTimestamp = c.updatedTimestamp
        commentId = c.commentId
        isMoreThanOneReply = c.isMoreThanOneReply
        comment = c.comment
        isDisliked = c.isDisliked
        noOfLikes = c.noOfLikes
        _id = c._id
        totalReactions = c.totalReactions
        noOfDislikes = c.noOfDislikes
        isClap = c.isClap
        createdAt = c.createdAt
        noOfClaps = c.noOfClaps
        isLiked = c.isLiked
        noOfLaughs = c.noOfLaughs
        chatroomId = c.chatroomId
        var u = User(JSON())
        u.fullName = c.userFullname
        u.id = c.userId
        u.userName = c.userName
        u.image = c.userImage
        u.isTrusted = c.userTrusted
        u.isCelebrity = c.userCelebrity
        user = u
        isLaugh = c.isLaugh
        isLikedByCreator = c.isLikedByCreator
        user_reply = c.replyArray
        isApprovedByCelebrity = c.isApprovedByCelebrity
        isCommentSaved = c.isCommentSaved
        var cel = Celebrity(JSON())
        cel.fullName = c.celebrityName
        cel.isTrusted = c.isCelebrityTrusted
        cel._id = c.celebrityId
        celebrity = cel
        var ch = ChatRoom(JSON())
        ch._id = c.chatroomId
        ch.name = c.chatroomName
        chatroom = ch
        var e = Event(JSON())
        e.id = c.eventId
        e.name = c.eventName
        event = e
    }
    
    init(myComment c:MyRecapCommentDBM){
        updatedTimestamp = c.updatedTimestamp
        commentId = c.commentId
        isMoreThanOneReply = c.isMoreThanOneReply
        comment = c.comment
        isDisliked = c.isDisliked
        noOfLikes = c.noOfLikes
        _id = c._id
        totalReactions = c.totalReactions
        noOfDislikes = c.noOfDislikes
        isClap = c.isClap
        createdAt = c.createdAt
        noOfClaps = c.noOfClaps
        isLiked = c.isLiked
        noOfLaughs = c.noOfLaughs
        chatroomId = c.chatroomId
        var u = User(JSON())
        u.fullName = c.userFullname
        u.id = c.userId
        u.userName = c.userName
        u.image = c.userImage
        u.isTrusted = c.userTrusted
        u.isCelebrity = c.userCelebrity
        user = u
        isLaugh = c.isLaugh
        isLikedByCreator = c.isLikedByCreator
        user_reply = c.replyArray
        isApprovedByCelebrity = c.isApprovedByCelebrity
        isCommentSaved = c.isCommentSaved
        var cel = Celebrity(JSON())
        cel.fullName = c.celebrityName
        cel.isTrusted = c.isCelebrityTrusted
        cel._id = c.celebrityId
        celebrity = cel
        var ch = ChatRoom(JSON())
        ch._id = c.chatroomId
        ch.name = c.chatroomName
        chatroom = ch
        var e = Event(JSON())
        e.id = c.eventId
        e.name = c.eventName
        event = e
    }
    
    static func returnComments(_ json:JSON) -> [Comment]{
        return json.arrayValue.map { Comment($0)}
    }
    
    static func returnCommentsFromDB(_ m:LiveRoomDBM) ->[Comment]{
        return m.comments.map { Comment(withDB: $0)}
    }
    
    static func returnRecapCommentsFromDB(_ m:RecapDBM,type:CommnetType) ->[Comment]{
        switch type {
        case .all:
            return m.allComments.map { Comment(allComment: $0)}
        case .following:
            return m.followingCommnets.map { Comment(followingComment: $0)}
        default:
            return m.myCommnets.map { Comment(myComment: $0)}
        }
        
    }
    
}

struct CommnetsModel {
    var page:Int
    var totalCount:Int
    var data:[Comment]
    var nextPage:Bool
    var isLoaded:Bool = true
    
    
    init(recap l:RecapDBM,type:CommnetType){
        page = 1
        switch type {
        case .all:
            totalCount = l.allComments.count
        case .following:
            totalCount = l.followingCommnets.count
        case .my:
            totalCount = l.myCommnets.count
        }
        data = Comment.returnRecapCommentsFromDB(l,type: type)
        nextPage = false
    }
    
    init(withDB l:LiveRoomDBM){
        page = 1
        totalCount = l.comments.count
        data = Comment.returnCommentsFromDB(l).sorted { $0.createdAt < $1.createdAt}
        nextPage = false
    }
    
    init(recap:JSON){
        page = recap["page"].intValue
        totalCount = recap["totalCount"].intValue
        data = Comment.returnComments(recap["data"])
        nextPage = recap["nextPage"].intValue > 0
    }
    
    init(_ json:JSON){
        page = json["page"].intValue
        totalCount = json["totalCount"].intValue
        data = Comment.returnComments(json["data"]).reversed()
        nextPage = json["nextPage"].intValue > 0
    }
    
}
