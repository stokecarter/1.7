//
//  Analytics.swift
//  Stoke
//
//  Created by Admin on 31/05/21.
//

import Foundation
import FirebaseAnalytics


enum AppEvents:String{
    
    case visitDiscoverScreen
    case visitLeaderBoardDetailScreen
    case visitMyRooms
    case visitCategoryListing
    case visitMyProfile
    case visitOtherUserProfile
    
    case visitNotifications
    case visitFeaturedEvents
    case visitTrendingEvents
    case visitTodayEvents
    case searchTag
    case searchEvent
    case searchUser
    
    case signupWithGoogle
    case signupWithFB
    case signupWithEmail
    case chatroomCreated
    
}




class StokeAnalytics {
    
    static let shared  = StokeAnalytics()
    private init(){}
    
    
    private func setUserId(){
        Analytics.setUserID(UserModel.main.userId)
    }
    
    
    func resetAnalytics(){
        DispatchQueue.backgroundQueueAsync {
            Analytics.resetAnalyticsData()
        }
    }
    
    func updateUserOnLogin(){
        DispatchQueue.backgroundQueueAsync {
            self.setUserId()
            let m = UserModel.main
            Analytics.setUserProperty(m.email, forName: "email")
            Analytics.setUserProperty("\(m.mobileNo)", forName: "mobileNo")
            Analytics.setUserProperty("\(m.countryCode)", forName: "countryCode")
            Analytics.setUserProperty(m.firstName, forName: "firstName")
            Analytics.setUserProperty(m.lastName, forName: "lastName")
            Analytics.setUserProperty(m.userName, forName: "userName")
            Analytics.setUserProperty(m.fullName, forName: "fullName")
        }
    }
    
    
    func updatedEngagemnets(_ eng:(String,String,String,String,String)){
        DispatchQueue.backgroundQueueAsync {
            Analytics.setUserProperty(eng.0, forName: "totalLikes")
            Analytics.setUserProperty(eng.1, forName: "totalComments")
            Analytics.setUserProperty(eng.2, forName: "totalDislikes")
            Analytics.setUserProperty(eng.3, forName: "totalLaugh")
            Analytics.setUserProperty(eng.4, forName: "totalClaps")
        }
    }
    
    func setScreenVisitEvent(_ type:AppEvents){
        
        DispatchQueue.backgroundQueueAsync {
            var name = ""
            switch type {
            case .visitFeaturedEvents:
                name = "Featured Screen"
            case .visitTrendingEvents:
                name = "Trending Screen"
            case .visitMyRooms:
                name = "My Rooms Screen"
            case .visitDiscoverScreen:
                name = "Discover Screen"
            case .visitMyProfile:
                name = "Profile Screen"
            default:
                name = ""
            }
            Analytics.logEvent(type.rawValue, parameters: [
              "name": name,
              "full_text":""
              ])
        }
        
    }
    
    
    
}
