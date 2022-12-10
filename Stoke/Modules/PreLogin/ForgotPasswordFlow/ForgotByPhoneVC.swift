//
//  ForgotByPhoneVC.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import UIKit

class ForgotByPhoneVC: BaseVC {
    
    
    
    @IBOutlet weak var headingLabel:UILabel!
    @IBOutlet weak var subHeadingLabel:UILabel!
    @IBOutlet weak var phoneTF: AppTextField!
    @IBOutlet weak var sendBtn: AppButton!
    @IBOutlet weak var backToLogin: AppButton!
    @IBOutlet weak var changeToEmailLabel:UILabel!
    
    var tapableRange1:NSRange!
    var viewModel:ForgotPassword!
    var enableBtn:Bool = false {
        didSet{
            if enableBtn{
                sendBtn.alpha = 1.0
                sendBtn.isEnabled = true
            }else{
                sendBtn.alpha = 0.6
                sendBtn.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setWhiteNavigationBar(title: "", backButton: true)
    }
    
    override func initalSetup() {
        enableBtn = false
        viewModel = ForgotPassword(NetworkLayer())
        viewModel.resetBy = .phone
        phoneTF.setupAs = .phone
        sendBtn.btnType = .themeColor
        backToLogin.btnType = .whiteColor
        phoneTF.editingChange = { [weak self] in
            self?.enableBtn = !(self?.phoneTF.text ?? "").isEmpty
        }
        viewModel.goToOtpSccreen = { [weak self] userID in
            guard let self = self else { return }
            let vc = OTPVc.instantiate(fromAppStoryboard: .Main)
            vc.isResetPwd = true
            vc.mobile = self.phoneTF.text ?? ""
            vc.countryCode = "+1"
            vc.userId = userID
            AppRouter.pushViewController(self, vc)
        }
    }
    
    override func setupFounts() {
        headingLabel.font = AppFonts.Medium.withSize(18)
        subHeadingLabel.font = AppFonts.Regular.withSize(16)
        subHeadingLabel.textColor = AppColors.labelColor
        setUpActiveLabel()
    }
    
    private func setUpActiveLabel(){
        
        let customType1    = "Email"
        let text           = "Reset Password via Email"
        changeToEmailLabel.attributedText = attributedText(withString: text, boldString1: customType1, font: AppFonts.Regular.withSize(16))
    }
    
    private func attributedText(withString string: String, boldString1: String,font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:AppColors.labelColor])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Medium.withSize(16),NSAttributedString.Key.foregroundColor:AppColors.themeColor]
        tapableRange1 = (string as NSString).range(of: boldString1)
        attributedString.addAttributes(boldFontAttribute, range: tapableRange1)
        changeToEmailLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(_:)))
        changeToEmailLabel.addGestureRecognizer(tap)
        return attributedString
    }
    
    @objc func tapLabel(_ gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: changeToEmailLabel, inRange: tapableRange1) {
            let vc = ForgotByEmailVC.instantiate(fromAppStoryboard: .Main)
            AppRouter.pushViewController(self, vc)
        } else{
            printDebug("Tapped none")
        }
    }
    
    @IBAction func sendBtnAction(_ sender: Any) {
        viewModel.phone = phoneTF.text ?? ""
        guard viewModel.validatePhone() else {
            return
        }
        view.endEditing(true)
        guard CommonFunctions.checkForInternet() else { return }
        viewModel.hitResetPassword()
    }
    
    @IBAction func backToLoginBtn(_ sender: Any) {
        AppRouter.goToLoginScreen()
    }
    
}

