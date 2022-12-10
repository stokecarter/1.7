//
//  FeatureVM.swift
//  Stoke
//
//  Created by Admin on 17/03/21.
//

import Foundation
import SwiftyJSON

class FeatureListVM{
    
    var dataSource:FeaturedList = FeaturedList(JSON()){
        didSet{
            if let noti = notify { noti() }
        }
    }
    
    var posts:PostList = PostList(JSON()){
        didSet{
            if let noti = notify { noti() }
        }
    }
    
    var allEvents: FeaturedList = FeaturedList(JSON()){
        didSet{
            if let noti = notify { noti() }
        }
    }
    
    var trendingCurrentPage = 1
    var currentPage:Int = 1
    var isOngoing:Bool = true
    var web:NetworkLayer!
    var notify:(()->())?
    var updateCalender:((Bool)->())?
    var isDataLoaded:Bool = true
    var hotTakeType: HotTakeListType = .new
    
    init(_ web:NetworkLayer, date:EventCalendar, allEvent: Bool = false){
        self.web = web
        if allEvent {
            hitAllEventsApi(date: date, loader: true)
        } else {
            hitFeaturesApi(date: date, loader: true)
        }
    }
    
//    init(_ web:NetworkLayer, date:EventCalendar, allEvent: Bool = true){
//        self.web = web
//        hitAllEventsApi(date: date, loader: true)
//    }
    
    func hitFeaturesApi(date:EventCalendar,loader:Bool = false){
        isDataLoaded = false
        let param:JSONDictionary = ["page":1,
                                    "limit":100,
                                    "startDateTime":date.timestamp,
                                    "endDateTime":date.endTimestamp,
                                    "isFeatured":true,
                                    "todayStartDateTime":Date().startOfDay.timeIntervalSince1970*1000,
                                    "todayEndDateTime":Date().endOfDay.timeIntervalSince1970*1000,
                                    "isLive":date.isOngoing,
                                    "isToday":date.isOngoing ? false : date.date.isToday]
        web.request(from: WebService.events, param: param, method: .GET, header: [:], loader: loader) { [weak self](data, e) in
            self?.isDataLoaded = true
            guard let self = self else { return }
            if let e = e{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { [weak self](json) in
                        guard let self = self else { return }
                        self.isOngoing = json[ApiKey.data]["isOngoing"].boolValue
                        let count = json[ApiKey.data]["unreadCount"].intValue
                        AppRouter.tabBar.isNewNotification = count > 0 ? count : nil
                        CommonFunctions.updateBadgeTo = count
                        if let t = self.updateCalender { t(self.isOngoing)}
//                        if self.currentPage == 1{
                            self.dataSource = FeaturedList(json[ApiKey.data])
//                        }else{
//                            self.dataSource.data.append(contentsOf: FeaturedList(json[ApiKey.data]).data)
//                        }
                        DispatchQueue.main.async {
                            let tl = json[ApiKey.data]["totalLikes"].stringValue
                            let tc = json[ApiKey.data]["totalComments"].stringValue
                            let td = json[ApiKey.data]["totalDislikes"].stringValue
                            let tlh = json[ApiKey.data]["totalLaugh"].stringValue
                            let tcp = json[ApiKey.data]["totalClaps"].stringValue
                            StokeAnalytics.shared.updatedEngagemnets((tl,tc,td,tlh,tcp))
                        }
                          
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    func hitForHotTakes(type: HotTakeListType = .new, loader:Bool = false){
        isDataLoaded = false
        hotTakeType = type
        let param:JSONDictionary = ["page":trendingCurrentPage,
                                    "limit":10,
                                    "listType": hotTakeType.rawValue]
        web.request(from: WebService.hotTake, param: param, method: .GET, header: [:], loader: loader) { (data, err) in
            self.isDataLoaded = true
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) {[weak self] (json) in
                        guard let self = self else { return }
                        if self.trendingCurrentPage == 1{
//                            var d = CommnetsModel(json[ApiKey.data])
//                            d.data.reverse()
//                            self.trending = d
                            self.posts = PostList(json[ApiKey.data])
                        } else {
                            self.posts.data.append(contentsOf: PostList(json[ApiKey.data]).data)
                            let m = PostList(json[ApiKey.data])
                            self.posts.totalCount = m.totalCount
                            self.posts.nextPage = m.nextPage
                            self.posts.page = m.page
                        }
                        self.posts.isLoaded = true
//                        if self.trendingCurrentPage == 1{
//                            self.posts = PostList(json[ApiKey.data])
//                        }else{
//                            self.posts.data.append(contentsOf: PostList(json[ApiKey.data]).data)
//                        }
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    func hitAllEventsApi(date: EventCalendar, loader: Bool = false) {
        isDataLoaded = false
        let param:JSONDictionary = ["page":1,
                                    "limit":100,
                                    "startDateTime":date.timestamp,
                                    "endDateTime":date.endTimestamp,
                                    "isFeatured": false,
                                    "todayStartDateTime":Date().startOfDay.timeIntervalSince1970*1000,
                                    "todayEndDateTime":Date().endOfDay.timeIntervalSince1970*1000,
                                    "isLive":date.isOngoing,
                                    "isToday":date.isOngoing ? false : date.date.isToday]
        web.request(from: WebService.events, param: param, method: .GET, header: [:], loader: loader) { [weak self](data, e) in
            self?.isDataLoaded = true
            guard let self = self else { return }
            if let e = e{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { [weak self](json) in
                        guard let self = self else { return }
                        self.isOngoing = json[ApiKey.data]["isOngoing"].boolValue
                        let count = json[ApiKey.data]["unreadCount"].intValue
                        AppRouter.tabBar.isNewNotification = count > 0 ? count : nil
                        CommonFunctions.updateBadgeTo = count
                        if let t = self.updateCalender { t(self.isOngoing)}
                            self.allEvents = FeaturedList(json[ApiKey.data])
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    func hitAddPostAPI(text: String, completion:@escaping(Bool)->()){
        let param:JSONDictionary = ["text": text]
        web.request(from: WebService.hotTake, param: param, method: .POST, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                if json[ApiKey.code].intValue >= 400{
                    if json["message"].stringValue == "You can't add post on weekend" {
                        completion(false)
                    } else {
                        CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                    }
                    
                }else{
                    completion(true)
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }

        }
    }
    
    func hitVoteAPI(postId: String, vote: Int, completion:@escaping()->()){
        let param:JSONDictionary = ["postId": postId, "vote": vote]
        web.request(from: WebService.hotTakeVote, param: param, method: .POST, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                if json[ApiKey.code].intValue >= 400{
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                }else{
                    for (index, hotTake) in self.posts.data.enumerated() {
                        if hotTake.id == json[ApiKey.data][ApiKey.postId].stringValue {
                            self.posts.data[index].vote = json[ApiKey.data][ApiKey.vote].intValue
                            self.posts.data[index].isVoted = json[ApiKey.data][ApiKey.isVoted].boolValue
                            self.posts.data[index].ownVote = vote
                        }
                    }
                    completion()
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }

        }
    }
    
    func hitReportPostAPI(postId: String, completion:@escaping()->()){
        let param:JSONDictionary = ["postId": postId]
        web.request(from: WebService.hotTakeReport, param: param, method: .PUT, header: [:], loader: true) { (data, err) in
            if let e = err {
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            } else {
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue, theme: .success)
                    DispatchQueue.main.async {
                        completion()
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }

        }
    }
    
    func hitDeletePostAPI(postId: String, completion:@escaping()->()){
        let param:JSONDictionary = ["postId": postId]
        web.request(from: WebService.hotTake, param: param, method: .DELETE, header: [:], loader: true) { (data, err) in
            if let e = err {
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            } else {
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue, theme: .success)
                    DispatchQueue.main.async {
                        completion()
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitCheckWeekdayAPI(completion:@escaping(Bool)->()){
        web.request(from: WebService.hotTakeCheckWeekday, param: [:], method: .GET, header: [:], loader: true) { (data, e) in
            guard let d = data else { CommonFunctions.showToastWithMessage(e?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                if json[ApiKey.code].intValue >= 400{
                    if json["message"].stringValue == "You can't add post on weekend" {
                        completion(false)
                    } else {
                        CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                    }
                }else{
                    completion(true)
                }
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
}
