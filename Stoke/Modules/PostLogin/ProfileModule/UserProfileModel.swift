//
//  UserProfileModel.swift
//  Stoke
//
//  Created by Admin on 17/05/21.
//

import Foundation
import SwiftyJSON

enum RankingType:String{
    case overall
    case category
}

struct RankData {
    var rank:Int
    var category:String
    var type:LeaderBordType
    var rankString:String
    var rankingType:RankingType
    var isTop100:Bool
    init(_ json:JSON){
        isTop100 = json["isTop100"].boolValue
        rank = json["rank"].intValue
        category = json["category"].stringValue
        type = LeaderBordType(rawValue: json["type"].stringValue) ?? .like
        rankString = json["rankString"].stringValue
        rankingType = RankingType(rawValue: json["rankingType"].stringValue) ?? .category
    }
    
}

struct Location {
    let address:String
    let longitude:Double
    let latitude:Double
    init(_ json:JSON){
        address = json["address"].stringValue
        longitude = json["coordinates"].arrayValue.first?.doubleValue ?? 0.0
        latitude = json["coordinates"].arrayValue.last?.doubleValue ?? 0.0
    }
}


struct UserProfileModel{
    
    let like:Int
    let isPaymentDone:Bool
    let isFollow:Bool
    let userName:String
    let profilePicture:String
    let laugh:Int
    let followingCount:Int
    let followersCount:Int
    let _id:String
    let isMostLikedProfile:Bool
    let isPrivateAccount:Bool
    let isEmailVerified:Bool
    let isMobileVerified:Bool
    let dislike:Int
    let isHideEngagementStats:Bool
    let bio:String
    let status:Bool
    let firstName:String
    let isGuestAccount:Bool
    let clap:Int
    let userType:String
    let lastName:String
    let isCelebrity:Bool
    var location:Location
    let fullName:String
    let profileLink:String
    var rankData:RankData
    let isTrusted:Bool
    var email:String
    var mobileNo:String
    var countryCode:String
    var toUserFollowStatus:FollowStatus
    var myfollowStatus:FollowStatus
    
    
    init(_ json:JSON) {
        like = json["like"].intValue
        followingCount = json["followingCount"].intValue
        laugh = json["laugh"].intValue
        followersCount = json["followersCount"].intValue
        dislike = json["dislike"].intValue
        clap = json["clap"].intValue
        isPaymentDone = json["isPaymentDone"].boolValue
        isFollow = json["isFollow"].boolValue
        isMostLikedProfile = json["isMostLikedProfile"].boolValue
        isPrivateAccount = json["isPrivateAccount"].boolValue
        isEmailVerified = json["isEmailVerified"].boolValue
        isMobileVerified = json["isMobileVerified"].boolValue
        isHideEngagementStats = json["isHideEngagementStats"].boolValue
        status = json["status"].boolValue
        isGuestAccount = json["isGuestAccount"].boolValue
        isCelebrity = json["isCelebrity"].boolValue
        profilePicture = json["profilePicture"].stringValue
        userName = json["userName"].stringValue
        _id = json["_id"].stringValue
        bio = json["bio"].stringValue
        firstName = json["firstName"].stringValue
        userType = json["userType"].stringValue
        lastName = json["lastName"].stringValue
        location = Location(json["location"])
        fullName = (firstName.capitalizedFirst + " " + lastName.capitalizedFirst).byRemovingLeadingTrailingWhiteSpaces
        profileLink = json["profileLink"].stringValue
        rankData = RankData(json["rankData"])
        isTrusted = json["isTrusted"].boolValue
        email = json["email"].stringValue
        mobileNo = json["mobileNo"].stringValue
        countryCode = json["countryCode"].stringValue
        toUserFollowStatus = FollowStatus(rawValue: json["toUserFollowStatus"].stringValue) ?? .none
        myfollowStatus = FollowStatus(rawValue: json["followStatus"].stringValue) ?? .none
    }
    
    init(withDB u:UserProfileDBM){
        like = u.like
        followingCount = u.followingCount
        laugh = u.laugh
        followersCount = u.followersCount
        dislike = u.dislike
        clap = u.clap
        isPaymentDone = u.isPaymentDone
        isFollow = u.isFollow
        isMostLikedProfile = u.isMostLikedProfile
        isPrivateAccount = u.isPrivateAccount
        isEmailVerified = u.isEmailVerified
        isMobileVerified = u.isMobileVerified
        isHideEngagementStats = u.isHideEngagementStats
        status = u.status
        isGuestAccount = u.isGuestAccount
        isCelebrity = u.isCelebrity
        profilePicture = u.profilePicture
        userName = u.userName
        _id = u._id
        bio = u.bio
        firstName = u.firstName
        userType = u.userType
        lastName = u.lastName
        location = Location(JSON())
        fullName = (firstName.capitalizedFirst + " " + lastName.capitalizedFirst).byRemovingLeadingTrailingWhiteSpaces
        profileLink = u.profileLink
        var r = RankData(JSON())
        r.category = u.category
        r.rank = u.rank
        r.type = u.type
        r.rankString = u.rankString
        r.rankingType = u.rankingType
        rankData = r
        isTrusted = u.isTrusted
        email = u.email
        mobileNo = u.mobileNo
        countryCode = u.countryCode
        toUserFollowStatus = u.toUserFollowStatus
        myfollowStatus = u.myfollowStatus
    }
    
    
}
