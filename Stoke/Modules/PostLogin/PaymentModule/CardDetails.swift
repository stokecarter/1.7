//
//  CardDetails.swift
//  Stoke
//
//  Created by Admin on 07/05/21.
//

import Foundation
import SwiftyJSON



/*
 object CARD_TYPE {
        const val VISA = "visa"
        const val MASTER_CARD = "mastercard"
        const val MASTER_UNION_PAY = "unionpay"
        const val AMEX = "amex"
        const val DISCOVER = "discover"
        const val JCB = "jcb"
        const val DINERS = "diners"
    }
 */


enum CardBrand:String{
    case visa
    case mastercard
    case jcb
    case diners
    case discover
    case amex
    case unionpay
    case unknowned
    
    init(_ val:String){
        switch val {
        case "visa":
            self = .visa
        case "mastercard":
            self = .mastercard
        case "jcb":
            self = .jcb
        case "diners":
            self = .diners
        case "discover":
            self = .discover
        case "amex":
            self = .amex
        case "unionpay":
            self = .unionpay
        default:
            self = .unknowned
        }
    }
    
    var image:UIImage{
        switch self {
        case .visa:
            return #imageLiteral(resourceName: "ic-visa")
        case .mastercard:
            return #imageLiteral(resourceName: "ic-mastero")
        case .jcb:
            return #imageLiteral(resourceName: "jcb")
        case .diners:
            return #imageLiteral(resourceName: "diners-club")
        case .discover:
            return #imageLiteral(resourceName: "discover")
        case .amex:
            return #imageLiteral(resourceName: "american-express")
        case .unionpay:
            return #imageLiteral(resourceName: "union-pay")
        default:
            return #imageLiteral(resourceName: "ic_add_card")
        }
    }
}
struct StripCards{
    let customer:String
    let exp_month:UInt
    let last4:String
    let brand:CardBrand
    let exp_year:UInt
    let id:String
    var isDefault:Bool
    
    init(_ json:JSON){
        customer = json["customer"].stringValue
        exp_month = UInt(json["exp_month"].intValue)
        last4 = json["card"]["last4"].stringValue
        brand = CardBrand(json["card"]["brand"].stringValue)
        exp_year = UInt(json["exp_year"].intValue)
        id = json["id"].stringValue
        isDefault = json["isDefault"].boolValue
    }
    
    static func returnCardList(_ json:JSON) ->[StripCards]{
        return json.arrayValue.map { StripCards($0)}
    }
}
    
    

/*
 
 "customer" : "cus_JRJiAkUzIL09T1",
 "created" : 1620387769,
 "object" : "payment_method",
 "card" : {
   "three_d_secure_usage" : {
     "supported" : true
   },
   "checks" : {
     "address_line1_check" : null,
     "address_postal_code_check" : null,
     "cvc_check" : "pass"
   },
   "funding" : "credit",
   "generated_from" : null,
   "exp_month" : 5,
   "country" : "US",
   "wallet" : null,
   "last4" : "4242",
   "fingerprint" : "akoDKg4880TqoEmV",
   "brand" : "visa",
   "exp_year" : 2025,
   "networks" : {
     "preferred" : null,
     "available" : [
       "visa"
     ]
   }
 },
 "livemode" : false,
 "type" : "card",
 "billing_details" : {
   "email" : null,
   "address" : {
     "line2" : null,
     "postal_code" : null,
     "city" : null,
     "country" : null,
     "state" : null,
     "line1" : null
   },
   "name" : null,
   "phone" : null
 },
 "id" : "pm_1IoS4zAu6wFrXWJepBibblzP",
 "metadata" : {

 }

 */


struct CardDetails {
    var cardNo:String
    var cardholderName:String
    var cvv:String
    var expMonth:UInt
    var expYear:UInt
    var isDefault:Bool = false
}
