//
//  LeaderBoardVM.swift
//  Stoke
//
//  Created by Admin on 27/04/21.
//

import Foundation

enum LeaderBordType:String{
    case like
    case clap
    case laugh
}

class LeaderBoardVM{
    
    private let web:NetworkLayer!
    var currentPage = 1
    var reload:(()->())?
    var cID = ""
    var leaderBoard:[LeaderBoard] = []{
        didSet{
            if let r = reload { r()}
        }
    }
    
    var completeData:[LeaderBoard] = []
    init(_ web:NetworkLayer){
        self.web = web
        hitLeaderBoardApi {}
    }
    
    var totalFirstRank:Int = 0
    var totalSecondRank:Int = 0
    var totalThirdRank:Int = 0

    var type:LeaderBordType = .like
    
    func hitLeaderBoardApi(type:LeaderBordType = .like,completion:@escaping (()->())){
        self.type = type
        let param:JSONDictionary = ["categoryId":cID,"type":type.rawValue,"page":1,"limit":100]
        web.request(from: WebService.leaderBord, param: param, method: .GET, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    guard let self = self else { return }
                    if json[ApiKey.code].intValue == 200{
                        let d = LeaderBoardModel(json)
                        self.completeData = d.data
                        self.totalFirstRank = d.firstRankCount
                        self.totalSecondRank = d.secondRank
                        self.totalThirdRank = d.thirdRank
                        self.leaderBoard = d.reducedData
                        completion()
                    }else{
                        CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue)
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitApiForCategories(completion:@escaping(([Categories])->())){
        let param:JSONDictionary = ["limit":60,"page":1]
        web.request(from: WebService.category, param: param, method: .GET, header: [:], loader: true) { [weak self](data, er) in
            guard let self = self else { return }
            if let e = er {
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        DispatchQueue.main.async {
                            completion(CategoryListModel(json[ApiKey.data]).data)
                        }
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
}
