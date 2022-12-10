//
//  CatergoriesEventListVM.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import Foundation
import SwiftyJSON


class CategoriesEventList{
    
    enum EventType:String{
        case upcoming
        case history
    }
    
    var currentPage = 1
    let web:NetworkLayer!
    var notifyUpdate:(()->())?
    let categoryId:String
    var sortingStyle:SortingBy = .time
    var isOngoing = false
    var currentpage = 1
    var isDataLoaded:Bool = true

    var updateCalender:((Bool)->())?
    var upcomingEvents:FeaturedList = FeaturedList(JSON()){
        didSet{
            if let noti = notifyUpdate { noti()}
        }
    }
    
    
    
    init(_ web:NetworkLayer, categoryId:String){
        self.web = web
        self.categoryId = categoryId
    }
    
    
    func getEvent(date:EventCalendar,loader:Bool = false){
        isDataLoaded = false
        let param:JSONDictionary = ["page":1,
                                    "limit":100,
                                    "todayStartDateTime":Date().startOfDay.timeIntervalSince1970*1000,
                                    "todayEndDateTime":Date().endOfDay.timeIntervalSince1970*1000,
                                    "categoryId":categoryId,
                                    "startDateTime":date.timestamp,
                                    "endDateTime":date.endTimestamp,
                                    "isFeatured":false,
                                    "isLive":date.isOngoing]
        web.request(from: WebService.events, param: param, method: .GET, header: [:], loader: loader) { [weak self](data, e) in
            self?.isDataLoaded = true
            guard let self = self else { return }
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { [weak self] (json) in
                guard let self = self else { return }
                self.isOngoing = json[ApiKey.data]["isOngoing"].boolValue
                if let n = self.updateCalender { n(self.isOngoing)}
                self.upcomingEvents = FeaturedList(json[ApiKey.data])
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
}
