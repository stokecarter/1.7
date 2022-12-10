//
//  Constants.swift
//  NewProject
//
//  Created by Harsh Vardhan Kushwaha on 30/08/18.
//  Copyright © 2018 Harsh Vardhan Kushwaha. All rights reserved.
//

import Foundation

enum LocalizedString : String {
    
    // MARK:- App Title
    //===================
    case appTitle = "NewProject"
    
    // MARK:- Screen Titles
    //=======================
    case login = "Login"
    case signUp = "SignUp"
    case changePassword = "ChangePassword"
    case forgotPassword = "ForgotPassword"
    
    //MARK:- SignupVC
    //===============
    case firstName = "FirstName"
    case middleName = "MiddleName"
    case lastName = "LastName"
    case userName = "UserName"
    case gender = "Gender"
    case male = "Male"
    case female = "Female"
    case other = "Other"
    
    case dateOfBirth = "DateOfBirth"
    case phoneNo = "PhoneNo"
    case city = "City"
    case countryCode = "CountryCode"
    case region = "Region"
    case longitude = "Longitude"
    case latitude = "Latitude"
    case postalCode = "PostalCode"
    case confirmPassword = "ConfirmPassword"
    case done = "Done"
    
    //MARK:- LoginVC
    //==============
    case ok = "Ok"
    case back = "Back"
    case emailAddress = "EmailAddress"
    case password = "Password"
    case logout = "Logout"
    
    //MARK:- ForgotPasswordVC
    //=======================
    case sendOTPToEmailAddress = "SendOTPToEmailAddress"
    case Continue = "Continue"
    
    //MARK:- ChangePasswordVC
    //=======================
    case oldPassword = "OldPassword"
    case newPassword = "NewPassword"
    
    //MARK:- CountryCodeVC
    //=======================
    case selectCountry = "SelectCountry"
    case searchCountry = "SearchCountry"
    
    //MARK:- ChangePasswordVC
    //=======================
    case enterNewPasswordForYourAccount = "EnterNewPasswordForYourAccount"
    
    // MARK :- Validations
    //======================

    // Email
    case enterEmail = "EnterEmail"
    case invalidEmail = "InvalidEmail"

    // First Name
    case enterFirstName = "EnterFirstName"
    case invalidFirstName = "InvalidFirstName"
    case firstNameInvalidLength = "FirstNameInvalidLength"

    // Middle Name
    case enterMiddleName = "EnterMiddleName"
    case invalidMiddleName = "InvalidMiddleName"
    case middleNameInvalidLength = "MiddleNameInvalidLength"
    
    // Last Name
    case enterLastName = "EnterLastName"
    case invalidLastName = "InvalidLastName"
    case lastNameInvalidLength = "LastNameInvalidLength"
    
    // Username
    case enterUsername = "EnterUsername"
    case invalidUsername = "InvalidUsername"
    case usernameInvalidLength = "UsernameInvalidLength"
    
    // Password
    case enterPassword = "EnterPassword"
    case passwordInvalidLength = "PasswordInvalidLength"
    
    // Confirm Password
    case enterConfirmPassword = "EnterConfirmPassword"
    case confirmPasswordWrong = "ConfirmPasswordWrong"
    
    // Old Password
    case enterOldPassword = "EnterOldPassword"
    case oldPasswordInvalidLength = "OldPasswordInvalidLength"
    case invalidOldPassword = "InvalidOldPassword"
    
    // New Password
    case enterNewPassword = "EnterNewPassword"
    case newPasswordInvalidLength = "NewPasswordInvalidLength"
    
    // Mobile Number
    case enterMobile = "EnterMobile"
    case mobileNumberInvalidLength = "MobileNumberInvalidLength"
    
    // Age Limit
    case minimumAgeLimit = "MinimumAgeLimit"
    case maximumAgeLimit = "MaximumAgeLimit"
    
    // City Name
    case enterCityName = "EnterCityName"
    case invalidCityName = "InvalidCityName"
    case cityNameInvalidLength = "CityNameInvalidLength"
    
    // Region Name
    case enterRegionName = "EnterRegionName"
    case invalidRegionName = "InvalidRegionName"
    case regionNameInvalidLength = "RegionNameInvalidLength"
    
    // Country Code
    case enterCountryCode = "EnterCountryCode"
    case invalidCountryCode = "InvalidCountryCode"
    
    // Biography
    case enterBiography = "EnterBiography"
    case biographyInvalidLength = "BiographyInvalidLength"
    
    // Something Went Wrong
    case somethingWentWrong = "SomethingWentWrong"

    // MARK :- No Internet
    //=====================
    case sorry = "Sorry"
    case pleaseTryAgain = "PleaseTryAgain"
    case pleaseCheckInternetConnection = "PleaseCheckInternetConnection"
    
    // MARK :- Random Keywords
    //===========================
    case success = "Success"
    case successfullySaved = "SuccessfullySaved"
    case error = "Error"
    case underDevelopment = "UnderDevelopment"
    
    //MARK:- UIViewController Extension
    //=================================
    case chooseOptions = "ChooseOptions"
    case camera = "Camera"
    case cameraNotAvailable = "CameraNotAvailable"
    case chooseImage = "ChooseImage"
    case chooseFromGallery = "ChooseFromGallery"
    case takePhoto = "TakePhoto"
    case cancel = "Cancel"
    case alert = "Alert"
    case settings = "Settings"
    case restrictedFromUsingCamera = "RestrictedFromUsingCamera"
    case changePrivacySettingAndAllowAccessToCamera = "ChangePrivacySettingAndAllowAccessToCamera"
    case restrictedFromUsingLibrary = "RestrictedFromUsingLibrary"
    case changePrivacySettingAndAllowAccessToLibrary = "ChangePrivacySettingAndAllowAccessToLibrary"
}


extension LocalizedString {
    var localized : String {
        return self.rawValue.localized
    }
}
