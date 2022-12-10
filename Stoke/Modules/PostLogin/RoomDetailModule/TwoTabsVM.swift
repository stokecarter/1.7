//
//  TwoTabsVM.swift
//  Stoke
//
//  Created by Admin on 14/04/21.
//

import Foundation
import SwiftyJSON

enum FollowAction:String{
    case follow
    case unfollow
}

enum ListType:String{
    case all
    case following
    case pending
}

class TwoTabsVM{
    
    private let web:NetworkLayer
    private let room:ChatRoom
    
    var notify:(()->())?
    
    var allusers:UserListModel = UserListModel(JSON()){
        didSet{
            if let inform = notify { inform() }
        }
    }
    
    var following:UserListModel = UserListModel(JSON()){
        didSet{
            if let inform = notify { inform() }
        }
    }
    
    
    init(_ web:NetworkLayer,room:ChatRoom){
        self.web = web
        self.room = room
        hitAllUserList(search: "", type: .following)
        hitAllUserList()
    }
    
    func hitAllUserList(search:String = "",type:ListType = .all){
        let param:JSONDictionary = ["page":1,
                                    "limit":100,
                                    "search":search,
                                    "chatroomId":room._id,
                                    "type":type.rawValue]
        web.request(from: WebService.chatroomUsers, param: param, method: .GET, header: [:], loader: false) { [weak self](data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    if type == .all{
                        self?.allusers = UserListModel(json[ApiKey.data])
                    }else{
                        self?.following = UserListModel(json[ApiKey.data])
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func actionOnFollowUnfollow(useID:String,action:FollowAction,completion: @escaping(FollowAction)->()){
        let param:JSONDictionary = ["toUserId":useID,"type":action.rawValue]
        web.request(from: WebService.followUnfollow, param: param, method: .POST, header: [:], loader: false) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    DispatchQueue.main.async {
                        completion(action)
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
}
