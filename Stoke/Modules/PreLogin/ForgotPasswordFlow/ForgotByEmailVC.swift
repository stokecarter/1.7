//
//  ForgotByEmailVC.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import UIKit

class ForgotByEmailVC: BaseVC {
    
    @IBOutlet weak var headingLabel:UILabel!
    @IBOutlet weak var subHeadingLabel:UILabel!
    @IBOutlet weak var emailTF: AppTextField!
    @IBOutlet weak var sendBtn: AppButton!
    @IBOutlet weak var backToLogin: AppButton!
    @IBOutlet weak var changeToPhoneLabel:UILabel!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setWhiteNavigationBar(title: "", backButton: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWhiteNavigationBar(title: "", backButton: true)

    }
    
    override func initalSetup() {
        enableBtn = false
        viewModel = ForgotPassword(NetworkLayer())
        viewModel.resetBy = .email
        emailTF.setupAs = .email
        sendBtn.btnType = .themeColor
        backToLogin.btnType = .whiteColor
        emailTF.editingChange = { [weak self] in
            self?.enableBtn = !(self?.emailTF.text ?? "").isEmpty
        }
        viewModel.showEmailSucess = { [weak self] msg in
            CommonFunctions.showToastWithMessage("Password reset link sent to your email.", theme: .success)
            AppRouter.goToLoginScreen()
//            let vc = SignupSucessVC.instantiate(fromAppStoryboard: .Main)
//            vc.delegate = self
//            vc.isFromSignup = false
//            vc.msg = msg
//            vc.modalTransitionStyle = .crossDissolve
//            vc.modalPresentationStyle = .overFullScreen
//            self?.present(vc, animated: false, completion: nil)
        }
        setUpActiveLabel()

    }
    
    override func setupFounts() {
        headingLabel.font = AppFonts.Medium.withSize(18)
        subHeadingLabel.font = AppFonts.Regular.withSize(16)
        subHeadingLabel.textColor = AppColors.labelColor
    }
    
    private func setUpActiveLabel(){
        
        let customType1    = "Phone Number"
        let text           = "Reset Password via Phone Number"
        changeToPhoneLabel.attributedText = attributedText(withString: text, boldString1: customType1, font: AppFonts.Regular.withSize(16))
    }
    
    private func attributedText(withString string: String, boldString1: String,font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:AppColors.labelColor])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Medium.withSize(16),NSAttributedString.Key.foregroundColor:AppColors.themeColor]
        tapableRange1 = (string as NSString).range(of: boldString1)
        attributedString.addAttributes(boldFontAttribute, range: tapableRange1)
        changeToPhoneLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(_:)))
        changeToPhoneLabel.addGestureRecognizer(tap)
        return attributedString
    }
    
    @objc func tapLabel(_ gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: changeToPhoneLabel, inRange: tapableRange1) {
            pop()
        } else{
            printDebug("Tapped none")
        }
    }
    
    
   
    @IBAction func sendBtnAction(_ sender: Any) {
        view.endEditing(true)
        guard CommonFunctions.checkForInternet() else { return }
        viewModel.email = emailTF.text ?? ""
        guard viewModel.validateEmail() else { return }
        viewModel.hitResetPassword()
    }
    
    @IBAction func backToLoginBtn(_ sender: Any) {
        AppRouter.goToLoginScreen()
        
    }
    
}


extension ForgotByEmailVC : SignupSucessDelegate {
    func okTapped() {
        AppRouter.goToLoginScreen()
    }
}
