//
//  UserInputKeys.swift
//  DittoFashionMarketBeta
//
//  Created by Appinventiv Technologies on 05/02/18.
//  Copyright © 2018 Bhavneet Singh. All rights reserved.
//

import Foundation

//MARK:- Api Keys
//=======================
enum ApiKey {
    
    static var status: String { return "status" }
    static var code: String { return "statusCode" }
    static var result: String { return "RESULT" }
    static var data:String { return "data"}
    static var message: String { return "message" }
    static var Authorization: String { return "Authorization" }
    static var user_id: String { return "user_id" }
    static var name: String { return "name" }
    static var first_name: String { return "first_name" }
    static var last_name: String { return "last_name" }
    static var email: String { return "email" }
    static var password: String { return "password" }
    static var confirmPassword: String { return "confirmPassword" }
    static var gender: String { return "gender" }
    static var phone: String { return "phone" }
    static var dob: String { return "dob" }
    static var address: String { return "address" }
    static var user_lat: String { return "user_lat" }
    static var user_long: String { return "user_long" }
    static var country_id: String { return "country_id" }
    static var state_id: String { return "state_id" }
    static var city_id: String { return "city_id" }
    static var device_id: String { return "device_id" }
    static var device_token: String { return "device_token" }
    static var platform: String { return "platform" }
    
    static var token: String { return "token" }
    static var refreshToken: String { return "refresh_token" }
    static var resetSuccess: String { return "resetSuccess" }
    static var oldpassword: String { return "oldpassword" }
    static var vote: String { return "vote" }
    static var isVoted: String { return "isVoted" }
    static var id: String { return "id" }
    static var postId: String { return "postId" }
    
}

//MARK:- Api Code
//=======================
enum ApiCode {
    
    static var success: Int { return 200 } // Success
    static var unauthorizedRequest: Int { return 206 } // Unauthorized request
    static var headerMissing: Int { return 207 } // Header is missing
    static var phoneNumberAlreadyExist: Int { return 208 } // Phone number alredy exists
    static var requiredParametersMissing: Int { return 418 } // Required Parameter Missing or Invalid
    static var fileUploadFailed: Int { return 421 } // File Upload Failed
    static var pleaseTryAgain: Int { return 500 } // Please try again
    static var tokenExpired: Int { return 401 } // Token expired refresh token needed to be generated
}
