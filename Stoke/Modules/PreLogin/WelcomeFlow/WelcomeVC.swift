//
//  WelcomeVC.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import UIKit

class WelcomeVC: BaseVC {

//    MARK:- IBOutlets
    
    @IBOutlet weak var signUpBtn: AppButton!
    @IBOutlet weak var loginBtn: AppButton!
    @IBOutlet weak var continueGuestBtn: UIButton!
    @IBOutlet weak var welcomeLabel:UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func initalSetup() {
        setWhiteNavigationBar(title: "", backButton: false, showTextOnRightBtn: "")
        signUpBtn.btnType = .themeColor
        loginBtn.btnType = .whiteColor
        
    }
    
    override func setupFounts() {
        welcomeLabel.font = AppFonts.Medium.withSize(18)
        setWhiteNavigationBar(title: "", backButton: false)
        continueGuestBtn.setTitle(" Explore as Guest", for: .normal)
        continueGuestBtn.titleLabel?.font = AppFonts.Medium.withSize(18)
        continueGuestBtn.setTitleColor(AppColors.themeColor, for: .normal)
        signUpBtn.setTitle("Sign Up", for: .normal)
        loginBtn.setTitle("Log In", for: .normal)
    }
    
//    MARK:- IBAction
    
    @IBAction func signupTapped(_ sender: Any) {
        let vc = SignUpVC.instantiate(fromAppStoryboard: .Main)
        AppRouter.pushViewController(self, vc)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        let vc = LoginVC.instantiate(fromAppStoryboard: .Main)
        AppRouter.pushViewController(self, vc)
        
    }
    
    @IBAction func guestTapped(_ sender: Any) {
        CommonFunctions.guestLogin()
    }
}
