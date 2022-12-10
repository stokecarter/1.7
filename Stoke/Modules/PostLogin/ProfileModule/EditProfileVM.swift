//
//  EditProfileVM.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import Foundation
import UIKit



class EditProfileVM{
    
    private let web:NetworkLayer!

    var fullName:String = ""{
        didSet{
            firstName = fullName.byRemovingLeadingTrailingWhiteSpaces.components(separatedBy: " ").first ?? ""
            lastName = fullName.byRemovingLeadingTrailingWhiteSpaces.components(separatedBy: " ").last ?? ""
        }
    }
    
    var verified:((Bool,String)->())?
    var dummyImage = UIImage()
    var isUploading = false
    var firstName:String = ""
    var lastName:String = ""
    var profilePicture:String = ""
    var userName:String = ""
    var location:String = ""
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var bio:String = ""
    var isHideEngagementStats:Bool = false
    var isPrivateAccount:Bool = false
    var isUsernamevailable = true
    var editSuccess:(()->())?
    
    init(_ web:NetworkLayer,u:UserProfileModel){
        self.web = web
        fullName = u.fullName
        firstName = u.firstName
        lastName = u.lastName
        profilePicture = u.profilePicture
        userName = u.userName
        location = u.location.address
        latitude = u.location.latitude
        longitude = u.location.longitude
        bio = u.bio
        isHideEngagementStats = u.isHideEngagementStats
        isPrivateAccount = u.isPrivateAccount
    }
    
    func validateUsername() -> Bool{
        if userName.isEmpty{
            CommonFunctions.showToastWithMessage("Please enter a valid username")
            return false
        }else if userName.count < 3{
            CommonFunctions.showToastWithMessage("Username must have at-least 3 characters")
            return false
        }else if userName.count > 30{
            CommonFunctions.showToastWithMessage("Username can not be grater than 30 characters")
            return false
        }else if userName.checkIfInvalid(.userName){
            CommonFunctions.showToastWithMessage("Username must not only contain digits and avoid using @")
            return false
        }else{
            return true
        }
    }
    
    func verifyUsername(){
        guard validateUsername() else {
            if let verify = verified { verify(true,"") }
            return }
        guard CommonFunctions.checkForInternet() else {
            if let verify = verified { verify(true,"") }
            return }
        let param:JSONDictionary = ["userName":userName,"userId":UserModel.main.userId]
        web.request(from: WebService.username, param: param, method: .POST, header: [:],loader:false) { [weak self] (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    self?.isUsernamevailable = json[ApiKey.code].intValue == 200
                    let msg = json[ApiKey.message].stringValue
                    if let verify = self?.verified { verify(self?.isUsernamevailable ?? false,msg) }
                } failure: { (e) in
                    self?.isUsernamevailable = false
                    if let verify = self?.verified { verify(true,"") }
                }
            }
        }
    }
    
    
    func hitUpdateProfile(){
        if !isUsernamevailable{
            CommonFunctions.showToastWithMessage("Username is already taken.")
            return
        }
        let param:JSONDictionary = [
            "firstName": firstName,
            "lastName": lastName == firstName ? "" : lastName,
            "profilePicture": profilePicture,
            "userName": userName,
            "location": "India",
            "latitude": 28.366363,
            "longitude": 78.32424,
            "bio": bio,
            "isHideEngagementStats": isHideEngagementStats,
            "isPrivateAccount": isPrivateAccount
        ]
        web.request(from: WebService.userProfile, param: param, method: .PUT, header: [:], loader: true) { (data, err) in
            guard let d = data  else { CommonFunctions.showToastWithMessage(err?.localizedDescription ?? "")
                return
            }
            Parser.shared.getJSONData(data: d) { [weak self](json) in
                CommonFunctions.showToastWithMessage(json[ApiKey.message].stringValue, theme: .success)
                if let s = self?.editSuccess { s()}
                printDebug(json)
            } failure: { (e) in
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }
        }
    }
    
}
