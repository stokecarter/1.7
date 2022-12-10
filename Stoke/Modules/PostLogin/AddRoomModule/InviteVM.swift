//
//  InviteVM.swift
//  Stoke
//
//  Created by Admin on 15/04/21.
//

import Foundation
import SwiftyJSON

class InviteVM{
    
    let web:NetworkLayer!
    var searchQuery:String = ""{
        didSet{
            if type == .follow{
                searchFollowerUser()
            }else{
                searchFollowingUser()
            }
        }
    }
    var followerUserList = UserListModel(JSON()){
        didSet{
            if let tap = notifyTOReload { tap()}
        }
    }
    var followingUserList = UserListModel(JSON()){
        didSet{
            if let tap = notifyTOReload { tap()}
        }
    }
    var roomId = ""
    var notifyTOReload:(()->())?
    var inviteIds:[String] = []
    var isInviteAll = false
    var type:FollowType = .follow
    
    init(_ web:NetworkLayer,eventId:String?){
        self.web = web
        self.roomId = eventId ?? ""
        searchFollowerUser()
        searchFollowingUser()
    }
    
    private func searchFollowerUser(){
        var param:JSONDictionary = [:]
        param["search"] = searchQuery
        param["page"] = 1
        param["limit"] = 100
        param["type"] = "follower"
        param["chatroomId"] = roomId
        web.request(from: WebService.chatroomInviteList, param: param, method: .GET, header: [:], loader: true) { [weak self](data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        self?.followerUserList = UserListModel(json[ApiKey.data])
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    private func searchFollowingUser(){
        var param:JSONDictionary = [:]
        param["search"] = searchQuery
        param["page"] = 1
        param["limit"] = 100
        param["type"] = "following"
        param["chatroomId"] = roomId
        web.request(from: WebService.chatroomInviteList, param: param, method: .GET, header: [:], loader: true) { [weak self](data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        self?.followingUserList = UserListModel(json[ApiKey.data])
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    func inviteusers(completion:@escaping(()->())){
        let param:JSONDictionary = ["inviteIds":inviteIds,
                                    "chatroomId":roomId,
                                    "isInviteAll":isInviteAll,
                                    "type":type == .follow ? "follower" : "following"]
        web.request(from: WebService.inviteUserChatRoom, param: param, method: .POST, header: [:], loader: true) { (data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        CommonFunctions.showToastWithMessage(json["message"].stringValue,theme: .success)
                        DispatchQueue.main.async {
                            completion()
                        }
                    } failure: { (e) in
                        DispatchQueue.main.async {
                            completion()
                        }
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
}
