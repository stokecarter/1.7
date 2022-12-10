//
//  MyRoomVM.swift
//  Stoke
//
//  Created by Admin on 12/04/21.
//

import Foundation

class MyRoomVM {
    
    private var web:NetworkLayer!
    
    var savedRooms:ChatRoomModel? = nil{
        didSet{
            if let not = notify { not()}
        }
    }
    
    var createdRooms:ChatRoomModel? = nil{
        didSet{
            if let not = notify { not()}
        }
    }
    
    var notify:(()->())?
    
    init(_ web:NetworkLayer){
        self.web = web
    }
    
    
    func getSavedRooms(_ loader:Bool = true){
        let param:JSONDictionary = ["page":1,"limit":100]
        web.request(from: WebService.saveChatRoom, param: param, method: .GET, header: [:], loader: loader) { [weak self](data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    let m = ChatRoomModel(json[ApiKey.data])
                    self?.savedRooms = m
                    self?.updatehSavedRooms(rooms: m.chatRooms)
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    
    func getCreatedRooms(_ loader:Bool = true){
        let param:JSONDictionary = ["page":1,"limit":100,"userId":UserModel.main.userId]
        web.request(from: WebService.getChatRooms, param: param, method: .GET, header: [:], loader: loader) { [weak self](data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    let m = ChatRoomModel(json[ApiKey.data])
                    self?.createdRooms = m
                    self?.updatehCreatedRooms(rooms: m.chatRooms)
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func fetchSavedRooms(_ completion:@escaping(ChatRoomModel?)->()){
        RealmController.shared.fetchObject(SavedChatrooms.self, primaryKey: "Saved") { (data) in
            if let r = data{
                let d = ChatRoomModel(withSavedChatroomsDb: r)
                completion(d)
            }
        }
    }
    
    func fetchCreatedRooms(_ completion:@escaping(ChatRoomModel?)->()){
        RealmController.shared.fetchObject(CreatedChatrooms.self, primaryKey: "Created") { (data) in
            if let r = data{
                let d = ChatRoomModel(withCreatedChatroomsDb: r)
                completion(d)
            }
        }
    }
    
    
    func updatehCreatedRooms( rooms:[ChatRoom]){
        let realm = RealmController.shared.realm
        var room = CreatedChatrooms()
        if let conversation = realm.object(ofType: CreatedChatrooms.self, forPrimaryKey: "Created"){
            room = conversation
        }else {
            RealmController.shared.create(room)
        }
        try! realm.write {
            for r in rooms{
                let v = ChatRoomDBM(from: r)
                if ChatRoomDBM.roomExists(v._id){
                    v.update()
                }else{
                    switch v.priority{
                    case 1:
                        room.liveRoom.append(v)
                    case 2:
                        room.upcoming.append(v)
                    default:
                        room.ended.append(v)
                    }
                }
            }
        }
    }
    
    func updatehSavedRooms( rooms:[ChatRoom]){
        let realm = RealmController.shared.realm
        var room = SavedChatrooms()
        if let conversation = realm.object(ofType: SavedChatrooms.self, forPrimaryKey: "Saved"){
            room = conversation
        }else {
            RealmController.shared.create(room)
        }
        try! realm.write {
            for r in rooms{
                let v = ChatRoomDBM(from: r)
                if ChatRoomDBM.roomExists(v._id){
                    v.update()
                }else{
                    switch v.priority{
                    case 1:
                        room.liveRoom.append(v)
                    case 2:
                        room.upcoming.append(v)
                    default:
                        room.ended.append(v)
                    }
                }
            }
        }
//        fetchCreatedRooms { (model) in
//            if let m = model{
//                var idsToDelte:[String] = []
//                let live = m.liveRoom.map { $0._id }
//                let upcoming = m.upcoming.map { $0._id }
//                let ended = m.ended.map { $0._id }
//                for i in 0..<rooms.count{
//                    if !live.contains(where: {$0 == rooms[i]._id}){
//                        if let index = room.liveRoom.firstIndex(where: {$0._id == rooms[i]._id}){
//                            RealmController.shared.delete(room.liveRoom[index])
//                        }
//                    }
//                }
//            }
//        }
    }
    
    func fetchOfflineData(){
        fetchSavedRooms { [weak self](rooms) in
            AppThread.main.async {
                self?.savedRooms = rooms
            }
        }
        fetchCreatedRooms { [weak self](rooms) in
            AppThread.main.async {
                self?.createdRooms = rooms
            }
        }

    }
}
