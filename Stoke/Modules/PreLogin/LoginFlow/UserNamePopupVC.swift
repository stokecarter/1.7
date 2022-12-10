//
//  UserNamePopupVC.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import UIKit

enum SignupType{
    case facebook
    case apple
    case google
    
    var val:String{
        switch self {
        case .facebook: return "Facebook"
        case .google: return "Google"
        default: return "Apple"
        }
    }
}

class UserNamePopupVC: BaseVC {
    
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subHeadingLabel: UILabel!
    @IBOutlet weak var usernameTF: AppTextField!
    @IBOutlet weak var continuewBtn: AppButton!
    
    var viewModel:SocialSignupVM!
    var fbModel:FacebookModel!
    var googlemodel:GoogleUser!
    var appleModel:AppleModel!
    
    var enabledBtn:Bool = false{
        didSet{
            if enabledBtn{
                continuewBtn.alpha = 1.0
                continuewBtn.isEnabled = true
            }else{
                continuewBtn.alpha = 0.6
                continuewBtn.isEnabled = false
            }
        }
        
    }
    
    var type:SignupType = .facebook
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initalSetup() {
        enabledBtn  = false
        viewModel = SocialSignupVM(NetworkLayer(), type: type)
        switch type {
        case .facebook: viewModel.fbmodel = fbModel
        case .google: viewModel.googlemodel = googlemodel
        default: viewModel.appleModel = appleModel
        }
        usernameTF.setupAs = .userName
        continuewBtn.btnType = .themeColor
        usernameTF.editingBegain = {[weak self] in
            self?.usernameTF.startAnimating = false
            
        }
        usernameTF.editingEnd = { [weak self] in
            if let un = self?.usernameTF.text, !un.isEmpty{
                self?.enabledBtn = !(self?.usernameTF.text ?? "").isEmpty
                self?.usernameTF.startAnimating = true
                self?.viewModel.userName = self?.usernameTF.text ?? ""
                self?.usernameTF.isUserInteractionEnabled = false
            }
        }
        viewModel.verified = { [weak self] (flag,msg) in
            if !flag{
                CommonFunctions.showToastWithMessage(msg)
            }
            self?.usernameTF.startAnimating = false
            self?.usernameTF.isUserInteractionEnabled = true
        }
    }
    
    override func setupFounts() {
        headingLabel.font = AppFonts.Medium.withSize(18)
        subHeadingLabel.font = AppFonts.Regular.withSize(16)
        subHeadingLabel.textColor = AppColors.labelColor
        headingLabel.textColor = #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
        subHeadingLabel.text = "You have successfully registered using \(type.val). Please enter a username to continue."
    }
    
    @IBAction func continuewTapped(_ sender: Any) {
        view.endEditing(true)
        guard CommonFunctions.checkForInternet() else { return }
        if viewModel.userName.isEmpty{
            CommonFunctions.showToastWithMessage("Please entet the user name")
            return
        }else if !viewModel.validateUsername() {
            CommonFunctions.showToastWithMessage("Please entet a valid user name")
            return
        }else{
            viewModel.hitSocail()
        }
    }
    
}
