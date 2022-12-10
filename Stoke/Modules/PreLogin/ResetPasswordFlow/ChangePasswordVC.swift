//
//  ChangePasswordVC.swift
//  Stoke
//
//  Created by Admin on 27/02/21.
//

import UIKit
import SwiftyJSON


class ChangePasswordVC: BaseVC {
    
    
    @IBOutlet weak var newPwdTF: AppTextField!
    @IBOutlet weak var cnfPwdTF: AppTextField!
    @IBOutlet weak var savePassword: AppButton!
    
    @IBOutlet weak var subHeadingLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    
    var enableBtn:Bool = false {
        didSet{
            if enableBtn{
                savePassword.alpha = 1.0
                savePassword.isEnabled = true
            }else{
                savePassword.alpha = 0.6
                savePassword.isEnabled = false
            }
        }
    }
    
    var token:String = ""
    var isEmail:Bool = true
    var password = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setWhiteNavigationBar(title: "", backButton: true)
    }
    
    
    override func initalSetup() {
        enableBtn = false
        newPwdTF.setupAs = .password
        cnfPwdTF.setupAs = .password
        newPwdTF.placeholder = "New Password"
        cnfPwdTF.placeholder = "Confirm Password"
        newPwdTF.editingChange = { [weak self] in
            self?.checkForBtn()
        }
        cnfPwdTF.editingChange = { [weak self] in
            self?.checkForBtn()
        }
    }
    
    override func setupFounts() {
        headingLabel.font = AppFonts.Medium.withSize(18)
        subHeadingLabel.font = AppFonts.Regular.withSize(16)
        subHeadingLabel.textColor = AppColors.labelColor
    }
    
    override func backButtonTapped() {
        AppRouter.goToLoginScreen()
    }
    
    
    @IBAction func savePassword(_ sender: Any) {
        view.endEditing(true)
        guard CommonFunctions.checkForInternet() else { return }
        guard validate() else { return }
        password = newPwdTF.text ?? ""
        hitApi()
    }
    
    func validate() -> Bool{
        guard let text1 = newPwdTF.text, let text2 =  cnfPwdTF.text else { return false}
        if text1.isEmpty{
            CommonFunctions.showToastWithMessage("Please enter the password")
            return false
        }else if text1.count < 8{
            CommonFunctions.showToastWithMessage("Password must be of 8 characters")
            return false
        }else if text1 != text2 {
            CommonFunctions.showToastWithMessage(" Confirm password is not matched ")
            return false
        }else{
            return true
        }
        
    }
    
    private func sucess(){
        CommonFunctions.showToastWithMessage("Password reset successfully. Log In to continue.", theme: .success)
        AppRouter.goToLoginScreen()
//        let vc = SignupSucessVC.instantiate(fromAppStoryboard: .Main)
//        vc.delegate = self
//        vc.isFromSignup = true
//        vc.modalTransitionStyle = .crossDissolve
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: false, completion: nil)
    }

    private func checkForBtn(){
        enableBtn = !(self.newPwdTF.text ?? "").isEmpty && !(self.cnfPwdTF.text ?? "").isEmpty
    }
    
    
    func hitApi(){
        let param:JSONDictionary = ["type":isEmail ? "email" : "mobile",
                                    "accessToken":token,
                                    "password":password]
        NetworkLayer().request(from: WebService.resetPassword, param: param, method: .POST, header: [:]) { (data, error) in
            if let e = error{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                if let d = data{
                    Parser.shared.getJSONData(data: d) { (json) in
                        DispatchQueue.main.async { [weak self] in
                            self?.sucess()
                        }
                    } failure: { (e) in
                        CommonFunctions.showToastWithMessage(e.localizedDescription)
                    }
                }
            }
        }
    }
}

extension ChangePasswordVC : SignupSucessDelegate {
    func okTapped() {
        AppRouter.goToLoginScreen()
    }
}


