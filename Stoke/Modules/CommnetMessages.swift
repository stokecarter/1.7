//
//  CommnetMessages.swift
//  Stoke
//
//  Created by Admin on 23/06/21.
//

import Foundation
import RealmSwift
import SwiftyJSON

@objcMembers class RecapDBM: Object{
    dynamic var _id:String = ""
    dynamic var allComments = List<AllRecapCommentDBM>()
    dynamic var followingCommnets = List<FollowingRecapCommentDBM>()
    dynamic var myCommnets = List<MyRecapCommentDBM>()

    override class func primaryKey() -> String? {
        return "_id"
    }
}

@objcMembers class ReplyThreadDBM: Object{
    
    dynamic var commnetId:String = ""
    dynamic var comment:CommentDBM?
    dynamic var user_reply = List<ReplyDBM>()
    
    override class func primaryKey() -> String? {
        return "commnetId"
    }
}


@objcMembers class LiveRoomDBM: Object{
    dynamic var _id:String = ""
    dynamic var isLive:Bool = false
    dynamic var comments = List<CommentDBM>()
    
    override class func primaryKey() -> String? {
        return "_id"
    }
}






@objcMembers class ChatRoomDBM : Object{

    dynamic var noOfUsers:String = ""
    dynamic var _id:String = ""
    dynamic var createdByUserName:String = ""
    dynamic var createdByUserFullname:String = ""
    dynamic var createdByUserId:String = ""
    dynamic var createdByUserImage:String = ""
    dynamic var eventName:String = ""
    dynamic var eventId:String = ""
    dynamic var endTime:Double = 0
    dynamic var eventIsExtented:Bool = false
    dynamic var eventImage:String = ""
    dynamic var noOfFollowings:String = ""
    dynamic var image:String = ""
    dynamic var _roomType:String = ""
    dynamic var isLive:Bool = false
    dynamic var name:String = ""
    dynamic var createdAt:String = ""
    dynamic var _description:String = ""
    dynamic var isSaved:Bool = false
    dynamic var inviteString:String = ""
    dynamic var amount:Double = 0
    dynamic var paidType:String = ""
    dynamic var isFree:Bool = false
    dynamic var requestId:String = ""
    dynamic var _requestStatus:Int = 0
    dynamic var _paymentStatus:String = ""
    dynamic var priority:Int = 0
    dynamic var isInvitedByCreator:Bool = false
    dynamic var categoryName:String = ""
    dynamic var categoryId:String = ""

    override static func primaryKey()->String{
        return "_id"
    }


    convenience init(from r:ChatRoom){
        self.init()
//        noOfUsers = r.noOfUsers
        _id = r._id
        createdByUserName = r.createdBy.userName
        createdByUserFullname = r.createdBy.fullName
        createdByUserId = r.createdBy.id
        eventName = r.event.name
        eventId = r.event.id
        eventImage = r.event.image
//        noOfFollowings = r.noOfFollowings
        image = r.image
        _roomType = r.roomType.rawValue
        isLive = r.isLive
        name = r.name
        _description = r.description
        isSaved = r.isSaved
        inviteString = r.inviteString
        amount = r.amount
        paidType = r.paidType
        isFree = r.isFree
        requestId = r.requestId
        _requestStatus = r.requestStatus.rawValue
        _paymentStatus = r.paymentStatus.rawValue
        priority = r.priority
        isInvitedByCreator = r.isInvitedByCreator
        categoryName = r.category.name
        categoryId = r.category.id
        endTime = r.event.endTime
        eventIsExtented = r.event.isEventExtendedIndefinately
    }

    var requestStatus:RoomRequestStatus{
        return RoomRequestStatus(rawValue: _requestStatus) ?? .none
    }

    var roomType:RoomType{
        return RoomType(val: _roomType)
    }

    var paymentStatus:PaymentStatus{
        return PaymentStatus(rawValue: _paymentStatus) ?? .none
    }

    static func roomExists(_ roomId : String) -> Bool{
        let realm = RealmController.shared.realm
        return realm.object(ofType: ChatRoomDBM.self, forPrimaryKey: roomId) != nil
    }

    func update(){
        RealmController.shared.fetchObject(ChatRoomDBM.self, primaryKey: _id) { (room) in
            if let r = room{
                let realm = r.realm!
                try! realm.write {
                    realm.add(self, update: .all)
                }
            }
        }
    }
}




@objcMembers class SavedChatrooms :Object{
    
    dynamic var totalCount:Int = 0
    dynamic var chatRooms = List<ChatRoomDBM>()
    dynamic var liveRoom = List<ChatRoomDBM>()
    dynamic var upcoming = List<ChatRoomDBM>()
    dynamic var ended = List<ChatRoomDBM>()
    dynamic var roomType = "Saved"
    
    override class func primaryKey() -> String? {
        return "roomType"
    }
}

@objcMembers class CreatedChatrooms :Object{
    
    dynamic var totalCount:Int = 0
    dynamic var chatRooms = List<ChatRoomDBM>()
    dynamic var liveRoom = List<ChatRoomDBM>()
    dynamic var upcoming = List<ChatRoomDBM>()
    dynamic var ended = List<ChatRoomDBM>()
    dynamic var roomType = "Created"
    
    override class func primaryKey() -> String? {
        return "roomType"
    }
}





@objcMembers class ReplyDBM : Object{
    dynamic var updatedTimestamp:Double = 0
    dynamic var chatroomId:String = ""
    dynamic var comment:String = ""
    dynamic var createdAt:Double = 0
    dynamic var noOfDislikes:Int = 0
    dynamic var noOfLaughs:Int = 0
    dynamic var noOfClaps:Int = 0
    dynamic var commentId:String = ""
    dynamic var isLiked:Bool = false
    dynamic var isDisliked:Bool = false
    dynamic var isClap:Bool = false
    dynamic var isLaugh:Bool = false
    dynamic var isLikedByCreator:Bool = false
    dynamic var userId:String = ""
    dynamic var userName:String = ""
    dynamic var userFullname:String = ""
    dynamic var userImage:String = ""
    dynamic var userIsTrusted:Bool = false
    dynamic var userIsCelebrity:Bool = false
    dynamic var _id:String = ""
    dynamic var noOfLikes:Int = 0
    dynamic var isApprovedByCelebrity:Bool = false
    dynamic var celebrityName:String = ""
    dynamic var isCelebrityTrusted:Bool = false
    dynamic var celebrityId:String = ""
    
    override static func primaryKey()->String{
        return "_id"
    }
    
    convenience init(from r:Reply){
        self.init()
        updatedTimestamp = r.updatedTimestamp
        chatroomId = r.chatroomId
        comment = r.comment
        createdAt = r.createdAt
        noOfDislikes = r.noOfDislikes
        noOfLaughs = r.noOfLaughs
        noOfLikes = r.noOfLikes
        commentId = r.commentId
        noOfClaps = r.noOfClaps
        userFullname = r.user.fullName
        userId = r.user.id
        userName = r.user.userName
        userImage = r.user.image
        userIsTrusted = r.user.isTrusted
        userIsCelebrity = r.user.isCelebrity
        _id = r._id
        isLiked = r.isLiked
        isDisliked = r.isDisliked
        isClap = r.isClap
        isLaugh = r.isLaugh
        isLikedByCreator = r.isLikedByCreator
        isApprovedByCelebrity = r.isApprovedByCelebrity
        celebrityName = r.celebrity.fullName
        isCelebrityTrusted = r.celebrity.isTrusted
        celebrityId = r.celebrity._id
    }
    
    func replyExists(_ replyId : String) -> Bool{
        let realm = RealmController.shared.realm
        return realm.object(ofType: ReplyDBM.self, forPrimaryKey: replyId) != nil
    }

    func update(_ replyId:String){
        RealmController.shared.fetchObject(ReplyDBM.self, primaryKey: replyId) { (room) in
            if let r = room{
                let realm = r.realm!
                try! realm.write {
                    realm.add(self, update: .all)
                }
            }
        }
    }
    
}

@objcMembers class MyRecapCommentDBM : Object{
    dynamic var updatedTimestamp:Double = 0
    dynamic var commentId:String = ""
    dynamic var isMoreThanOneReply:Bool = false
    dynamic var comment:String = ""
    dynamic var isDisliked:Bool = false
    dynamic var noOfLikes:Int = 0
    dynamic var _id:String = ""
    dynamic var totalReactions:Int = 0
    dynamic var noOfDislikes:Int = 0
    dynamic var isClap:Bool = false
    dynamic var createdAt:Double = 0
    dynamic var noOfClaps:Int = 0
    dynamic var isLiked:Bool = false
    dynamic var noOfLaughs:Int = 0
    dynamic var chatroomId:String = ""
    dynamic var userId:String = ""
    dynamic var userName:String = ""
    dynamic var userFullname:String = ""
    dynamic var userImage:String = ""
    dynamic var userTrusted:Bool = false
    dynamic var userCelebrity:Bool = false
    dynamic var isLaugh:Bool = false
    dynamic var replyUserName:String = ""
    dynamic var replyUserFullName:String = ""
    dynamic var replyUserImage:String = ""
    dynamic var replyUserIsTrusted:Bool = false
    dynamic var replyUserIsCelebrity:Bool = false
    dynamic var replyUserId:String = ""
    dynamic var replyCommnet:String = ""
    dynamic var replyCreatedAt:Double = 0
    dynamic var isLikedByCreator:Bool = false
    dynamic var isApprovedByCelebrity:Bool = false
    dynamic var isCommentSaved:Bool = false
    dynamic var celebrityName:String = ""
    dynamic var isCelebrityTrusted:Bool = false
    dynamic var celebrityId:String = ""
    dynamic var chatroomName:String = ""
    dynamic var eventName:String = ""
    dynamic var eventId:String = ""
    
    override static func primaryKey()->String{
        return "_id"
    }
    
    convenience init(from c:Comment){
        self.init()
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
        userFullname = c.user.fullName
        userId = c.user.id
        userName = c.user.userName
        userImage = c.user.image
        userTrusted = c.user.isTrusted
        userCelebrity = c.user.isCelebrity
        isLaugh = c.isLaugh
        isLikedByCreator = c.isLikedByCreator
        let rep = replyList(r: c.user_reply).first
        replyUserName = rep?.userName ?? ""
        replyUserFullName = rep?.userFullname ?? ""
        replyUserImage = rep?.userImage ?? ""
        replyUserIsTrusted = rep?.userIsTrusted ?? false
        replyUserId = rep?.userId ?? ""
        replyCommnet = rep?.comment ?? ""
        replyUserIsCelebrity = rep?.userIsCelebrity ?? false
        replyCreatedAt = rep?.createdAt ?? 0
        isApprovedByCelebrity = c.isApprovedByCelebrity
        isCommentSaved = c.isCommentSaved
        celebrityName = c.celebrity.fullName
        isCelebrityTrusted = c.celebrity.isTrusted
        celebrityId = c.celebrity._id
        chatroomId = c.chatroom._id
        chatroomName = c.chatroom.name
        eventId = c.event.id
        eventName = c.event.name
    }
    
    static func commentExists(_ commnetId : String) -> Bool{
        let realm = RealmController.shared.realm
        return realm.object(ofType: MyRecapCommentDBM.self, forPrimaryKey: commnetId) != nil
    }

    func update(){
        RealmController.shared.fetchObject(MyRecapCommentDBM.self, primaryKey: _id) { (room) in
            if let r = room{
                let realm = r.realm!
                try! realm.write {
                    realm.add(self, update: .all)
                }
            }
        }
    }
    
    
    var replyArray:[Reply]{
        var ar:[Reply] = []
        if replyCommnet.isEmpty{
            printDebug("Do nothing....")
        }else{
            var u = User(JSON())
            u.fullName = replyUserFullName
            u.userName = replyUserName
            u.image = replyUserImage
            u.isTrusted = replyUserIsTrusted
            u.id = replyUserId
            u.isCelebrity = replyUserIsCelebrity
            var r = Reply(JSON())
            r.user = u
            r.comment = replyCommnet
            r.createdAt = replyCreatedAt
            ar.append(r)
        }
        return ar
    }
    
    func replyList(r:[Reply]) -> List<ReplyDBM>{
        let replies  = List<ReplyDBM>()
        for i in r{
            replies.append(ReplyDBM (from: i))
        }
        return replies
    }
}

@objcMembers class FollowingRecapCommentDBM : Object{
    dynamic var updatedTimestamp:Double = 0
    dynamic var commentId:String = ""
    dynamic var isMoreThanOneReply:Bool = false
    dynamic var comment:String = ""
    dynamic var isDisliked:Bool = false
    dynamic var noOfLikes:Int = 0
    dynamic var _id:String = ""
    dynamic var totalReactions:Int = 0
    dynamic var noOfDislikes:Int = 0
    dynamic var isClap:Bool = false
    dynamic var createdAt:Double = 0
    dynamic var noOfClaps:Int = 0
    dynamic var isLiked:Bool = false
    dynamic var noOfLaughs:Int = 0
    dynamic var chatroomId:String = ""
    dynamic var userId:String = ""
    dynamic var userName:String = ""
    dynamic var userFullname:String = ""
    dynamic var userImage:String = ""
    dynamic var userTrusted:Bool = false
    dynamic var userCelebrity:Bool = false
    dynamic var isLaugh:Bool = false
    dynamic var replyUserName:String = ""
    dynamic var replyUserFullName:String = ""
    dynamic var replyUserImage:String = ""
    dynamic var replyUserIsTrusted:Bool = false
    dynamic var replyUserIsCelebrity:Bool = false
    dynamic var replyUserId:String = ""
    dynamic var replyCommnet:String = ""
    dynamic var replyCreatedAt:Double = 0
    dynamic var isLikedByCreator:Bool = false
    dynamic var isApprovedByCelebrity:Bool = false
    dynamic var isCommentSaved:Bool = false
    dynamic var celebrityName:String = ""
    dynamic var isCelebrityTrusted:Bool = false
    dynamic var celebrityId:String = ""
    dynamic var chatroomName:String = ""
    dynamic var eventName:String = ""
    dynamic var eventId:String = ""
    
    override static func primaryKey()->String{
        return "_id"
    }
    
    convenience init(from c:Comment){
        self.init()
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
        userFullname = c.user.fullName
        userId = c.user.id
        userName = c.user.userName
        userImage = c.user.image
        userTrusted = c.user.isTrusted
        userCelebrity = c.user.isCelebrity
        isLaugh = c.isLaugh
        isLikedByCreator = c.isLikedByCreator
        let rep = replyList(r: c.user_reply).first
        replyUserName = rep?.userName ?? ""
        replyUserFullName = rep?.userFullname ?? ""
        replyUserImage = rep?.userImage ?? ""
        replyUserIsTrusted = rep?.userIsTrusted ?? false
        replyUserId = rep?.userId ?? ""
        replyCommnet = rep?.comment ?? ""
        replyUserIsCelebrity = rep?.userIsCelebrity ?? false
        replyCreatedAt = rep?.createdAt ?? 0
        isApprovedByCelebrity = c.isApprovedByCelebrity
        isCommentSaved = c.isCommentSaved
        celebrityName = c.celebrity.fullName
        isCelebrityTrusted = c.celebrity.isTrusted
        celebrityId = c.celebrity._id
        chatroomId = c.chatroom._id
        chatroomName = c.chatroom.name
        eventId = c.event.id
        eventName = c.event.name
    }
    
    static func commentExists(_ commnetId : String) -> Bool{
        let realm = RealmController.shared.realm
        return realm.object(ofType: FollowingRecapCommentDBM.self, forPrimaryKey: commnetId) != nil
    }

    func update(){
        RealmController.shared.fetchObject(FollowingRecapCommentDBM.self, primaryKey: _id) { (room) in
            if let r = room{
                let realm = r.realm!
                try! realm.write {
                    realm.add(self, update: .all)
                }
            }
        }
    }
    
    
    var replyArray:[Reply]{
        var ar:[Reply] = []
        if replyCommnet.isEmpty{
            printDebug("Do nothing....")
        }else{
            var u = User(JSON())
            u.fullName = replyUserFullName
            u.userName = replyUserName
            u.image = replyUserImage
            u.isTrusted = replyUserIsTrusted
            u.id = replyUserId
            u.isCelebrity = replyUserIsCelebrity
            var r = Reply(JSON())
            r.user = u
            r.comment = replyCommnet
            r.createdAt = replyCreatedAt
            ar.append(r)
        }
        return ar
    }
    
    func replyList(r:[Reply]) -> List<ReplyDBM>{
        let replies  = List<ReplyDBM>()
        for i in r{
            replies.append(ReplyDBM (from: i))
        }
        return replies
    }
}



@objcMembers class AllRecapCommentDBM : Object{
    dynamic var updatedTimestamp:Double = 0
    dynamic var commentId:String = ""
    dynamic var isMoreThanOneReply:Bool = false
    dynamic var comment:String = ""
    dynamic var isDisliked:Bool = false
    dynamic var noOfLikes:Int = 0
    dynamic var _id:String = ""
    dynamic var totalReactions:Int = 0
    dynamic var noOfDislikes:Int = 0
    dynamic var isClap:Bool = false
    dynamic var createdAt:Double = 0
    dynamic var noOfClaps:Int = 0
    dynamic var isLiked:Bool = false
    dynamic var noOfLaughs:Int = 0
    dynamic var chatroomId:String = ""
    dynamic var userId:String = ""
    dynamic var userName:String = ""
    dynamic var userFullname:String = ""
    dynamic var userImage:String = ""
    dynamic var userTrusted:Bool = false
    dynamic var userCelebrity:Bool = false
    dynamic var isLaugh:Bool = false
    dynamic var replyUserName:String = ""
    dynamic var replyUserFullName:String = ""
    dynamic var replyUserImage:String = ""
    dynamic var replyUserIsTrusted:Bool = false
    dynamic var replyUserIsCelebrity:Bool = false
    dynamic var replyUserId:String = ""
    dynamic var replyCommnet:String = ""
    dynamic var replyCreatedAt:Double = 0
    dynamic var isLikedByCreator:Bool = false
    dynamic var isApprovedByCelebrity:Bool = false
    dynamic var isCommentSaved:Bool = false
    dynamic var celebrityName:String = ""
    dynamic var isCelebrityTrusted:Bool = false
    dynamic var celebrityId:String = ""
    dynamic var chatroomName:String = ""
    dynamic var eventName:String = ""
    dynamic var eventId:String = ""
    
    override static func primaryKey()->String{
        return "_id"
    }
    
    convenience init(from c:Comment){
        self.init()
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
        userFullname = c.user.fullName
        userId = c.user.id
        userName = c.user.userName
        userImage = c.user.image
        userTrusted = c.user.isTrusted
        userCelebrity = c.user.isCelebrity
        isLaugh = c.isLaugh
        isLikedByCreator = c.isLikedByCreator
        let rep = replyList(r: c.user_reply).first
        replyUserName = rep?.userName ?? ""
        replyUserFullName = rep?.userFullname ?? ""
        replyUserImage = rep?.userImage ?? ""
        replyUserIsTrusted = rep?.userIsTrusted ?? false
        replyUserId = rep?.userId ?? ""
        replyCommnet = rep?.comment ?? ""
        replyUserIsCelebrity = rep?.userIsCelebrity ?? false
        replyCreatedAt = rep?.createdAt ?? 0
        isApprovedByCelebrity = c.isApprovedByCelebrity
        isCommentSaved = c.isCommentSaved
        celebrityName = c.celebrity.fullName
        isCelebrityTrusted = c.celebrity.isTrusted
        celebrityId = c.celebrity._id
        chatroomId = c.chatroom._id
        chatroomName = c.chatroom.name
        eventId = c.event.id
        eventName = c.event.name
    }
    
    static func commentExists(_ commnetId : String) -> Bool{
        let realm = RealmController.shared.realm
        return realm.object(ofType: AllRecapCommentDBM.self, forPrimaryKey: commnetId) != nil
    }

    func update(){
        RealmController.shared.fetchObject(AllRecapCommentDBM.self, primaryKey: _id) { (room) in
            if let r = room{
                let realm = r.realm!
                try! realm.write {
                    realm.add(self, update: .all)
                }
            }
        }
    }
    
    
    var replyArray:[Reply]{
        var ar:[Reply] = []
        if replyCommnet.isEmpty{
            printDebug("Do nothing....")
        }else{
            var u = User(JSON())
            u.fullName = replyUserFullName
            u.userName = replyUserName
            u.image = replyUserImage
            u.isTrusted = replyUserIsTrusted
            u.id = replyUserId
            u.isCelebrity = replyUserIsCelebrity
            var r = Reply(JSON())
            r.user = u
            r.comment = replyCommnet
            r.createdAt = replyCreatedAt
            ar.append(r)
        }
        return ar
    }
    
    func replyList(r:[Reply]) -> List<ReplyDBM>{
        let replies  = List<ReplyDBM>()
        for i in r{
            replies.append(ReplyDBM (from: i))
        }
        return replies
    }
}



@objcMembers class CommentDBM : Object{
    dynamic var updatedTimestamp:Double = 0
    dynamic var commentId:String = ""
    dynamic var isMoreThanOneReply:Bool = false
    dynamic var comment:String = ""
    dynamic var isDisliked:Bool = false
    dynamic var noOfLikes:Int = 0
    dynamic var _id:String = ""
    dynamic var totalReactions:Int = 0
    dynamic var noOfDislikes:Int = 0
    dynamic var isClap:Bool = false
    dynamic var createdAt:Double = 0
    dynamic var noOfClaps:Int = 0
    dynamic var isLiked:Bool = false
    dynamic var noOfLaughs:Int = 0
    dynamic var chatroomId:String = ""
    dynamic var userId:String = ""
    dynamic var userName:String = ""
    dynamic var userFullname:String = ""
    dynamic var userImage:String = ""
    dynamic var userTrusted:Bool = false
    dynamic var userCelebrity:Bool = false
    dynamic var isLaugh:Bool = false
    dynamic var replyUserName:String = ""
    dynamic var replyUserFullName:String = ""
    dynamic var replyUserImage:String = ""
    dynamic var replyUserIsTrusted:Bool = false
    dynamic var replyUserIsCelebrity:Bool = false
    dynamic var replyUserId:String = ""
    dynamic var replyCommnet:String = ""
    dynamic var replyCreatedAt:Double = 0
    dynamic var isLikedByCreator:Bool = false
    dynamic var isApprovedByCelebrity:Bool = false
    dynamic var isCommentSaved:Bool = false
    dynamic var celebrityName:String = ""
    dynamic var isCelebrityTrusted:Bool = false
    dynamic var celebrityId:String = ""
    dynamic var chatroomName:String = ""
    dynamic var eventName:String = ""
    dynamic var eventId:String = ""
    
    override static func primaryKey()->String{
        return "_id"
    }
    
    convenience init(from c:Comment){
        self.init()
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
        userFullname = c.user.fullName
        userId = c.user.id
        userName = c.user.userName
        userImage = c.user.image
        userTrusted = c.user.isTrusted
        userCelebrity = c.user.isCelebrity
        isLaugh = c.isLaugh
        isLikedByCreator = c.isLikedByCreator
        let rep = replyList(r: c.user_reply).first
        replyUserName = rep?.userName ?? ""
        replyUserFullName = rep?.userFullname ?? ""
        replyUserImage = rep?.userImage ?? ""
        replyUserIsTrusted = rep?.userIsTrusted ?? false
        replyUserId = rep?.userId ?? ""
        replyCommnet = rep?.comment ?? ""
        replyUserIsCelebrity = rep?.userIsCelebrity ?? false
        replyCreatedAt = rep?.createdAt ?? 0
        isApprovedByCelebrity = c.isApprovedByCelebrity
        isCommentSaved = c.isCommentSaved
        celebrityName = c.celebrity.fullName
        isCelebrityTrusted = c.celebrity.isTrusted
        celebrityId = c.celebrity._id
        chatroomId = c.chatroom._id
        chatroomName = c.chatroom.name
        eventId = c.event.id
        eventName = c.event.name
    }
    
    static func commentExists(_ commnetId : String) -> Bool{
        let realm = RealmController.shared.realm
        return realm.object(ofType: CommentDBM.self, forPrimaryKey: commnetId) != nil
    }

    func update(){
        RealmController.shared.fetchObject(CommentDBM.self, primaryKey: _id) { (room) in
            if let r = room{
                let realm = r.realm!
                try! realm.write {
                    realm.add(self, update: .all)
                }
            }
        }
    }
    
    
    var replyArray:[Reply]{
        var ar:[Reply] = []
        if replyCommnet.isEmpty{
            printDebug("Do nothing....")
        }else{
            var u = User(JSON())
            u.fullName = replyUserFullName
            u.userName = replyUserName
            u.image = replyUserImage
            u.isTrusted = replyUserIsTrusted
            u.id = replyUserId
            u.isCelebrity = replyUserIsCelebrity
            var r = Reply(JSON())
            r.user = u
            r.comment = replyCommnet
            r.createdAt = replyCreatedAt
            ar.append(r)
        }
        return ar
    }
    
    func replyList(r:[Reply]) -> List<ReplyDBM>{
        let replies  = List<ReplyDBM>()
        for i in r{
            replies.append(ReplyDBM (from: i))
        }
        return replies
    }
}


@objcMembers class NotificationDBM : Object{
    dynamic var roomId:String = ""
    dynamic var userId:String = ""
    dynamic var isRead:Bool = false
    dynamic var _id:String = ""
    dynamic var _notificationType:Int = 0
    dynamic var title:String = ""
    dynamic var message:String = ""
    dynamic var fromUserimage:String = ""
    dynamic var fromUserRequestId:String = ""
    dynamic var fromUsername:String = ""
    dynamic var _fromUserinviteStatus:String = ""
    dynamic var _fromUserfollowStatus:String = ""
    dynamic var fromUser_id:String = ""
    dynamic var fromUserisPrivateAccount:Bool = false
    dynamic var fromUserisTrusted:Bool = false
    dynamic var createdAt:Double = 0
    dynamic var userImage:String = ""
    dynamic var chatroomImage:String = ""
    dynamic var _roomType:String = ""
    dynamic var isInvitedByCreator:Bool = false
    dynamic var eventname:String = ""
    dynamic var tagImage:String = ""
    
    override static func primaryKey()->String{
        return "_id"
    }
    
    var notificationType:PushTypes{
        return PushTypes(rawValue: _notificationType) ?? .adminNotification
    }
    
    var roomType:RoomType{
        return RoomType(val: _roomType)
    }
    var fromUserinviteStatus:RequestStatus{
        return RequestStatus(_fromUserinviteStatus)
    }
    var fromUserfollowStatus:FollowStatus{
        return FollowStatus(rawValue: _fromUserfollowStatus) ?? .none
    }
    var fromUser:FromUser{
        var u = FromUser(JSON())
        u._id = fromUser_id
        u.image = fromUserimage
        u.followStatus = fromUserfollowStatus
        u.inviteStatus = fromUserinviteStatus
        u.isPrivateAccount = fromUserisPrivateAccount
        u.isTrusted = fromUserisTrusted
        u.name = fromUsername
        u.requestId = fromUserRequestId
        return u
    }
    
    convenience init(_ n:NotificationModel){
        self.init()
        roomId = n.roomId
        userId = n.userId
        isRead = n.isRead
        _id = n._id
        _notificationType = n.notificationType.rawValue
        title = n.title
        message = n.message
        let u = n.fromUser
        fromUser_id = u?._id ?? ""
        fromUserimage = u?._id ?? ""
        _fromUserfollowStatus = u?.followStatus.rawValue ?? ""
        _fromUserinviteStatus = u?.inviteStatus.rawValue ?? ""
        fromUserisPrivateAccount = u?.isPrivateAccount ?? false
        fromUserisTrusted = u?.isTrusted ?? false
        fromUsername = u?.name ?? ""
        fromUserRequestId = u?.requestId ?? ""
        createdAt = n.createdAt
        userImage = n.userImage
        chatroomImage = n.chatroomImage
        _roomType = n.roomType.rawValue
        isInvitedByCreator = n.isInvitedByCreator
        eventname = n.eventname
        tagImage = n.tagImage
    }
    
    static func notificationExists(_ commnetId : String) -> Bool{
        let realm = RealmController.shared.realm
        return realm.object(ofType: NotificationDBM.self, forPrimaryKey: commnetId) != nil
    }

    func update(){
        RealmController.shared.fetchObject(NotificationDBM.self, primaryKey: _id) { (room) in
            if let r = room{
                let realm = r.realm!
                try! realm.write {
                    realm.add(self, update: .all)
                }
            }
        }
    }
}



@objcMembers class NotificationListDBM : Object{
    dynamic var list = List<NotificationDBM>()
    dynamic var _id = UserModel.main.userId
    dynamic var unreadCount:Int = 0
    
    override static func primaryKey()->String{
        return "_id"
    }
    
}


@objcMembers class  UserProfileDBM : Object{
    
    dynamic var like:Int = 0
    dynamic var isPaymentDone:Bool = false
    dynamic var isFollow:Bool = false
    dynamic var userName:String = ""
    dynamic var profilePicture:String = ""
    dynamic var laugh:Int = 0
    dynamic var followingCount:Int = 0
    dynamic var followersCount:Int = 0
    dynamic var _id:String = ""
    dynamic var isMostLikedProfile:Bool = false
    dynamic var isPrivateAccount:Bool = false
    dynamic var isEmailVerified:Bool = false
    dynamic var isMobileVerified:Bool = false
    dynamic var dislike:Int = 0
    dynamic var isHideEngagementStats:Bool = false
    dynamic var bio:String = ""
    dynamic var status:Bool = false
    dynamic var firstName:String = ""
    dynamic var isGuestAccount:Bool = false
    dynamic var clap:Int = 0
    dynamic var userType:String = ""
    dynamic var lastName:String = ""
    dynamic var isCelebrity:Bool = false
    dynamic var fullName:String = ""
    dynamic var profileLink:String = ""
    dynamic var isTrusted:Bool = false
    dynamic var email:String = ""
    dynamic var mobileNo:String = ""
    dynamic var countryCode:String = ""
    dynamic var _toUserFollowStatus:String = ""
    dynamic var _myfollowStatus:String = ""
    dynamic var rank:Int = 0
    dynamic var category:String = ""
    dynamic var _type:String = ""
    dynamic var rankString:String = ""
    dynamic var _rankingType:String = ""
    
    override class func primaryKey() -> String? {
        return "_id"
    }
    
    convenience init(_ u:UserProfileModel){
        self.init()
        like = u.like
        followingCount = u.followingCount
        laugh = u.laugh
        followersCount = u.followersCount
        dislike = u.dislike
        clap = u.clap
        isPaymentDone = u.isPaymentDone
        isFollow = u.isFollow
        isMostLikedProfile = u.isMostLikedProfile
        isPrivateAccount = u.isPrivateAccount
        isEmailVerified = u.isEmailVerified
        isMobileVerified = u.isMobileVerified
        isHideEngagementStats = u.isHideEngagementStats
        status = u.status
        isGuestAccount = u.isGuestAccount
        isCelebrity = u.isCelebrity
        profilePicture = u.profilePicture
        userName = u.userName
        _id = u._id
        bio = u.bio
        firstName = u.firstName
        userType = u.userType
        lastName = u.lastName
        fullName = (firstName.capitalizedFirst + " " + lastName.capitalizedFirst).byRemovingLeadingTrailingWhiteSpaces
        profileLink = u.profileLink
        category = u.rankData.category
        rank = u.rankData.rank
        _type = u.rankData.type.rawValue
        rankString = u.rankData.rankString
        _rankingType = u.rankData.rankingType.rawValue
        isTrusted = u.isTrusted
        email = u.email
        mobileNo = u.mobileNo
        countryCode = u.countryCode
        _toUserFollowStatus = u.toUserFollowStatus.rawValue
        _myfollowStatus = u.myfollowStatus.rawValue
    }
    
    var type:LeaderBordType{
        return LeaderBordType(rawValue: _type) ?? .like
    }
    
    var rankingType:RankingType{
        return RankingType(rawValue: _rankingType) ?? .category
    }
    
    var toUserFollowStatus:FollowStatus{
        return FollowStatus(rawValue: _toUserFollowStatus) ?? .none
    }
    var myfollowStatus:FollowStatus{
        return FollowStatus(rawValue: _myfollowStatus) ?? .none
    }
    
    static func notificationExists(_ userId : String) -> Bool{
        let realm = RealmController.shared.realm
        return realm.object(ofType: UserProfileDBM.self, forPrimaryKey: userId) != nil
    }

    func update(){
        RealmController.shared.fetchObject(NotificationDBM.self, primaryKey: _id) { (room) in
            if let r = room{
                let realm = r.realm!
                try! realm.write {
                    realm.add(self, update: .all)
                }
            }
        }
    }
}
    
