//
//  LeaderBoard.swift
//  Stoke
//
//  Created by Admin on 27/04/21.
//

import Foundation
import SwiftyJSON


struct LeaderBoard {
    
    var email:String
    var lastName:String
    var userName:String
    var rank:Int
    var _id:String
    var image:String
    var count:Int
    var firstName:String
    var fullName:String
    let isTrusted:Bool
    
    
    init(_ json:JSON){
        email = json["email"].stringValue
        lastName = json["lastName"].stringValue
        userName = json["userName"].stringValue
        rank = json["rank"].intValue
        _id = json["_id"].stringValue
        image = json["image"].stringValue
        count = json["count"].intValue
        firstName = json["firstName"].stringValue
        fullName = (firstName + " " + lastName).byRemovingLeadingTrailingWhiteSpaces
        isTrusted = json["isTrusted"].boolValue
    }
    
    static func returnLeaderBoard(_ json:JSON) -> [LeaderBoard]{
        return json.arrayValue.map { LeaderBoard($0)}
    }
}

struct LeaderBoardModel {
    var data:[LeaderBoard]
    
    init(_ json:JSON){
        data = LeaderBoard.returnLeaderBoard(json["data"]["data"])
    }
    
    var firstRankCount:Int{
        return data.filter { $0.rank == 1}.count
    }
    
    var secondRank:Int{
        return data.filter { $0.rank == 2}.count
    }
    
    var thirdRank:Int{
        return data.filter { $0.rank == 3}.count
    }
    
    var reducedData:[LeaderBoard]{
        var temp:[LeaderBoard] = []
        
        data.forEach { (d) in
            if d.rank > 3{
                temp.append(d)
            }else{
                if let index = temp.firstIndex(where: { $0.rank == d.rank }){
                    printDebug(data[index].rank)
                }else{
                    temp.append(d)
                }
            }
        }
        return temp
    }
}
