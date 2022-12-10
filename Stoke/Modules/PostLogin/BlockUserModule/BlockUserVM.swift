//
//  BlockUserVM.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import Foundation
import SwiftyJSON

class BlockUserVM{
    
    private let web:NetworkLayer!
    
    init(_ web:NetworkLayer){
        self.web = web
        getList()
    }
    
    var notify:(()->())?
    
    var data:[User] = []{
        didSet{
            if let n = notify{ n()}
        }
    }
    func getList(){
        let param:JSONDictionary = ["page":1,"limit":100]
        web.request(from: WebService.blockUserList, param: param, method: .GET, header: [:], loader: true) { (data, err) in
            guard let d = data else { CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                DispatchQueue.main.async { [weak self] in
                    self?.data = User.returnUsers(json[ApiKey.data][ApiKey.data])
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    
    func unblockUser(_ id:String,completion:@escaping(()->())){
        let param:JSONDictionary = ["toUserId":id,"type":"active"]
        web.request(from: WebService.blockUser, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            guard let d = data else { CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                printDebug(json)
                completion()
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
}
