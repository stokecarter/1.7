//
//  RecapVM.swift
//  Stoke
//
//  Created by Admin on 26/04/21.
//

import Foundation
import SwiftyJSON

class RecapVM{
    
    private let web:NetworkLayer!
    let roomId:String!
    var currentPage = 1
    var reloadTrending:(()->())?
    var type:CommnetType = .all{
        didSet{
            if !AppNetworkDetector.sharedInstance.isIntenetOk{
                fetchCommnets(type: type) { (data) in
                    AppThread.main.async {
                        self.recape = data
                    }
                }
            }else{
                getRecape()
            }
        }
    }
    
    init(_ web:NetworkLayer,roomId:String){
        self.roomId = roomId
        self.web = web
        if !AppNetworkDetector.sharedInstance.isIntenetOk{
            fetchCommnets(type: type) { (data) in
                AppThread.main.async {
                    self.recape = data
                }
            }
        }else{
            getRecape()
        }
        
    }
    
    var recape:CommnetsModel! = CommnetsModel(JSON()){
        didSet{
            if let re = reloadTrending { re()}
        }
    }
    
    func getRecape(){
        let param:JSONDictionary = ["page":currentPage,
                                    "limit":"100",
                                    "chatroomId":roomId ?? "",
                                    "type":type.rawValue,
                                    "isTrending":true]
        web.request(from: WebService.comments, param: param, method: .GET, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    guard let self = self else { return }
                    if self.currentPage == 1{
                        self.recape = CommnetsModel(recap:json[ApiKey.data])
                    }else{
                        let m = CommnetsModel(recap:json[ApiKey.data])
                        self.recape.data.append(contentsOf: m.data)
                        self.recape.totalCount = m.totalCount
                        self.recape.nextPage = m.nextPage
                        self.recape.page = m.page
                    }
                    self.updateRecapCommnets(roomId: self.roomId ?? "", type: self.type, dataModel: self.recape) { (data) in
                        printDebug(data)
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitSaveComment(_ id:String,action:Bool,completion:@escaping(()->())){
        let param:JSONDictionary = ["commentId":id,"type":action ? "save" : "unsave"]
        web.request(from: WebService.saveCommnets, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            if let e = err{
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
    
    func hitReportComment(_ id:String,completion:@escaping(()->())){
        let param:JSONDictionary = ["commentId":id]
        web.request(from: WebService.reportCommnet, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            if let e = err{
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
}


extension RecapVM {
    
    func updateRecapCommnets( roomId:String,type:CommnetType,dataModel:CommnetsModel,_ completion:@escaping(CommnetsModel?)->()){
        let realm = RealmController.shared.realm
        var room = RecapDBM()
        if let conversation = realm.object(ofType: RecapDBM.self, forPrimaryKey: roomId){
            room = conversation
        }else {
            room._id = roomId
            RealmController.shared.create(room)
        }
        try! realm.write {
            for c in dataModel.data{
                switch type {
                case .all:
                    let v = AllRecapCommentDBM(from: c)
                    if AllRecapCommentDBM.commentExists(v._id){
                        v.update()
                    }else{
                        room.allComments.append(v)
                    }
                case .following:
                    let v = FollowingRecapCommentDBM(from: c)
                    if FollowingRecapCommentDBM.commentExists(v._id){
                        v.update()
                    }else{
                        room.followingCommnets.append(v)
                    }
                case .my:
                    let v = MyRecapCommentDBM(from: c)
                    if MyRecapCommentDBM.commentExists(v._id){
                        v.update()
                    }else{
                        room.myCommnets.append(v)
                    }
                }
            }
        }
    }
    
    func fetchCommnets(type:CommnetType,_ completion:@escaping(CommnetsModel?)->()){
        RealmController.shared.fetchObject(RecapDBM.self, primaryKey: roomId ?? "") { (data) in
            if let r = data{
                let d = CommnetsModel(recap: r, type: self.type)
                completion(d)
            }
        }
    }
}
