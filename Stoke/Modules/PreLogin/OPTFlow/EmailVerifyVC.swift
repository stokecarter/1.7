//
//  EmailVerifyVC.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import UIKit

class EmailVerifyVC: BaseVC {
    
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet var subHeadinglabel: UILabel!
    @IBOutlet weak var emailTF: AppTextField!
    @IBOutlet weak var verifyBtn: AppButton!
    @IBOutlet weak var changeToPhoneLbs: UILabel!
    var tapableRange1:NSRange!
    var viewModel:SignupVM!
    var enableBtn:Bool = false {
        didSet{
            if enableBtn{
                verifyBtn.alpha = 1.0
                verifyBtn.isEnabled = true
            }else{
                verifyBtn.alpha = 0.6
                verifyBtn.isEnabled = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setWhiteNavigationBar(title: "", backButton: true, showTextOnRightBtn: "2/2")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initalSetup() {
        enableBtn = false
        emailTF.setupAs = .email
        verifyBtn.btnType = .themeColor
        viewModel.showEmailVerifyPopup = { [weak self] in
            guard let self = self else { return }
            self.presentPopupView()
        }
        emailTF.editingChange = { [weak self] in
            self?.enableBtn = !(self?.emailTF.text ?? "").isEmpty
        }
        setUpActiveLabel()
    }
    
    
    private func setUpActiveLabel(){
        
        let customType1    = "Phone Number"
        let text           = "Verify via Phone Number"
        changeToPhoneLbs.attributedText = attributedText(withString: text, boldString1: customType1, font: AppFonts.Regular.withSize(16))
    }
    
    private func attributedText(withString string: String, boldString1: String,font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:AppColors.labelColor])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Medium.withSize(16),NSAttributedString.Key.foregroundColor:AppColors.themeColor]
        tapableRange1 = (string as NSString).range(of: boldString1)
        attributedString.addAttributes(boldFontAttribute, range: tapableRange1)
        changeToPhoneLbs.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(_:)))
        changeToPhoneLbs.addGestureRecognizer(tap)
        return attributedString
    }
    
    @objc func tapLabel(_ gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: changeToPhoneLbs, inRange: tapableRange1) {
            pop()
        } else{
            printDebug("Tapped none")
        }
    }
    
    override func setupFounts() {
        headingLabel.font = AppFonts.Medium.withSize(18)
        subHeadinglabel.font = AppFonts.Regular.withSize(16)
        subHeadinglabel.textColor = AppColors.labelColor
    }
    
    @objc func goToPhone(_ sender: Any) {
        pop()
    }
    
    @IBAction func goToOtp(_ sender: Any) {
        viewModel.email = emailTF.text ?? ""
        viewModel.type = .email
        guard viewModel.validateEmail() else { return }
        viewModel.hitForSignup()
        
    }
    
    private func presentPopupView(){
        CommonFunctions.showToastWithMessage("Verification email sent.", theme: .success)
        CommonFunctions.isFromSignUp = true
        AppRouter.goToHome()
//        let vc = SignupSucessVC.instantiate(fromAppStoryboard: .Main)
//        vc.delegate = self
//        vc.modalTransitionStyle = .crossDissolve
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: false, completion: nil)
    }
}

extension EmailVerifyVC : SignupSucessDelegate {
    func okTapped() {
        CommonFunctions.isFromSignUp = true
        AppRouter.goToHome()
    }
}
