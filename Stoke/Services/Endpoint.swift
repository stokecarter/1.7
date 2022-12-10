//
//  Endpoint.swift
//  Covid-19 Dependecy_Injection
//
//  Created by Arpit Srivastava on 01/11/20.
//  Copyright © 2020 Arpit Srivastava. All rights reserved.
//

enum ServerType {
    case dev
    case qa
    case staging
    case production
    case pre_pod
}

var server: ServerType = .production

protocol Endpoint {
    var path: String { get }
}

enum WebService:String {
    
    case username = "/check-username"
    case signup = "/signup"
    case login = "/login"
    case guestLogin = "/guest-signup"
    case otp = "/verify-otp"
    case resendOtp = "/send-otp"
    case resendForgotOtp = "/send-forget-otp"
    case checkSocail = "/check-social-id"
    case socailLogin = "/social-login"
    case forgotPassword = "/forgot-password"
    case resetPassword = "/reset-password"
    case verifyResetOtp = "/verify-forget-otp"
    case logout = "/logout"
    case hotTake = "/hot-take"
    case hotTakeVote = "/hot-take-vote"
    case hotTakeReport = "/hot-take/report"
    case hotTakeCheckWeekday = "/hot-take/check-weekday"
    
    case featureList = "/featured-events"
    case category = "/category"
    case todayEvents = "/today-events"
    case recomendedChatRooms = "/recommended-chatrooms"
    case recomendedEvents = "/recommended-events"
    case users = ""
    case events = "/events"
    case allEvents = "/events/all"
    case tags = "/tags"
    case searchEvents = "/events/search"
    
    case inviteChatroom = "/chatroom/invite-string"
    case getChatRooms = "/chatrooms"
    case inviteUserChatRoom = "/chatrooms/invite"
    case chatroomInviteList = "/chatrooms/invite-list"
    case saveUnsaveTags = "/chatrooms/tags"
    case getChatRoomDetail = "/chatrooms/"
    case saveChatRoom = "/my-chatrooms"
    
    case chatroomUsers = "/chatrooms/users"
    case trending = "/trending-events"
    case followUnfollow = "/follow-unfollow"
    case requestToJoin = "/chatrooms/request-to-join"
    case inviteRequest = "/chatrooms/request-pending"
    case saveCreadedRooms = "/chatrooms/saved-created"
    
    case comments = "/chatrooms/comments"
    case reply = "/chatrooms/comments/reply"
    case leaderBord = "/chatrooms/leaderboard"
    case approveByCelebrity = "/chatrooms/approve-comment"
    case saveCommnets = "/chatrooms/saved-comments"
    case reportCommnet = "/chatrooms/report-comment"
    case checkChatroom = "/check-chatrooms"
    
    /// Paymnets
    case getCards = "/cards"
    case paymentIntent = "/payment-intent"
    case setIntent = "/setup-intent"
    case myPayments = "/my-payments"
    case completePayment = "/complete-payment"
    
    /// Profile
    case userProfile = "/profile"
    case userNotificationSettings = "/notifications/settings"
    case changePassword = "/change-password"
    case feedback = "/feedback"
    case blockUser = "/block-unblock"
    case blockUserList = "/blocked-users"
    case followFollowing = "/follow-following-list"
    case contact = "/contact"
    case notifications = "/notifications"
    case report = "/reported-user"
    case updateInfo = "/info"
    case resendVerificationmale = "/resend-verification-mail"
    case actionFollowRequest = "/follow/action"
    case ribbonLogic = "/ribbon-logic"
    case eventDetail = "/event-detail"
    
    /// Admin
    case reportedCommnetsList = "admin/chatrooms/reported-comments"
    case deleteCommnets = "/chatrooms/delete-comments"
    case deleteUser = "/chatrooms/delete-user"
    case adminNotification = "/admin-notifications"
    
    case faq = "/3"
    
}

extension WebService: Endpoint {
    private var baseUrl:String{
        switch server {
        case .dev:
            return "http://chatroomsdevapi.appskeeper.in:7151/api/v1/users"
        case .qa:
            return "http://chatroomsqaapi.appskeeper.in:7152/api/v1/users"
        case .staging:
            return "http://chatroomsstgapi.appskeeper.in:7153/api/v1/users"
        case .pre_pod:
            return "http://10.0.6.217:6621/api/v1/users" //"https://pre-prod-api-1937859798.us-east-1.elb.amazonaws.com/api/v1/users"//"http://10.0.6.217:6621/api/v1/users"//"https://preprodapi.stokeapp.live/api/v1/users"
            //"https://pre-prod-api-1937859798.us-east-1.elb.amazonaws.com/api/v1/users"//
        default:
            return "https://api.stokeapp.live/api/v1/users"
        }
    }
    
    var cardBaseUrl:String {
        switch server {
        case .dev:
            return "http://chatroomsdevapi.appskeeper.in:7151/api/v1/"
        case .qa:
            return "http://chatroomsqaapi.appskeeper.in:7152/api/v1/"
        case .staging:
            return "http://chatroomsstgapi.appskeeper.in:7153/api/v1/"
        case .pre_pod:
            return "https://preprodapi.stokeapp.live/api/v1/"
        default:
            return "https://api.stokeapp.live/api/v1/"
        }
    }
    
    var paymentPath:String{
        return (cardBaseUrl + self.rawValue)
    }
    
    var path: String {
        return (baseUrl + self.rawValue)
    }
    
    static var pageUrl:String{
        switch server {
        case .dev:
            return "http://chatroomsdevadmin.appskeeper.in/"
        case .production:
            return "https://admin.stokeapp.live/"//https://api.stokeapp.live/"
        case .staging:
            return "http://chatroomsstgadmin.appskeeper.in/"
        case .qa:
            return "http://chatroomsqaadmin.appskeeper.in/"
        case .pre_pod:
            return "https://preprodapi.stokeapp.live/api/v1/"
        }
    }
}
