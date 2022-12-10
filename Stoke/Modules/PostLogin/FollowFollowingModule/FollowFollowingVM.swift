//
//  FollowFollowingVM.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import Foundation
import SwiftyJSON

enum FollowType:String{
    case follow
    case following
}

struct FollowFollowingModel {
    var totalCount:Int
    var data:[User] = []
    init(_ json:JSON){
        totalCount = json["totalCount"].intValue
        data = User.returnUsers(json[ApiKey.data])
    }
}

class FollowFollowingVM{
    
    var type:FollowType = .follow
    let userId:String
    private let web:NetworkLayer!
    
    var follow:FollowFollowingModel = FollowFollowingModel(JSON()){
        didSet{
            if let t = refresh { t()}
        }
    }
    var following:FollowFollowingModel = FollowFollowingModel(JSON()){
        didSet{
            if let t = refresh { t()}
        }
    }
    
    var search:String = ""{
        didSet{
            if self.type == .follow{
                hitFollowList()
            }else{
                hitFollowerList()
            }
        }
    }
    
    var refresh:(()->())?
    
    init(_ web:NetworkLayer, userId:String = UserModel.main.userId){
        self.web = web
        self.userId = userId
        hitFollowList()
        hitFollowerList()
    }
    
    func hitFollowList(_ loader:Bool = true){
        let param:JSONDictionary = ["type":"follow","page":1,"limit":1000,"search":search,"toUserId":userId]
        web.request(from: WebService.followFollowing, param: param, method: .GET, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                DispatchQueue.main.async {
                    self.follow = FollowFollowingModel(json[ApiKey.data])
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }

        }
    }
    
    func hitFollowerList(_ loader:Bool = true){
        let param:JSONDictionary = ["type":"following","page":1,"limit":1000,"search":search,"toUserId":userId]
        web.request(from: WebService.followFollowing, param: param, method: .GET, header: [:], loader: loader) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                DispatchQueue.main.async {
                    self.following = FollowFollowingModel(json[ApiKey.data])
                }
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
                DispatchQueue.main.async {
                    completion()
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
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
                DispatchQueue.main.async {
                    completion()
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
}
