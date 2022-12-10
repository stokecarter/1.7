//
//  ReplyThreadVM.swift
//  Stoke
//
//  Created by Admin on 20/04/21.
//

import Foundation
import SwiftyJSON

class ReplyThreadVM{
    
    
    private let web:NetworkLayer!
    let commentId:String
    let roomId:String
    var currentPage = 1
    var reload:(()->())?
    var comment:Comment!
    var upDateComnet:((Comment)->())?
    
    var dataSource:[Reply] = []{
        didSet{
            if let  reload = reload { reload() }
        }
    }
    
    init(_ web:NetworkLayer,comment:Comment,roomId:String){
        self.commentId = comment._id
        self.comment = comment
        self.web = web
        self.roomId = roomId
        hitGetReply(self.commentId)
    }
    
    
    
    func hitGetReply(_ commentId:String,loader:Bool = true){
        let param:JSONDictionary = ["page":currentPage,
                                    "limit":"100",
                                    "commentId":commentId]
        web.request(from: WebService.reply, param: param, method: .GET, header: [:], loader: loader) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    guard let self = self else { return }
                    self.dataSource = Reply.returnReply(json[ApiKey.data][ApiKey.data])
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func approveComment(_ id:String,type:Bool,completion:@escaping(()->())){
        let param:JSONDictionary = ["commentId":id,"type":type ? "set" : "remove"]
        web.request(from: WebService.approveByCelebrity, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
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
}


