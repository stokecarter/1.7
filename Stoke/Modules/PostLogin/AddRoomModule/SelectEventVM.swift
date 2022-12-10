//
//  SelectEventVM.swift
//  Stoke
//
//  Created by Admin on 12/04/21.
//

import Foundation

class SelectEventVM {
    
    private let web:NetworkLayer!
    
    var events:[Event] = []{
        didSet{
            if let not = notify { not()}
        }
    }
    var query:String = ""{
        didSet{
            hitEventListing()
        }
    }
    
    var notify:(()->())?
    
    init(_ web:NetworkLayer) {
        self.web = web
    }
    
    
    private func hitEventListing(){
        let param:JSONDictionary = ["search":query,"page":1,"limit":50,"isUpcoming":true,"isLive":true]
        web.request(from: WebService.searchEvents, param: param, method: .GET, header: [:], loader: true) { [weak self](data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        DispatchQueue.main.async {
                            self?.events = Event.returnEventArray(json[ApiKey.data][ApiKey.data])
                        }
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
}
