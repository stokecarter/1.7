//
//  FAQVm.swift
//  Stoke
//
//  Created by Admin on 29/10/21.
//

import Foundation
import SwiftyJSON

class FAQVm{
    
    private let web:NetworkLayer!
    var faqList: FAQList?{
        didSet{
            if let _list = faqList, let faqArr = _list.faqList{
                list = faqArr
            }
            if let t = refresh { t()}
        }
    }
    var list = [FAQModel]()
    var refresh:(()->())?
   
    init() {
        web = NetworkLayer()
        getFAQList()
    }
    
    func getFAQList(){
        
        web.requestString(from: "https://api.stokeapp.live/api/v1/3", method: .GET, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                DispatchQueue.main.async {
                    self.faqList = FAQList(json["data"]["data"])
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
}
