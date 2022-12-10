//
//  AdminVM.swift
//  Stoke
//
//  Created by Admin on 27/05/21.
//

import Foundation
import SwiftyJSON


class AdminVM{
    
    let web:NetworkLayer!
    let room:ChatRoom!
    
    var dataSource:[Comment] = []{
        didSet{
            if let r = reload { r()}
        }
    }
    
    var reload:(()->())?
    var updateTitle:(()->())?
    var selectedCommnet:Set<String> = []{
        didSet{
            if let t = updateTitle { t() }
        }
    }
    var selectedUsers:[String]{
        var userId:Set<String> = []
        for i in selectedCommnet{
            if let index = dataSource.firstIndex(where: {$0._id == i}){
                userId.insert(dataSource[index].user.id)
            }
        }
        return Array(userId)
    }
    
    init(_ web:NetworkLayer,room:ChatRoom){
        self.web = web
        self.room = room
        getReportedCommnetList()
    }
    
    func getReportedCommnetList(){
        let param:JSONDictionary = ["chatroomId":room._id,"limit":100,"page":1]
        let url = WebService.reportCommnet.path
        web.requestString(from: url, param: param, method: .GET, header: [:], loader: true) { (data, e) in
            guard let d = data else {
                CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return }
            Parser.shared.getJSONData(data: d) { [weak self](json) in
                DispatchQueue.main.async {
                    self?.dataSource = CommnetsModel(json[ApiKey.data]).data
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    
    func deleteReportedCommnets(_ completion:@escaping()->()){
        let ids = Array(selectedCommnet.map{ $0 })
        let param:JSONDictionary = ["commentIds":ids,"chatroomId":room._id]
        web.request(from: WebService.deleteCommnets, param: param, method: .POST, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ??
            "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                CommonFunctions.showToastWithMessage("Comment removed successfully.", theme: .success)
                completion()
            } failure: { (e) in
                
            }
        }
    }
    
    func deleteReportedUsers(_ completion:@escaping()->()){
        let id  = selectedUsers
        let params:JSONDictionary = ["userIds":id, "chatroomId":room._id]
        web.request(from: WebService.deleteUser, param: params, method: .POST, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ??
            "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                CommonFunctions.showToastWithMessage("User removed successfully.", theme: .success)
                completion()
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
}
