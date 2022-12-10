//
//  ChatRooomVM.swift
//  Stoke
//
//  Created by Admin on 20/04/21.
//

import Foundation
import SwiftyJSON

enum CommnetType:String{
    case all
    case following
    case my
}

class ChatRoomVM{
    
    
    private let web:NetworkLayer!
    let roomId:String
    var dataSource:CommnetsModel! = CommnetsModel(JSON())
    var trending:CommnetsModel! = CommnetsModel(JSON()){
        didSet{
            if let re = reloadTrending { re()}
        }
    }
    
    var isReplyLoaded = true
    var replyDataSource:[Reply] = []
    var totalReply = 0
    var refreshReplyReactions:((Int)->())?
    var reloadReply:(()->())?
    var upDateComnet:((Comment)->())?
    var exitFromRoom:((String)->())?
    var commnetType:CommnetType = .all
    var currentPage = 1
    var trendingCurrentPage = 1
    var replyCurrentPage = 1
    var reload:((Int?)->())?
    var reloadTrending:(()->())?
    var notifyNewComment:(()->())?
    var popOutUser:((String)->())?
    var scrollToMyCommnet:(()->())?
    var reloadForNewComments:(()->())?
    var reloadToPreviousIndex:((Int)->())?
    init(_ web:NetworkLayer,roomId:String){
        self.roomId = roomId
        self.web = web
//        if !AppNetworkDetector.sharedInstance.isIntenetOk{
//            fetchCommnets { (data) in
//                AppThread.main.async {
//                    self.dataSource = data
//                    if let r = self.reload { r(nil)}
//                }
//            }
//        }else{
            hitJoinEvent()
            startObserving()
            hitGetComment()
//        }
    }
    
    var currentCommnet:Comment? = nil
    
    func startObserving(){
//        NotificationCenter.default.addObserver(self, selector: #selector(checkInternetStatus(_:)), name: .internetUpdate, object: nil)
        
        
        SocketIOManager.instance.listenSocket(.commnet) {[weak self] (data) in
            if let code = JSON(data).arrayValue.first?["statusCode"].int, code == 400{
                if let exit = self?.exitFromRoom { exit(JSON(data).arrayValue.first?["message"].stringValue ?? "") }
            }else if let code = JSON(data).arrayValue.first?["statusCode"].int, code == 401{
                CommonFunctions.showToastWithMessage(JSON(data).arrayValue.first?["message"].stringValue ?? "")
                SocketIOManager.instance.emit(with: .didDisConnect, [:])
                UserModel.main = UserModel()
                AppRouter.checkUserFlow()
            }else if let code = JSON(data).arrayValue.first?["statusCode"].int, code == 422{
                SocketIOManager.instance.emit(with: .didDisConnect, [:])
                if let exit = self?.popOutUser { exit(JSON(data).arrayValue.first?["message"].stringValue ?? "") }
            }else if let code = JSON(data).arrayValue.first?["statusCode"].int, code == 423{
                SocketIOManager.instance.emit(with: .didDisConnect, [:])
                if let exit = self?.popOutUser { exit(JSON(data).arrayValue.first?["message"].stringValue ?? "") }
            }else{
                let c = Comment(JSON(data).arrayValue.first?["data"] ?? JSON())
                if c.chatroomId == self?.roomId{
                    /// This is for replies......
                    if let com = self?.currentCommnet, c._id == com._id{
                        let json = JSON(data).arrayValue.first ?? JSON()
                        let d = Reply(json["data"]["user_reply"].arrayValue.first ?? JSON())
                        if d.commentId == (self?.currentCommnet?._id ?? ""){
                            if let index = self?.replyDataSource.firstIndex(where: { $0._id == d._id}){
                                self?.replyDataSource[index] = d
                            }else{
                                self?.replyDataSource.append(d)
                            }
                            if let  reload = self?.reloadReply { reload() }
                        }
                    }else{
                        /// This is for comments...
                        if let index = self?.dataSource.data.firstIndex(where: { $0._id == c._id}){
                            self?.dataSource.data[index] = c
                            if let re = self?.reload { re(index)}
                        }else if c.user.id == UserModel.main.userId{
                            self?.dataSource.data.append(c)
                            if let re = self?.scrollToMyCommnet { re()}
                        }else{
                            self?.dataSource.data.append(c)
                            if self?.currentPage == 1{
                                if let re = self?.reloadForNewComments { re()}
                            }else{
                                if let newComment = self?.notifyNewComment { newComment() }
                            }
                        }
                    }
                }
            }
        }
        
        SocketIOManager.instance.listenSocket(.approveComment) { [weak self] (data) in
            guard let self = self else { return }
            let comment = Comment(JSON(data).arrayValue.first?[ApiKey.data] ?? JSON())
            if let c = self.currentCommnet, c._id == comment._id{
                self.currentCommnet = comment
                if let reload = self.upDateComnet { reload(comment)}
            }
            if let index = self.dataSource.data.firstIndex(where: { $0._id == comment._id}){
                self.getTrending(self.commnetType,loader: false)
                self.dataSource.data[index] = comment
                if let re = self.reload { re(index)}
            }
        }
        
        SocketIOManager.instance.listenSocket(.commentReaction) { [weak self](data) in
            guard let self = self else { return }
            let comment = Comment(JSON(data).arrayValue.first?[ApiKey.data] ?? JSON())
            if !comment.commentId.isEmpty{
                let json = JSON(data).arrayValue.first ?? JSON()
                let d = Reply(json["data"])
                if let index = self.replyDataSource.firstIndex(where: { $0._id == d._id }){
                    self.replyDataSource[index] = d
                    if let re = self.refreshReplyReactions { re(index)}
                }else{
                    let c = Comment(json[ApiKey.data])
                    if c._id == self.currentCommnet?._id{
                        if let reload = self.upDateComnet { reload(Comment(json[ApiKey.data]))}
                    }
                }
            }else{
                if let c = self.currentCommnet, c._id == comment._id{
                    self.currentCommnet = comment
                    if let reload = self.upDateComnet { reload(comment)}
                }
                if let index = self.dataSource.data.firstIndex(where: { $0._id == comment._id}){
//                    self.getTrending(self.commnetType,loader: false)
                    self.dataSource.data[index] = comment
                    if let re = self.reload { re(index)}
                }
                if let index = self.trending.data.firstIndex(where: {$0._id == comment._id}){
                    self.trending.data[index] = comment
                }
            }
        }
        
        SocketIOManager.instance.listenSocket(.reportedCommnet) { [weak self](data) in
            let json = JSON(data)
            let array = json.arrayValue.first?[ApiKey.data].arrayValue.map { $0.stringValue } ?? []
            for i in array{
                if let index = self?.dataSource.data.firstIndex(where: {$0._id == i}){
                    self?.dataSource.data.remove(at: index)
                }
            }
            self?.getTrending(self?.commnetType ?? .all,loader: false)
            if let re = self?.reload { re(nil)}
        }
    }
    
    func hitJoinEvent(){
        let param = ["chatroomId":roomId]
        SocketIOManager.instance.emit(with: .joinRoom,param)
    }
    
    func reactOnReply(_ id:String,action:Bool,type:ReationType){
        guard CommonFunctions.checkForInternet() else { return }
        if !UserModel.main.isAdmin && !CommonFunctions.isGuestLogin{
            let param:JSONDictionary = ["chatroomId":roomId,"commentId":id,"reactionType":type.rawValue,"type": action ? "set" : "remove"]
            SocketIOManager.instance.emit(with: .commentReaction, param)
        }
    }
    
    func addReply(comment:String,commentId:String){
        guard CommonFunctions.checkForInternet() else { return }
        if !UserModel.main.isAdmin && !CommonFunctions.isGuestLogin{
            let param:JSONDictionary = ["chatroomId":roomId,"comment":comment,"commentId":commentId]
            SocketIOManager.instance.emit(with: .commnet, param)
        }
    }
    
    func stopObserving(){
        SocketIOManager.instance.offTheEvent(.commnet)
        SocketIOManager.instance.offTheEvent(.commentReaction)
    }
    
    func reactOnComment(_ id:String,action:Bool,type:ReationType){
        guard CommonFunctions.checkForInternet() else { return }
        if !UserModel.main.isAdmin && !CommonFunctions.isGuestLogin{
            let param:JSONDictionary = ["chatroomId":roomId,"commentId":id,"reactionType":type.rawValue,"type":action ? "set" : "remove"]
            SocketIOManager.instance.emit(with: .commentReaction, param)
        }
    }
    
    
    
    func addComment(_ commnet:String){
        guard CommonFunctions.checkForInternet() else { return }
        if !UserModel.main.isAdmin && !CommonFunctions.isGuestLogin{
            let param:JSONDictionary = ["chatroomId":roomId,"comment":commnet]
            SocketIOManager.instance.emit(with: .commnet, param)
        }
    }
    
    func getTrending(_ type:CommnetType = .all,loader:Bool = true){
        commnetType = type
        let param:JSONDictionary = ["page":trendingCurrentPage,
                                    "limit":"100",
                                    "chatroomId":roomId,
                                    "type":commnetType.rawValue,
                                    "isTrending":true]
        web.request(from: WebService.comments, param: param, method: .GET, header: [:], loader: loader) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    guard let self = self else { return }
                    if self.trendingCurrentPage == 1{
                        var d = CommnetsModel(json[ApiKey.data])
                        d.data.reverse()
                        self.trending = d
                    }else{
                        let m = CommnetsModel(json[ApiKey.data])
                        self.trending.data.append(contentsOf: m.data.reversed())
                        self.trending.totalCount = m.totalCount
                        self.trending.nextPage = m.nextPage
                        self.trending.page = m.page
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    
    func approveComment(_ id:String,type:Bool,completion:@escaping((Celebrity)->())){
        let param:JSONDictionary = ["commentId":id,"type":type ? "set" : "remove"]
        web.request(from: WebService.approveByCelebrity, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    let c = Celebrity(json[ApiKey.data]["celebrity"])
                    DispatchQueue.main.async {
                        completion(c)
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitSaveComment(_ id:String,action:Bool,completion:@escaping(()->())){
        guard CommonFunctions.checkForInternet() else { return }
        let param:JSONDictionary = ["commentId":id,"type":action ? "save" : "unsave"]
        web.request(from: WebService.saveCommnets, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    DispatchQueue.main.async {
                        CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .success)
                        completion()
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitReportComment(_ id:String,completion:@escaping(()->())){
        guard CommonFunctions.checkForInternet() else { return }
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
    
    func hitGetComment(){
        let param:JSONDictionary = ["page":currentPage,
                                    "limit": "20",
                                    "chatroomId":roomId,
                                    "type":"all"]
        web.request(from: WebService.comments, param: param, method: .GET, header: [:], loader: true) { (data, err) in
            if let e = err{
                self.dataSource.isLoaded = true
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else {
                    self.dataSource.isLoaded = true
                    return
                }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    guard let self = self else { return }
                    if self.currentPage == 1{
                        self.dataSource = CommnetsModel(json[ApiKey.data])
                        self.dataSource.isLoaded = true
                        if let r = self.reload { r(nil)}
                    }else{
                        var m = CommnetsModel(json[ApiKey.data])
                        var index = self.dataSource.data.count - 1
                        m.data.append(contentsOf: self.dataSource.data)
                        index = m.data.count - self.dataSource.data.count - 1
                        self.dataSource = m
                        self.dataSource.totalCount = m.totalCount
                        self.dataSource.nextPage = m.nextPage
                        self.dataSource.page = m.page
                        self.dataSource.isLoaded = true
                        if let r = self.reloadToPreviousIndex { r((index > 0 && index < self.dataSource.data.count) ? index : 0)}
                    }
//                    self.updateLiveCommnets(roomId: self.roomId, dataModel: self.dataSource) { (data) in
//                        printDebug(data)
//                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitGetReply(_ commentId:String,loader:Bool = true){
        let param:JSONDictionary = ["page":replyCurrentPage,
                                    "limit":"20",
                                    "commentId":commentId]
        web.request(from: WebService.reply, param: param, method: .GET, header: [:], loader: loader) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
                self.isReplyLoaded = true
            }else{
                guard let d = data else {
                    self.isReplyLoaded = true
                    return
                }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    guard let self = self else { return }
                    self.isReplyLoaded = true
                    if self.replyCurrentPage == 1{
                        self.replyDataSource = Reply.returnReply(json[ApiKey.data][ApiKey.data]).reversed()
                        self.totalReply = json[ApiKey.data]["totalCount"].intValue
                        if let r = self.reloadReply { r()}
                    }else{
                        var t = Array(Reply.returnReply(json[ApiKey.data][ApiKey.data]).reversed())
                        t.append(contentsOf: self.replyDataSource)
                        self.replyDataSource = t
                        self.totalReply = json[ApiKey.data]["totalCount"].intValue
                        if let r = self.reloadReply { r()}
                    }
                    self.updateReplies(comment: self.currentCommnet, dataModel: self.replyDataSource) { (data) in
                        printDebug(data)
                    }
                } failure: { (e) in
                    self.isReplyLoaded = true
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }    
}


extension ChatRoomVM {
    
    func updateLiveCommnets( roomId:String,dataModel:CommnetsModel,_ completion:@escaping(CommnetsModel?)->()){
        let realm = RealmController.shared.realm
        var room = LiveRoomDBM()
        if let conversation = realm.object(ofType: LiveRoomDBM.self, forPrimaryKey: roomId){
            room = conversation
        }else {
            room._id = roomId
            RealmController.shared.create(room)
            
        }
        try! realm.write {
            for c in dataModel.data{
                let v = CommentDBM(from: c)
                if CommentDBM.commentExists(v._id){
                    v.update()
                }else{
                    room.comments.append(v)
                }
            }
        }
        fetchCommnets(completion)
    }
    
    func fetchCommnets(_ completion:@escaping(CommnetsModel?)->()){
        RealmController.shared.fetchObject(LiveRoomDBM.self, primaryKey: roomId) { (data) in
            if let r = data{
                let d = CommnetsModel(withDB: r)
                completion(d)
            }
        }
    }
    
    
    func updateReplies( comment:Comment?,dataModel:[Reply],_ completion:@escaping([Reply])->()){
//        guard let comment = comment else { return }
//        let realm = RealmController.shared.realm
//        var room = ReplyThreadDBM()
//        if let conversation = realm.object(ofType: ReplyThreadDBM.self, forPrimaryKey: comment._id){
//            room = conversation
//        }else {
//            room.commnetId = comment._id
//            room.comment = CommentDBM(from: comment)
//            RealmController.shared.create(room)
//        }
//        try! realm.write {
//            for c in dataModel{
//                let v = ReplyDBM(from: c)
//                if v.replyExists(v._id){
//                    v.update(v._id)
//                }else{
//                    room.user_reply.append(v)
//                }
//            }
//        }
//        fetchReplies(comment:comment,completion)
    }
    
    func fetchReplies(comment:Comment,_ completion:@escaping([Reply])->()){
//        RealmController.shared.fetchObject(ReplyThreadDBM.self, primaryKey: comment._id) { (data) in
//            if let r = data{
//                var replies = [Reply]()
//                for i in r.user_reply{
//                    replies.append(Reply(withDB: i))
//                }
//                completion(replies)
//            }
//        }
    }
    
}


extension ChatRoomVM {
    
    @objc func checkInternetStatus(_ sender:NSNotification){
//        if let dict =  sender.object as? [String:Bool]{
//            if let status = dict["status"]{
//                if status{
//                    currentPage = 1
//                    trendingCurrentPage = 1
//                    hitGetComment()
//                    getTrending()
//                }else{
//                    fetchCommnets { (data) in
//                        AppThread.main.async {
//                            self.dataSource = data
//                            if let r = self.reload { r(nil)}
//                        }
//                    }
//                }
//            }
//        }
    }
}
