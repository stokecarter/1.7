//
//  MyPaymnetsVM.swift
//  Stoke
//
//  Created by Admin on 12/05/21.
//

import Foundation
import SwiftyJSON


struct PaymentModel{
    let room:ChatRoom
    var transactionId:String
    var _id:String
    var paymentStatus:PaymentStatus
    var createdAt:Double
    var amount:Double
    
    init(_ json:JSON) {
        room = ChatRoom(json["chatroom"])
        transactionId = json["transactionId"].stringValue
        _id = json["_id"].stringValue
        paymentStatus = PaymentStatus(rawValue: json["paymentStatus"].stringValue) ?? .success
        createdAt = json["createdAt"].doubleValue
        amount = json["amount"].doubleValue
    }
    
    var createDate:Date{
        return Date(timeIntervalSince1970: createdAt/1000)
    }
    
    static func returnAllPayments(_ json:JSON) -> [PaymentModel]{
        return json[ApiKey.data].arrayValue.map { PaymentModel($0)}
    }
}

class MyPaymnetsVM{
    
    private let web:NetworkLayer!
    var maxPrice:Double = 200 {
        didSet{
            printDebug(maxPrice)
        }
    }
    var minPrice:Double = 0
    var fromDate:Date?
    var toDate:Date?
    
    var dataSource:[PaymentModel] = []{
        didSet{
            DispatchQueue.main.async { [weak self] in
                if let r = self?.reload { r()}
            }
        }
    }
    
    var reload:(()->())?
    
    var getFromdate:Double{
        if let d = fromDate{
            return d.startOfDay.timeIntervalSince1970*1000
        }else{
            return 0
        }
    }
    
    var getToDate:Double{
        if let d = toDate{
            return d.endOfDay.timeIntervalSince1970*1000
        }else{
            return 0
        }
    }
    
    
    var search:String = ""{
        didSet{
            hitPaymnetList()
        }
    }
    
    init(_ web:NetworkLayer){
        self.web = web
        hitPaymnetList()
        
    }
    
    func hitPaymnetList(){
        var param:JSONDictionary = [:]
        if getFromdate > 0 && getToDate > 0{
            param = ["limit":100,
                                        "search":search,
                                        "minPrice":minPrice,
                                        "maxPrice":maxPrice,
                                        "fromTimestamp":getFromdate,
                                        "toTimestamp":getToDate]
        }else{
            param = ["limit":100,
                                        "search":search,
                                        "minPrice":minPrice,
                                        "maxPrice":maxPrice]
        }
        web.request(from: WebService.myPayments, param: param, method: .GET, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    self.dataSource = PaymentModel.returnAllPayments(json[ApiKey.data])
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
}
