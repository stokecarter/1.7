//
//  EventGroupListVM.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import Foundation
import SwiftyJSON

class EventGroupListVM {
    
    enum ChroomType:String{
        case trending
        case following
    }
    
    var notifyUpdate:(()->())?
    var currentpage:Int = 1
    private let web:NetworkLayer!
    private let eventId:String!
    var trendingChatRooms:ChatRoomModel = ChatRoomModel(JSON()){
        didSet{
            if let noti = notifyUpdate { noti()}
        }
    }
    
    var followingChatRooms:ChatRoomModel = ChatRoomModel(JSON()){
        didSet{
            if let noti = notifyUpdate { noti()}
        }
    }
    
    
    
    var type:ChroomType = .trending
    
    init(_ web:NetworkLayer,eventId:String){
        self.web = web
        self.eventId = eventId
    }
    
    private func getAllChatrooms(type:ChroomType) -> JSONDictionary{
        let param:JSONDictionary = ["page":currentpage,
                                    "limit":100,
//                                    "listType":type == .trending ? "trending" : "following",
                                    "eventId":eventId ?? "",
                                    "status":"active"]
        return param
    }
    
    
    func getAllTrendingChatRooms(type:ChroomType,loader:Bool = false){
        let param = getAllChatrooms(type: type)
        web.request(from: WebService.getChatRooms, param: param, method: .GET, header: [:], loader: loader) { [weak self](data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                guard let self = self else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    DispatchQueue.main.async {
                        if type == .trending{
                            self.trendingChatRooms = ChatRoomModel(json[ApiKey.data])
                        }else{
                            self.followingChatRooms = ChatRoomModel(json[ApiKey.data])
                        }
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func groupDetail(_ id:String,completion:@escaping (ChatRoom)->Void){
        let url = WebService.getChatRooms.path + "/\(id)"
        web.requestString(from: url, param: [:], method: .GET, header: [:], loader: true) { (data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    completion(ChatRoom(json[ApiKey.data]))
                } failure: { (e) in
                    printDebug(e.localizedDescription)
                }
            }
        }
    }
}
