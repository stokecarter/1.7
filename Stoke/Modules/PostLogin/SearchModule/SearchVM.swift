//
//  SearchVM.swift
//  Stoke
//
//  Created by Admin on 18/03/21.
//

import Foundation
import SwiftyJSON


class SearchVM{
    
    enum SearchType{
        case user
        case event
        case tag
    }
    
    var searchStyle:SearchType = .user{
        didSet{
            if let noti = notifyTypeChage { noti()}
        }
    }
    
    var userList:UserListModel = UserListModel(JSON()){
        didSet{
            if let reload = reloadData { reload() }
        }
    }
    var eventList:[Event] = []{
        didSet{
            if let reload = reloadData { reload() }
        }
    }
    
    var tagList:TagListModel = TagListModel(JSON()){
        didSet{
            if let reload = reloadData { reload() }
        }
    }
    
    var clearData:Int{
        userList.data.removeAll()
        eventList.removeAll()
        tagList.data.removeAll()
        if let reload = reloadData { reload() }
        return 1
    }
    
    private var web:NetworkLayer!
    
    var reloadData:(()->())?
    var notifyTypeChage:(()->())?
    
    var searchQuery:String = ""{
        didSet{
            switch searchStyle {
            case .user:
                searchUser()
            case .event:
                searchEvent()
            default:
                searchTag()
            }
        }
    }
    
    init(_ web:NetworkLayer){
        self.web = web
    }
    
    
    
    private func searchUser(){
        guard !searchQuery.isEmpty else { return }
        let param:JSONDictionary = ["search":searchQuery,"page":1,"limit":25]
        web.request(from: WebService.users, param: param, method: .GET, header: [:], loader: true) { [weak self](data, er) in
            guard let d = data else { CommonFunctions.showToastWithMessage(er?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { (json) in
                self?.userList = UserListModel(json[ApiKey.data])
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }

    
    private func searchEvent(){
        guard !searchQuery.isEmpty else { return }
        let param:JSONDictionary = ["search":searchQuery,"page":1,"limit":10]
        web.request(from: WebService.searchEvents, param: param, method: .GET, header: [:], loader: true) { [weak self](data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        self?.eventList = Event.returnEventArray(json[ApiKey.data][ApiKey.data])
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func searchTag(){
        guard !searchQuery.isEmpty else { return }
        let param:JSONDictionary = ["search":searchQuery,"page":1,"limit":10]
        web.request(from: WebService.tags, param: param, method: .GET, header: [:], loader: true) { [weak self](data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        self?.tagList = TagListModel(json[ApiKey.data])
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
    
    
}
