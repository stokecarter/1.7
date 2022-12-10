//
//  NotificationHandler.swift
//  Stoke
//
//  Created by Admin on 21/05/21.
//

import Foundation
import SwiftyJSON
import FittedSheets


enum PushTypes:Int{
    case newFollow = 1
    case followersActiveInChatroom = 2
    case newChatroomInvite = 3
    case paymentConfirmation = 4
    case savedChatroomLive = 5
    case chatroomCreatedByFollower = 6
    case celebrityApprovesCommnets = 7
    case recapAvailabel = 8
    case adminNotification = 9
    case eventStarted = 10
    case chatroomStarted = 11
    case requestToJoin = 12
    case eventReminder = 13
    case celebrityPush = 14
    case requestAccepted = 15
    case replyOnCommnet = 16
    case engagementPoping = 17
    case newFollowRequest = 18
    case newFollowRequestAccept = 19
    
}




/*
 
 1///
 {
 "_id" : ObjectId("60adebea4ed9367d45f646bc"),
 "status" : "active",
 "isRead" : false,
 "recipientId" : ObjectId("60a49da49510ab6746e34822"),
 "typeData" : {
 "_id" : ObjectId("6037523564cf1a0eb87f038e"),
 "name" : "arpit",
 "image" : "https://s3.us-east-1.amazonaws.com/appinventiv-development/1621280646.png"
 },
 "title" : "Follow user",
 "message" : "arpit has started following you.",
 "notificationType" : 1,
 "createdAt" : ISODate("2021-05-26T12:04:18.332+05:30"),
 "updatedAt" : ISODate("2021-05-26T12:08:10.692+05:30")
 }
 
 2///
 {
 "_id" : ObjectId("60ade51a4ed9367d45f646af"),
 "status" : "active",
 "isRead" : false,
 "recipientId" : ObjectId("6059da908f73821d196599b7"),
 "typeData" : {
 "_id" : ObjectId("60acddb98164926a04864277"),
 "name" : "gdfhhf",
 "image" : "https://appinventiv-development.s3.amazonaws.com/chatrooms/1621941219892.png"
 },
 "title" : "Follower active in chatroom",
 "message" : "ayu6788 active in chatroom gdfhhf",
 "notificationType" : 2,
 "createdAt" : ISODate("2021-05-26T11:35:14.657+05:30"),
 "updatedAt" : ISODate("2021-05-26T12:08:10.692+05:30")
 }
 
 3///
 {
 "_id" : ObjectId("60adc2f9f7eacc76029927b3"),
 "status" : "active",
 "isRead" : false,
 "recipientId" : ObjectId("6076841946a4dd0f13ca72e4"),
 "typeData" : {
 "_id" : ObjectId("60acd5131b7d6335ceac9508"),
 "name" : "Paid Paid",
 "image" : "https://appinventiv-development.s3.amazonaws.com/chatrooms/1621939470027.png"
 },
 "fromUser" : {
 "_id" : ObjectId("6037523564cf1a0eb87f038e"),
 "name" : "arpit",
 "image" : "https://s3.us-east-1.amazonaws.com/appinventiv-development/1621280646.png",
 "requestId" : ObjectId("60adc2f9f7eacc76029927b2"),
 "inviteStatus" : "pending"
 },
 "title" : "New Room Invite 🎟",
 "message" : "arpit has invited you to Paid Paid in the event paiddd",
 "notificationType" : 3,
 "createdAt" : ISODate("2021-05-26T09:09:37.821+05:30"),
 "updatedAt" : ISODate("2021-05-26T12:08:10.692+05:30")
 }
 4///
 5///
 6///
 {
 "_id" : ObjectId("60add55ef7eacc76029927e3"),
 "status" : "active",
 "isRead" : false,
 "recipientId" : ObjectId("6059da908f73821d196599b7"),
 "typeData" : {
 "_id" : ObjectId("60add55ef7eacc76029927e0"),
 "name" : "bhhhh",
 "image" : "https://appinventiv-development.s3.amazonaws.com/chatrooms/1621941219892.png"
 },
 "title" : "Chatroom created",
 "message" : "ayu6788 just created a room in jjj",
 "notificationType" : 6,
 "createdAt" : ISODate("2021-05-26T10:28:06.691+05:30"),
 "updatedAt" : ISODate("2021-05-26T12:08:10.692+05:30")
 }
 7///
 {
 "_id" : ObjectId("60abf5f5fbead2094009095d"),
 "status" : "active",
 "isRead" : false,
 "recipientId" : ObjectId("60a49da49510ab6746e34822"),
 "typeData" : {
 "_id" : ObjectId("60abf2adb9bad3674c0eb230"),
 "name" : "v g g",
 "image" : "https://appinventiv-development.s3.amazonaws.com/chatrooms/1621881497303.png"
 },
 "title" : "Celebrity Approval! 🎖",
 "message" : "ayu-gmail-05 approved your comment: n",
 "notificationType" : 7,
 "createdAt" : ISODate("2021-05-25T00:22:37.980+05:30"),
 "updatedAt" : ISODate("2021-05-26T12:08:10.692+05:30")
 }
 8///
 {
 "_id" : ObjectId("60a4dfe8a57cf967cb5b191c"),
 "notificationType" : 8,
 "status" : "delete",
 "isRead" : true,
 "recipientId" : ObjectId("608fb3b0e912642391d964b2"),
 "typeData" : {
 "_id" : ObjectId("60806b0552210841d6aac138"),
 "name" : "ayuayu",
 "image" : "https://appinventiv-development.s3.amazonaws.com/chatrooms/973883.png"
 },
 "title" : "Celebrity approves comment",
 "message" : "bh",
 "createdAt" : ISODate("2021-05-19T15:22:40.392+05:30"),
 "updatedAt" : ISODate("2021-05-26T12:08:10.692+05:30")
 }
 9///
 {
 "_id" : ObjectId("60a696aa0f328f41c08bec8f"),
 "status" : "delete",
 "isRead" : true,
 "notificationType" : 9,
 "typeData" : {
 "_id" : ObjectId("60a696a80f328f41c08bec8c"),
 "name" : "Title test",
 "image" : "https://appinventiv-development.s3.amazonaws.com/admin_icon_notification%403x.png"
 },
 "title" : "Title test",
 "message" : "description Test",
 "recipientId" : ObjectId("60a49da49510ab6746e34822"),
 "createdAt" : ISODate("2021-05-20T22:34:42.916+05:30"),
 "updatedAt" : ISODate("2021-05-26T12:08:10.692+05:30")
 }
 10///
 11///
 12///
 {
 "_id" : ObjectId("60abfc0b73407b16ee0503b9"),
 "status" : "active",
 "isRead" : false,
 "recipientId" : ObjectId("6059da908f73821d196599b7"),
 "typeData" : {
 "_id" : ObjectId("60abf6fbfbead20940090960"),
 "name" : "f gg",
 "image" : "https://appinventiv-development.s3.amazonaws.com/chatrooms/1621882599221.png"
 },
 "fromUser" : {
 "_id" : ObjectId("6059da908f73821d196599b7"),
 "name" : "ayu-gmail-05",
 "image" : "https://appinventiv-development.s3.amazonaws.com/cropped2303269315352896325.jpg1621258166123.null",
 "requestId" : ObjectId("60abfc0b73407b16ee0503b8"),
 "inviteStatus" : "accepted"
 },
 "title" : "New Chatroom Join Request",
 "message" : "ayu6788 has requested to join the chatroom f gg",
 "notificationType" : 12,
 "createdAt" : ISODate("2021-05-25T00:48:35.030+05:30"),
 "updatedAt" : ISODate("2021-05-26T12:08:10.692+05:30")
 }
 13///
 14///
 
 
 
 */

class NotificationHandler{
    
    static let shared  = NotificationHandler()
    private init(){}
    
    func handelListNotifications(_ m:NotificationModel, onParent:BaseVC? = nil){
        switch m.notificationType {
        case .newFollow:
            CommonFunctions.navigateToUserProfile(m.userId,onParent: onParent)
        case .followersActiveInChatroom:
            let roomId = m.roomId
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .newChatroomInvite:
            let roomId = m.roomId
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .paymentConfirmation:
            printDebug("To Do....")
        case .savedChatroomLive:
            let roomId = m.roomId
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .chatroomCreatedByFollower:
            let roomId = m.roomId
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .celebrityApprovesCommnets:
            let roomId = m.roomId
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .recapAvailabel:
            let roomId = m.roomId
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .adminNotification:
            printDebug("Do nothing....")
        case .eventStarted:
            getEventDetail(m.roomId) { (event) in
                let vc = EventGroupListVC.instantiate(fromAppStoryboard: .Home)
                vc.event = event
                if let v = onParent{
                    AppRouter.pushViewController(v, vc)
                }else{
                    AppRouter.pushFromTabbar(vc)
                }
            }
        case .chatroomStarted:
            let roomId = m.roomId
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .requestToJoin:
            let roomId = m.roomId
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .eventReminder:
            getEventDetail(m.roomId) { (event) in
                let vc = EventGroupListVC.instantiate(fromAppStoryboard: .Home)
                vc.event = event
                if let v = onParent{
                    AppRouter.pushViewController(v, vc)
                }else{
                    AppRouter.pushFromTabbar(vc)
                }
            }
        case .celebrityPush:
            printDebug("To Do....")
        case .requestAccepted:
            AppRouter.goToMyrooms()
        case .newFollowRequest:
            CommonFunctions.navigateToUserProfile(m.userId,onParent: onParent)
        case .newFollowRequestAccept:
            CommonFunctions.navigateToUserProfile(m.userId,onParent: onParent)
        case .engagementPoping:
            let roomId = m.roomId
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .replyOnCommnet:
            let roomId = m.roomId
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        }
    }
    
    
    func handelNavigation(_ pushData:JSON){
        let d = pushData["data"]
        let type = PushTypes(rawValue: d["notificationType"].intValue)
        if let vc = AppRouter.tabBar.navigationController?.topViewController, vc is ChatRoomVC{
            switch type {
            case .followersActiveInChatroom,.savedChatroomLive,.celebrityApprovesCommnets,.chatroomStarted:
                return
            default:
                break
            }
        }
        switch type {
        case .newFollow:
            let id = d["data"]["typeData"]["_id"].stringValue
            CommonFunctions.navigateToUserProfile(id)
        case .followersActiveInChatroom:
            let roomId = d["data"]["typeData"]["_id"].stringValue
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .newChatroomInvite:
            let roomId = d["data"]["typeData"]["_id"].stringValue
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .paymentConfirmation:
            printDebug("To Do....")
        case .savedChatroomLive:
            let roomId = d["data"]["typeData"]["_id"].stringValue
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .chatroomCreatedByFollower:
            let roomId = d["data"]["typeData"]["_id"].stringValue
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .celebrityApprovesCommnets:
            let roomId = d["data"]["typeData"]["_id"].stringValue
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .recapAvailabel:
            let roomId = d["data"]["typeData"]["_id"].stringValue
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .adminNotification:
            printDebug("Do nothing....")
        case .eventStarted:
            let roomId = d["data"]["typeData"]["_id"].stringValue
            getEventDetail(roomId) { (event) in
                let vc = EventGroupListVC.instantiate(fromAppStoryboard: .Home)
                vc.event = event
                AppRouter.pushFromTabbar(vc)
            }
        case .chatroomStarted:
            let roomId = d["data"]["typeData"]["_id"].stringValue
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .requestToJoin:
            let roomId = d["data"]["typeData"]["_id"].stringValue
            getRoomDetail(roomId) { (room) in
                self.moveToDetailScreen(room)
            }
        case .eventReminder:
            getEventDetail(Event(d["data"]["typeData"]).id) { (event) in
                let vc = EventGroupListVC.instantiate(fromAppStoryboard: .Home)
                vc.event = event
                AppRouter.pushFromTabbar(vc)
            }
        case .celebrityPush:
            printDebug("To Do....")
        case .requestAccepted:
            AppRouter.goToMyrooms()
        case .newFollowRequest,.newFollowRequestAccept:
            let id = d["data"]["typeData"]["_id"].stringValue
            CommonFunctions.navigateToUserProfile(id)
        case .replyOnCommnet:
            let roomId = d["data"]["typeData"]["_id"].stringValue
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        case .engagementPoping:
            let roomId = d["data"]["typeData"]["_id"].stringValue
            getRoomDetail(roomId) { (room) in
                self.manageRoom(room)
            }
        default:
            printDebug("Do Nothing....")
        }
    }
    
    private func getEventDetail(_ id:String,completion:@escaping(Event)->()){
        let url = WebService.events.path + "/\(id)"
        NetworkLayer().requestString(from: url, param: [:], method: .GET, header: [:], loader: true) { (data, e) in
            if let e = e{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    if json[ApiKey.code].intValue == 400{
                        CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                        return
                    }
                    completion(Event(json[ApiKey.data]))
                } failure: { (e) in
                    printDebug(e.localizedDescription)
                }
            }
        }
    }
    
    
    
    func goToRoomFromOutside(_ id:String){
        getRoomDetail(id) { (room) in
            self.manageRoom(room)
        }
    }
    
    private func getRoomDetail(_ id:String,completion:@escaping(ChatRoom)->()){
        let url = WebService.getChatRoomDetail.path + "\(id)"
        NetworkLayer().requestString(from: url, param: [:], method: .GET, header: [:], loader: true) { (data, e) in
            if let e = e{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    if json[ApiKey.code].intValue == 400{
                        CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                        return
                    }
                    DispatchQueue.main.async {
                        completion(ChatRoom(json[ApiKey.data]))
                    }
                } failure: { (e) in
                    printDebug(e.localizedDescription)
                }
            }
        }
    }
    
    func manageRoom(_ data:ChatRoom){
        DispatchQueue.main.async {
            if data.roomType == ._public{
                if data.isLive{
                    if data.isFree{
                        guard CommonFunctions.checkForInternet() else { return }
                        let param = ["chatroomId":data._id]
                        SocketIOManager.instance.emit(with: .joinRoom,param )
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                            vc.room = data
                            AppRouter.pushFromTabbar(vc)
                        }
                    }else{
                        if data.paymentStatus == .success{
                            guard CommonFunctions.checkForInternet() else { return }
                            let param = ["chatroomId":data._id]
                            SocketIOManager.instance.emit(with: .joinRoom,param )
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                
                                let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                                vc.room = data
                                AppRouter.pushFromTabbar(vc)
                                
                            }
                        }else if data.paymentStatus == .pending{
                            CommonFunctions.showToastWithMessage("Your Payment is in process. Please try after some time.")
                            return
                        }else{
                            self.presentPopupDetail(data)
                        }
                    }
                }else{
                    self.presentPopupDetail(data)
                }
            }else{
                if data.isLive && data.isCreatedByMe{
                    guard CommonFunctions.checkForInternet() else { return }
                    let param = ["chatroomId":data._id]
                    SocketIOManager.instance.emit(with: .joinRoom,param )
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                        vc.room = data
                        AppRouter.pushFromTabbar(vc)
                    }
                }else if data.isLive && data.requestStatus == .readyToJoin{
                    guard CommonFunctions.checkForInternet() else { return }
                    if data.isFree{
                        let param = ["chatroomId":data._id]
                        SocketIOManager.instance.emit(with: .joinRoom,param )
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                            vc.room = data
                            AppRouter.pushFromTabbar(vc)
                            
                        }
                    }else{
                        let param = ["chatroomId":data._id]
                        SocketIOManager.instance.emit(with: .joinRoom,param )
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                            vc.room = data
                            AppRouter.pushFromTabbar(vc)
                        }
                    }
                }else if data.isConcluded && data.isCreatedByMe{
                    self.viewRecape(data)
                }else{
                    self.presentPopupDetail(data)
                }
            }
        }
    }
    
    private func presentPopupDetail(_ data:ChatRoom){
        if data.isConcluded && ((data.roomType == ._private && data.requestStatus == .readyToJoin) || data.roomType == ._public){
            if data.isFree{
                viewRecape(data)
            }else{
                if data.paymentStatus == .success{
                    viewRecape(data)
                }else{
                    presentSheet(data)
                }
            }
        }else{
            presentSheet(data)
        }
    }
    
    private func viewRecape(_ room:ChatRoom){
        let vc = RecapVC.instantiate(fromAppStoryboard: .Chat)
        vc.room = room
        AppRouter.tabBar.selectedViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentSheet(_ data:ChatRoom){
        let vc = GroupDetailVC.instantiate(fromAppStoryboard: .Events)
        vc.room = data
        vc.delegate = self
        let sheet = SheetViewController(controller: vc, sizes: [.fullscreen])
        vc.showdetail = { [weak self] room in
            sheet.dismiss(animated: true) {
                self?.moveToDetailScreen(room)
            }
        }
        vc.showInviteFriend = { [weak self] room in
            sheet.dismiss(animated: true) {
                //                self?.moveToInvitecreen(room)
            }
        }
        vc.viewRecape = { [weak self] room in
            sheet.dismiss(animated: true) {
                self?.viewRecape(room)
            }
        }
        sheet.gripSize = .zero
        sheet.gripColor = .clear
        sheet.minimumSpaceAbovePullBar = 0
        sheet.cornerRadius = 0
        sheet.contentBackgroundColor = .clear
        sheet.overlayColor = UIColor.black.withAlphaComponent(0.15)
        sheet.pullBarBackgroundColor = .clear
        AppRouter.tabBar.present(sheet, animated: false, completion: nil)
    }
    
    private func moveToDetailScreen(_ room:ChatRoom){
        let vc = RoomDetailVC.instantiate(fromAppStoryboard: .Events)
        vc.roomId = room._id
        vc.isPending = true
        AppRouter.tabBar.selectedViewController?.navigationController?.pushViewController(vc, animated: true)  //pushFromTabbar(vc)
    }
    
    private func presentPopupView(){
        //        let vc = RoomCreatedSuccessVC.instantiate(fromAppStoryboard: .Events)
        //        vc.delegate = self
        //        vc.heading = "Chatroom Saved"
        //        vc.subheading = "You have successfully saved the chat room\nWe will notify once the chatroom is live"
        //        vc.okBtntitle = "OK"
        //        vc.modalTransitionStyle = .crossDissolve
        //        vc.modalPresentationStyle = .overFullScreen
        //        AppRouter.tabBar.present(vc, animated: false, completion: nil)
    }
}


extension NotificationHandler : GroupDetailDelegate {
    func editRoom(_ room: ChatRoom) {}
    
    
    func showSaveRoomPopup() {
        presentPopupView()
    }
    
    func gotoRoom(_ room: ChatRoom) {
        let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
        vc.room = room
        AppRouter.pushFromTabbar(vc)
    }
    
    func showReqDenied() {}
    
    func goForPayment(_ room: ChatRoom) {
        let vc = PaymentVC.instantiate(fromAppStoryboard: .Chat)
        vc.room = room
        AppRouter.pushFromTabbar(vc)
    }
    func goForInviteFriend(_ room: ChatRoom) {
        let vc = InviteUsersVC.instantiate(fromAppStoryboard: .Events)
        vc.isfromDetail = true
        vc.url = room.inviteString
        vc.roomId = room._id
        AppRouter.pushFromTabbar(vc)
    }
}


extension NotificationHandler : SignupSucessDelegate {
    func okTapped() {
        //        AppRouter.goToMyrooms()
    }
}
