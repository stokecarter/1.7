//
//  PaymnetDetailVM.swift
//  Stoke
//
//  Created by Admin on 13/05/21.
//

import Foundation
import SwiftyJSON

class PaymnetDetailVM{
    
    private let web:NetworkLayer!
    private let id:String!
    var data:PaymentModel = PaymentModel(JSON()){
        didSet{
            if let update = update { update() }
        }
    }
    
    var update:(()->())?
    var popToBack:(()->())?
    
    init(_ web:NetworkLayer,paymnetId:String){
        self.web = web
        self.id = paymnetId
        getPaymentDetail()
    }
    
    func getPaymentDetail(){
        let url = WebService.myPayments.path + "/\(id ?? "")"
        web.requestString(from: url, param: [:], method: .GET, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    if  json[ApiKey.code].intValue == 400{
                        CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue,theme: .info)
                        if let  p = self?.popToBack{ p()}
                        return
                    }
                    self?.data = PaymentModel(json["data"])
                    printDebug(json)
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
}
