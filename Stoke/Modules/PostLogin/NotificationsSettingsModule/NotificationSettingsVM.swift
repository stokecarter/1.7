//
//  NotificationSettingsVM.swift
//  Stoke
//
//  Created by Admin on 19/05/21.
//

import Foundation
import SwiftyJSON



/*
 "newChatRoomInvite" : true,
 "replyOnComment" : true,
 "recapAvailable" : true,
 "paymentConfirmations" : true,
 "chatRoomCreationByFollower" : true,
 "newFollower" : true,
 "saveTag" : true,
 "yourCreatedRoomLive" : true,
 "roomRequestAccepted" : true,
 "savedChatRoomLive" : true,
 "celebrityApprovesComment" : true,
 "eventReminder" : true,
 "savedRoomEvent" : true,
 "recapAvailableForYourCreatedRoom" : true,
 "mentionInChat" : true,
 "followerActiveInChatroom" : true,
 "requestToJoinChatroom" : true
 */


struct NotificationsStatus {
    var mentionInChat:Bool
    var newFollower:Bool
    var followerActiveInChatroom:Bool
    var newChatRoomInvite:Bool
    var paymentConfirmations:Bool
    var savedChatRoomLive:Bool
    var chatRoomCreationByFollower:Bool
    var celebrityApprovesComment:Bool
    var recapAvailable:Bool
    var saveTag:Bool
    var savedRoomEvent:Bool
    
    var replyOnComment:Bool
    var yourCreatedRoomLive:Bool
    var roomRequestAccepted:Bool
    var eventReminder:Bool
    var recapAvailableForYourCreatedRoom:Bool
    var requestToJoinChatroom:Bool
    
    init(_ json:JSON){
        mentionInChat = json["mentionInChat"].boolValue
        newFollower = json["newFollower"].boolValue
        followerActiveInChatroom = json["followerActiveInChatroom"].boolValue
        newChatRoomInvite = json["newChatRoomInvite"].boolValue
        paymentConfirmations = json["paymentConfirmations"].boolValue
        savedChatRoomLive = json["savedChatRoomLive"].boolValue
        chatRoomCreationByFollower = json["chatRoomCreationByFollower"].boolValue
        celebrityApprovesComment = json["celebrityApprovesComment"].boolValue
        recapAvailable = json["recapAvailable"].boolValue
        saveTag = json["saveTag"].boolValue
        savedRoomEvent = json["savedRoomEvent"].boolValue
        
        replyOnComment = json["replyOnComment"].boolValue
        yourCreatedRoomLive = json["yourCreatedRoomLive"].boolValue
        roomRequestAccepted = json["roomRequestAccepted"].boolValue
        eventReminder = json["eventReminder"].boolValue
        recapAvailableForYourCreatedRoom = json["recapAvailableForYourCreatedRoom"].boolValue
        requestToJoinChatroom = json["requestToJoinChatroom"].boolValue

        
        
    }
}



class NotificationSettingsVM{
    
    private let web:NetworkLayer!
    var model:NotificationsStatus = NotificationsStatus(JSON()){
        didSet{
            if let r = reloadData { r()}
        }
    }
    var reloadData:(()->())?
    var dataSource:[(String,Bool)]{
        return [("Mentioned in a chat",model.mentionInChat),
                ("New followers",model.newFollower),
                ("Followers active in chat room",model.followerActiveInChatroom),
                ("Room Invites",model.newChatRoomInvite),
                ("Payment confirmations",model.paymentConfirmations),
                ("Saved Room Is Live",model.savedChatRoomLive),
                ("Room Created by Following",model.chatRoomCreationByFollower),
                ("Celebrity approves Comment",model.celebrityApprovesComment),
                ("Saved Room Recap Available",model.recapAvailable),
                ("Event for Saved Tag Is Live",model.saveTag),
                ("Event for Saved Room Is Live",model.savedRoomEvent),
                ("Comment Reply",model.replyOnComment),
                ("Created Room Is Live",model.yourCreatedRoomLive),
                ("Room Request Accepted",model.roomRequestAccepted),
                ("Upcoming Event for Saved Tag",model.eventReminder),
                ("Created Room Recap Available",model.recapAvailableForYourCreatedRoom),
                ("Join Room Request",model.requestToJoinChatroom)]
    }
    
    init(_ web:NetworkLayer){
        self.web = web
        getStatus()
    }
    
    func getStatus(){
        web.request(from: WebService.userNotificationSettings, param: [:], method: .GET, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                DispatchQueue.main.async { [weak self] in
                    self?.model = NotificationsStatus(json[ApiKey.data])
                }
                printDebug(json)
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    
    
    func updateStatus(_ completion:@escaping()->()){
        let para:JSONDictionary = [/*"mentionInChat": model.mentionInChat,
                                   */"newFollower": model.newFollower,
                                   "followerActiveInChatroom": model.followerActiveInChatroom,
                                   "newChatRoomInvite": true,
                                   /*"paymentConfirmations": model.paymentConfirmations,
                                   */"savedChatRoomLive": model.savedChatRoomLive,
                                   "chatRoomCreationByFollower": model.chatRoomCreationByFollower,
                                   "celebrityApprovesComment": model.celebrityApprovesComment,
                                   "recapAvailable": model.recapAvailable,
                                   "saveTag": model.saveTag,
            "savedRoomEvent":model.savedRoomEvent,
            "replyOnComment":model.replyOnComment,
            "yourCreatedRoomLive":model.yourCreatedRoomLive,
            "roomRequestAccepted":model.roomRequestAccepted,
            "eventReminder":model.eventReminder,
            "recapAvailableForYourCreatedRoom":model.recapAvailableForYourCreatedRoom,
            "requestToJoinChatroom":model.requestToJoinChatroom]
        web.request(from: WebService.userNotificationSettings, param: para, method: .PUT, header: [:], loader: true) { (data, e) in
            guard let d = data else {
                CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                if json[ApiKey.code].intValue != 201{
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                }else{
                    CommonFunctions.showToastWithMessage("Notification Settings updated successfully.", theme: .success)
                }
                completion()
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    
}
