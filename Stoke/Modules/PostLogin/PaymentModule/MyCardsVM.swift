//
//  MyCardsVM.swift
//  Stoke
//
//  Created by Admin on 12/05/21.
//

import Foundation
import SwiftyJSON


class MyCardsVM{
    
    private let web:NetworkLayer!
    var cards:[StripCards] = []{
        didSet{
            if let reload = reloadData { reload() }
        }
    }
    
    var reloadData:(()->())?
    
    init(_ web:NetworkLayer){
        self.web = web
        getCards()
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
    
    func markDefault(_ id:String){
        let param:JSONDictionary = ["paymentMethodId":id]
        web.request(from: WebService.getCards, param: param, method: .PUT, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    self.getCards()
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func deleteCard(_ id:String){
        let url = WebService.getCards.path + "/\(id)"
        web.requestString(from: url, param: [:], method: .DELETE, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    self.getCards()
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
}
