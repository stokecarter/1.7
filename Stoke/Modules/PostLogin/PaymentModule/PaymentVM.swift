//
//  PaymentVM.swift
//  Stoke
//
//  Created by Admin on 07/05/21.
//

import Foundation
import SwiftyJSON
import Stripe

class PaymentVM{
    
    var amount = 0.0
    var cardNo = ""
    var cvv = ""
    var expMonth:UInt = 0
    var expYear:UInt = 0
    var cardHolderName = ""
    
    var cardModel:CardDetails? = nil{
        didSet{
            if let c = cardModel{
                cardNo = c.cardNo
                cvv = c.cvv
                expMonth = c.expMonth
                expYear = c.expYear
                cardHolderName = c.cardholderName
            }
        }
    }
    
    var cards:[StripCards] = []{
        didSet{
            if let reload = reloadData { reload() }
        }
    }
    var reloadData:(()->())?
    
    let web:NetworkLayer!
    
    
    init(_ web:NetworkLayer){
        self.web = web
        getCards()
    }
    
    
    private var vaidate:Bool{
        if cardNo.count < 16{
            CommonFunctions.showToastWithMessage("Please enter the valid card number.")
            return false
        }else if cardHolderName.isEmpty{
            CommonFunctions.showToastWithMessage("Please enter the name")
            return false
        }else if cardHolderName.count<3{
            CommonFunctions.showToastWithMessage("Please enter the valid name")
            return false
        }else if cvv.isEmpty{
            CommonFunctions.showToastWithMessage("Please enter your cvv")
            return false
        }else if cvv.count>3{
            CommonFunctions.showToastWithMessage("Please enter the valid cvv")
            return false
        }else if expYear == 0 || expMonth == 0{
            CommonFunctions.showToastWithMessage("Please enter card expiry date")
            return false
        }else{
            return true
        }
    }
    
    
    func getCards(){
        web.request(from: WebService.getCards, param: [:], method: .GET, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    DispatchQueue.main.async {
                        self?.cards = StripCards.returnCardList(json["data"]["cards"])
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    
    private func setupIntent(completion:@escaping(String)->()){
        web.request(from: WebService.setIntent, param: [:], method: .POST, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    completion(json["data"]["clientSecret"].stringValue)
                    printDebug(json)
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func paymnetIntent(_ chatroomId:String,paymentMethodId:String,amount:Double,completion:@escaping(STPPaymentIntentParams)->()){
        let param:JSONDictionary = ["paymentMethodId":paymentMethodId,
                                    "chatroomId":chatroomId,
                                    "amount":amount]
        web.request(from: WebService.paymentIntent, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    if json[ApiKey.code].intValue == 201{
                        let paymentIntentParams = STPPaymentIntentParams(clientSecret: json["data"]["client_secret"].stringValue)
                        completion(paymentIntentParams)
                    }else{
                        CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func addCard(completions:@escaping(STPSetupIntentConfirmParams)->()){
        guard vaidate else { return }
        let params = STPCardParams()
        params.number = cardNo
        params.cvc = cvv
        params.name = cardHolderName
        params.expYear = expYear
        params.expMonth = expMonth
        let cardparams = STPPaymentMethodCardParams(cardSourceParams: params)
        let billingDetails = STPPaymentMethodBillingDetails()
        // Create SetupIntent confirm parameters with the above
        let paymentMethodParams = STPPaymentMethodParams(card: cardparams, billingDetails: billingDetails, metadata: nil)
        setupIntent { (setupIntentClientSecret) in
            DispatchQueue.main.async {
                let setupIntentParams = STPSetupIntentConfirmParams(clientSecret: setupIntentClientSecret)
                setupIntentParams.paymentMethodParams = paymentMethodParams
                completions(setupIntentParams)
            }
        }
    }
    
    func confirmPaymnet(_ intentId:String,chatroomId:String,paymentMethodId:String,isDefault:Bool = true,completion:@escaping()->()){
        let param:JSONDictionary = ["paymentIntentId":intentId,
                                    "chatroomId":chatroomId,
                                    "isDefault":true,
                                    "paymentMethodId":paymentMethodId]
        web.request(from: WebService.completePayment, param: param, method: .POST, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    printDebug(json)
                    completion()
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
}
