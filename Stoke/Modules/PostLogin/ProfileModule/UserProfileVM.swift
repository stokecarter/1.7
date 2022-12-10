//
//  UserProfileVM.swift
//  Stoke
//
//  Created by Admin on 17/05/21.
//

import Foundation
import SwiftyJSON

enum ProfileSections{
    case savedCommnets
    case savedTaggs
    case savedRooms
}


class UserProfileVM{
    
    
    
    var currentSection:ProfileSections = .savedCommnets
    private let web:NetworkLayer!
    private var userId = UserModel.main.userId
    var notify:(()->())?
    var popToBack:(()->())?
    var model:UserProfileModel! = UserProfileModel(JSON()){
        didSet{
            if let notify = notify { notify()}
        }
    }
    
    var savedCommnets:[Comment] = []{
        didSet{
            if let notify = notify { notify()}
        }
    }
    
    var savedTags:[Tag] = []{
        didSet{
            if let notify = notify { notify()}
        }
    }
    
    var savedRooms:[ChatRoom] = []{
        didSet{
            if let notify = notify { notify()}
        }
    }
    
    init(_ web:NetworkLayer,userId:String = UserModel.main.userId,isPrivate:Bool = false) {
        self.web = web
        self.userId = userId
        if userId == UserModel.main.userId{
            if !AppNetworkDetector.sharedInstance.isIntenetOk{
                fetchOfflineData()
            }else{
                getProfile()
                getSavedCommnets()
                getSavedTaggs()
            }
        }else{
            getProfile()
            getSavedCommnets()
            getSavedTaggs()
            getSavedRooms()
        }
    }
    
    func getProfile(){
        let param:JSONDictionary = ["toUserId":userId]
        web.request(from: WebService.userProfile,param: param, method: .GET, header: [:], loader: false) { (data, err) in
            guard let d = data else { CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { [weak self] (json) in
                if json[ApiKey.code].intValue == 400{
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                    if let pop = self?.popToBack { pop()}
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.model = UserProfileModel(json[ApiKey.data])
                    if self.userId == UserModel.main.userId{
                        self.updateNotifications(dataModel: self.model)
                        AppUserDefaults.save(value: self.model.profilePicture, forKey: .profilePicture)
                    }
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
            }
            
        }
    }
    
    func getSavedCommnets(){
        let param:JSONDictionary = ["toUserId":userId,"page":1,"limit":100]
        web.request(from: WebService.saveCommnets,param: param, method: .GET, header: [:], loader: false) { (data, err) in
            guard let d = data else { CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { [weak self](json) in
                DispatchQueue.main.async {
                    self?.savedCommnets = Comment.returnComments(json[ApiKey.data][ApiKey.data])
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
            }
            
        }
    }
    
    func getSavedTaggs(){
        let param:JSONDictionary = ["userId":userId,"page":1,"limit":100]
        web.request(from: WebService.tags, param: param, method: .GET, header: [:], loader: false) { (data, err) in
            guard let d = data else { CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { [weak self](json) in
                DispatchQueue.main.async {
                    self?.savedTags = Tag.returnTag(json[ApiKey.data][ApiKey.data])
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
            }
        }
    }
    
    func getSavedRooms(_ page:Int = 1){
        let param:JSONDictionary = ["userId":userId,"page":page,"limit":100]
        web.request(from: WebService.saveCreadedRooms, param: param, method: .GET, header: [:], loader: false) { [weak self](data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    DispatchQueue.main.async {
                        self?.savedRooms = ChatRoom.returnArray(json[ApiKey.data][ApiKey.data])
                    }
                    printDebug(json)
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
                
            }
        }
    }
    
    func followUser(_ action:Bool,completion:@escaping(()->())){
        let param:JSONDictionary = ["toUserId":userId,"type":action ? "follow" : "unfollow"]
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
    
    func blockUser(completion:@escaping(()->())){
        let param:JSONDictionary = ["toUserId":userId,"type":"block"]
        web.request(from: WebService.blockUser, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            guard let d = data else { CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                completion()
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }

        }
    }
    
    func reportUser(completion:@escaping(()->())){
        let param:JSONDictionary = ["toUserId":userId]
        web.request(from: WebService.report, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            guard let d = data else { CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                completion()
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }

        }
    }
    
    func unsavedCommnet(_ id:String){
        let param:JSONDictionary = ["commentId":id,"type":"unsave"]
        web.request(from: WebService.saveCommnets, param: param, method: .POST, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { [weak self](json) in
                CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue, theme: .success)
                self?.getSavedCommnets()
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    

}

extension UserProfileVM {
    
    func updateNotifications(dataModel:UserProfileModel){
        let realm = RealmController.shared.realm
        var room = UserProfileDBM(dataModel)
        if let conversation = realm.object(ofType: UserProfileDBM.self, forPrimaryKey: UserModel.main.userId){
            room = conversation
        }else {
            RealmController.shared.create(room)
        }
        room.update()
    }
    
    func fetchNotifications(_ completion:@escaping(UserProfileModel)->()){
        RealmController.shared.fetchObject(UserProfileDBM.self, primaryKey: UserModel.main.userId) { (data) in
            if let r = data{
                let m = UserProfileModel(withDB: r)
                
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
}
