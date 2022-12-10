//
//  UserModel.swift
//  NewProject
//
//  Created by Harsh Vardhan Kushwaha on 30/08/18.
//  Copyright © 2018 Harsh Vardhan Kushwaha. All rights reserved.
//

import Foundation
import SwiftyJSON
/*
 {
     "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2MDM3NTIzNTY0Y2YxYTBlYjg3ZjAzOGUiLCJlbWFpbCI6ImFycGl0OTg0MEBnbWFpbC5jb20iLCJzYWx0IjoiMWM4MGU1ZjdhYmJlMmVjZjUwZmE4ZDYwMjQxMTc4ZTkiLCJpYXQiOjE2MTQyMzk0MjgsImV4cCI6MTYyOTc5MTQyOH0.l0KMkqcpXMOZ9JghQXd258owk9W70iA-DeKlDB5GcWo",
     "refreshToken": "MGYyNjY5YTRlZGE1ZDFhODcyNTVkMzU1OTdjOGIyYmU=",
     "userId": "6037523564cf1a0eb87f038e",
     "firstName": "",
     "lastName": "",
     "email": "arpit9840@gmail.com",
     "profilePicture": "",
     "isEmailVerified": false,
     "isMobileVerified": false,
     "countryCode": "",
     "mobileNo": "",
     "registeredUsing": 1,
     "createdAt": "2021-02-25T07:31:01.396Z",
     "userName": "arpit",
     "userType": "user"
   }
 */

// MARK:- User Model
//====================

struct UserModel {
    
    static var main = UserModel(AppUserDefaults.value(forKey: .fullUserProfile)) {
        didSet {
            main.saveToUserDefaults()
        }
    }
    let userId: String
    let firstName: String
    let lastName:String
    let profilePicture:String
    let isEmailVerified:Bool
    let isMobileVerified:Bool
    let mobileNo: String
    let countryCode:String
    var accessToken, refreshToken : String
    let userName:String
    let userType:String
    let isGuestAccount:Bool
    let registeredUsing:Int
    
    var isUserLogin:Bool{
        return !accessToken.isEmpty
    }
    var isCelebrity:Bool{
        return AppUserDefaults.value(forKey: .isCelibrity).boolValue
    }
    var isAdmin:Bool{
        return userType == "admin"
    }
    var fullName:String{
        return (firstName + " " + lastName).byRemovingLeadingTrailingWhiteSpaces
    }
    var email:String{
        return AppUserDefaults.value(forKey: .email).stringValue
    }
    init() {
        self.init(JSON([:]))
    }
    
    init (_ json: JSON = JSON()) {
        isGuestAccount = json["isGuestAccount"].boolValue
        userId = json["userId"].stringValue
        firstName = json["firstName"].stringValue.capitalizedFirst
        lastName = json["lastName"].stringValue.capitalizedFirst
        profilePicture = json["profilePicture"].stringValue
        isMobileVerified = json["isMobileVerified"].boolValue
        isEmailVerified = json["isEmailVerified"].boolValue
        mobileNo = json["mobileNo"].stringValue
        countryCode = json["countryCode"].stringValue
        accessToken = json["accessToken"].stringValue
        refreshToken = json["refreshToken"].stringValue
        userName = json["userName"].stringValue
        userType = json["userType"].stringValue
        AppUserDefaults.save(value: json["isCelebrity"].boolValue, forKey: .isCelibrity)
        registeredUsing = json["registeredUsing"].intValue
        AppUserDefaults.save(value: profilePicture, forKey: .profilePicture)
        AppUserDefaults.save(value: json["email"].stringValue, forKey: .email)
    }
    
    func saveToUserDefaults() {
        
        let dict: JSONDictionary = [ApiKey.email:email,
                                    ApiKey.refreshToken:refreshToken,
                                    "accessToken":accessToken,
                                    "userId":userId,
                                    "firstName":firstName,
                                    "lastName":lastName,
                                    "profilePicture":profilePicture,
                                    "isMobileVerified":isMobileVerified,
                                    "isEmailVerified":isEmailVerified,
                                    "mobileNo":mobileNo,
                                    "countryCode":countryCode,
                                    "userType":userType,
                                    "userName":userName,
                                    "isGuestAccount":isGuestAccount,
                                    "registeredUsing":registeredUsing]
        
        AppUserDefaults.save(value: dict, forKey: .fullUserProfile)
    }
}

