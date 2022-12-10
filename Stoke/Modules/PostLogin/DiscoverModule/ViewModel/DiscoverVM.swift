//
//  DiscoverVM.swift
//  Stoke
//
//  Created by Admin on 18/03/21.
//

import Foundation
import SwiftyJSON

class DiscoverVM {
    
    
    private var web:NetworkLayer!
    
    var currentDate:EventCalendar{
        return AppCalendar.shared.oneWeek.filter { $0.date.isToday }.first!
    }
    var isleaderBoardLoading:Bool = false
    var categories:[Categories] = []{
        didSet{
            DispatchQueue.main.async { [unowned self] in
                if let noti = self.notify { noti()}
            }
        }
    }
    
    var events:[Event] = []{
        didSet{
            DispatchQueue.main.async { [unowned self] in
                if let noti = self.notify { noti()}
            }
        }
    }
    
    var leaderBoard:[LeaderBoard] = []{
        didSet{
            DispatchQueue.main.async { [weak self] in
                if let noti = self?.notify { noti()}
            }
        }
    }
    var type:LeaderBordType = .like
    
    var notify:(()->())?
    
    init(_ web:NetworkLayer){
        self.web = web
        hitApiForCategories()
        hitTodaysEvents()
        hitLeaderBoardApi(){}
    }
    
    func hitApiForCategories(loader:Bool = true){
        let param:JSONDictionary = ["limit":60,"page":1]
        web.request(from: WebService.category, param: param, method: .GET, header: [:], loader: false) { [weak self](data, er) in
            guard let self = self else { return }
            if let e = er {
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        self.categories = CategoryListModel(json[ApiKey.data]).data
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    func hitLeaderBoardApi(type:LeaderBordType = .like,cID:String = "",_ completion:@escaping ()->()){
        isleaderBoardLoading = true
        let param:JSONDictionary = ["categoryId":cID,"type":type.rawValue,"page":1,"limit":100]
        web.request(from: WebService.leaderBord, param: param, method: .GET, header: [:], loader: false) { (data, err) in
            self.isleaderBoardLoading = false
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    guard let self = self else { return }
                    self.leaderBoard = LeaderBoardModel(json).data
                    completion()
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitTodaysEvents(){
        let param:JSONDictionary = ["page":1,
                                    "limit":50,
                                    "todayStartDateTime":Date().startOfDay.timeIntervalSince1970*1000,
                                    "todayEndDateTime":Date().endOfDay.timeIntervalSince1970*1000,
                                    "startDateTime":currentDate.timestamp,
                                    "endDateTime":currentDate.endTimestamp,
                                    "isFeatured":false,
                                    "isLive":false,
                                    "isToday":true]
        web.request(from: WebService.events, param: param, method: .GET, header: [:], loader: false) { [weak self](data, er) in
            guard let self = self else { return }
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        self.events = Event.returnEventArray(json[ApiKey.data][ApiKey.data])
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
}
