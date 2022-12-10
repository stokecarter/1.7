//
//  NotificationListVM.swift
//  Stoke
//
//  Created by Admin on 21/05/21.
//

import Foundation
import SwiftyJSON

class NotificationListVM{
    
    private let web:NetworkLayer!
    var currentPage = 1
    var isLoaded = true
    var model:NotificationList = NotificationList(JSON()){
        didSet{
            if let r = reloadData{ r()}
        }
    }
    var adminModel:AdminNotificationList = AdminNotificationList(JSON()){
        didSet{
            if let r = reloadData{ r()}
        }
    }
    
    var reloadData:(()->())?
    init(_ web:NetworkLayer){
        self.web = web
        if !AppNetworkDetector.sharedInstance.isIntenetOk{
            fetchNotifications { (data) in
                AppThread.main.async {
                    self.model = data
                }
            }
        }else{
            if UserModel.main.isAdmin{
                getAdminNotification()
            }else{
                getNotificationsList()
            }
        }
    }
    
    func getAdminNotification(_ loader:Bool = false){
        
        let param:JSONDictionary = ["page":currentPage,"limit":10]
        web.request(from: WebService.adminNotification, param: param, method: .GET, header: [:], loader: loader) { (data, e) in
            self.isLoaded = true
            guard let d = data else {
                CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { [weak self](json) in
                guard let self = self else { return }
                AppRouter.tabBar.isNewNotification = self.model.unreadCount > 0 ? self.model.unreadCount : nil
                if self.currentPage == 1{
                    self.adminModel = AdminNotificationList(json[ApiKey.data])
                }else{
                    self.adminModel.data.append(contentsOf: AdminNotificationList(json[ApiKey.data]).data)
                }
//                self.updateNotifications(dataModel: self.AdminNotificationList)
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    
    func getNotificationsList(_ loader:Bool = false){
        if UserModel.main.isAdmin{
            getAdminNotification(loader)
            return
        }
        let param:JSONDictionary = ["page":currentPage,"limit":10]
        web.request(from: WebService.notifications, param: param, method: .GET, header: [:], loader: loader) { (data, e) in
            self.isLoaded = true
            guard let d = data else {
                CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { [weak self](json) in
                guard let self = self else { return }
                AppRouter.tabBar.isNewNotification = self.model.unreadCount > 0 ? self.model.unreadCount : nil
                if self.currentPage == 1{
                    self.model = NotificationList(json[ApiKey.data])
                }else{
                    self.model.data.append(contentsOf: NotificationList(json[ApiKey.data]).data)
                }
                self.updateNotifications(dataModel: self.model)
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    
    func readNotification(_ id:[String],completion:@escaping()->()){
        let param:JSONDictionary = ["notificationId":id,"type":"read"]
        web.request(from: WebService.notifications, param: param, method: .PUT, header: [:], loader: false) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { json in
                let unreadCount = json[ApiKey.data]["unreadCount"].intValue
                AppRouter.tabBar.isNewNotification = unreadCount > 0 ? unreadCount : nil
                completion()
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    
    func deleteNotification(_ id:String,completion:@escaping()->()){
        let param:JSONDictionary = ["notificationId":id,"type":"delete"]
        web.request(from: WebService.notifications, param: param, method: .PUT, header: [:], loader: false) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { _ in
                completion()
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    
    func actionOnInvitation(_ action:Bool,id:String,completion:@escaping(()->())){
        let param:JSONDictionary = ["requestId":id,"type":action ? "accept" : "decline"]
        web.request(from: WebService.inviteRequest, param: param, method: .PUT, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                    self?.getNotificationsList()
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    
    func actiononRequest(id:String,flag:Bool,completion:@escaping (Bool)->()){
        let param:JSONDictionary = ["requestId":id,
                                    "type":flag ? "accept" : "decline"]
        web.request(from: WebService.inviteRequest, param: param, method: .PUT, header: [:], loader: false) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                    self?.getNotificationsList()
                    completion(flag)
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func followUser(_ id:String,completion:@escaping(()->())){
        let param:JSONDictionary = ["toUserId":id,"type":"follow"]
        web.request(from: WebService.followUnfollow, param: param, method: .POST, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                completion()
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    
    func unfollowUser(_ id:String,completion:@escaping(()->())){
        let param:JSONDictionary = ["toUserId":id,"type":"unfollow"]
        web.request(from: WebService.followUnfollow, param: param, method: .POST, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                completion()
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    
}



extension NotificationListVM{
    
    func updateNotifications(dataModel:NotificationList){
        let realm = RealmController.shared.realm
        var room = NotificationListDBM()
        if let conversation = realm.object(ofType: NotificationListDBM.self, forPrimaryKey: UserModel.main.userId){
            room = conversation
        }else {
            room.unreadCount = dataModel.unreadCount
            RealmController.shared.create(room)
        }
        try! realm.write {
            for c in dataModel.data{
                let v = NotificationDBM(c)
                if NotificationDBM.notificationExists(v._id){
                    v.update()
                }else{
                    room.list.append(v)
                }
            }
        }
    }
    
    func fetchNotifications(_ completion:@escaping(NotificationList)->()){
        RealmController.shared.fetchObject(NotificationListDBM.self, primaryKey: UserModel.main.userId) { (data) in
            if let r = data{
                let m = NotificationList(withDb: r)
                completion(m)
            }
        }
    }
    
    func fetchOfflineData(){
        fetchNotifications { (data) in
            AppThread.main.async {
                self.model = data
            }
        }
    }
    
    func getRoomDetail(_ id:String,completion:@escaping(ChatRoom)->()){
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
}
