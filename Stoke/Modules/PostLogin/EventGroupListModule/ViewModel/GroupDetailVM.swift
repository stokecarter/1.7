//
//  GroupDetailVM.swift
//  Stoke
//
//  Created by Admin on 24/03/21.
//

import Foundation
import SwiftyJSON

class GroupDetailVM {
    
    private let web:NetworkLayer!
    var roomId:String!
    var notifyChatSave:(()->())?
    var room:ChatRoom? = nil{
        didSet{
            if let re = reload{ re()}
        }
    }
    
    var reload:(()->())?
    var requestDeclined:(()->())?
    
    init(_ web:NetworkLayer, id:String) {
        self.web = web
        self.roomId = id
        hitRoomDetail()
    }
    
    
    func hitRoomDetail(){
        let url = WebService.getChatRooms.path + "/\(roomId ?? "")"
        let param:JSONDictionary = ["chatroomId":roomId ?? ""]
        web.requestString(from: url, param: param, method: .GET, header: [:], loader: false) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    DispatchQueue.main.async {
                        self?.room = ChatRoom(json[ApiKey.data])
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitForUnsaveChatRoom(completion:@escaping (()->())){
        let url = WebService.saveChatRoom.path + "/" + roomId
        web.requestString(from: url, param: [:], method: .DELETE, header: [:], loader: true) { (data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue, theme: .success)
                    DispatchQueue.main.async {
                        completion()
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitForSaveChatRoom(){
        let param:JSONDictionary = ["chatroomId":roomId ?? ""]
        web.request(from: WebService.saveChatRoom, param: param, method: .POST, header: [:], loader: true) { [weak self](data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue, theme: .success)
                    if let noti = self?.notifyChatSave { noti()}
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitJoinrequest(completion:@escaping((String)->())){
        let param:JSONDictionary = ["chatroomId":roomId ?? ""]
        web.request(from: WebService.requestToJoin, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    if json[ApiKey.code] == 420{
                        if let req = self?.requestDeclined { req()}
                    }else{
                        self?.hitRoomDetail()
                        CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func cancelAlreadyJoinedrequest(completion:@escaping (()->())){
        let param:JSONDictionary = ["requestId":room?.requestId ?? "","type": "cancel"]
        web.request(from: WebService.inviteRequest, param: param, method: .PUT, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                    completion()
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func actionOnrequest(_ action:Bool,completion:@escaping(()->())){
        let param:JSONDictionary = ["requestId":room?.requestId ?? "","type":action ? "accept" : "decline"]
        web.request(from: WebService.inviteRequest, param: param, method: .PUT, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                    completion()
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
}
