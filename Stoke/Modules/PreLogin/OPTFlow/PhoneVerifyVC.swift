//
//  PhoneVerifyVC.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import UIKit

class PhoneVerifyVC: BaseVC {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet var subHeadinglabel: UILabel!
    @IBOutlet weak var phone: AppTextField!
    @IBOutlet weak var verifyBtn: AppButton!
    @IBOutlet weak var changeToEmailLbl: UILabel!
    
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
        phone.setupAs = .phone
        verifyBtn.btnType = .themeColor
        viewModel.proceedToOtp = { [weak self] mobile in
            guard let self = self else { return }
            let vc = OTPVc.instantiate(fromAppStoryboard: .Main)
            vc.mobile = mobile
            vc.countryCode = "+1"
            vc.userId = UserModel.main.userId
            AppRouter.pushViewController(self, vc)
        }
        
        phone.editingChange = { [weak self] in
            self?.enableBtn = !(self?.phone.text ?? "").isEmpty
            
        }
        setUpActiveLabel()
    }
    
    override func setupFounts() {
        headingLabel.font = AppFonts.Medium.withSize(18)
        subHeadinglabel.font = AppFonts.Regular.withSize(16)
        subHeadinglabel.textColor = AppColors.labelColor
    }
    
    private func setUpActiveLabel(){
        
        let customType1    = "Email"
        let text           = "Verify via Email"
        changeToEmailLbl.attributedText = attributedText(withString: text, boldString1: customType1, font: AppFonts.Regular.withSize(16))
    }
    
    private func attributedText(withString string: String, boldString1: String,font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:AppColors.labelColor])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Medium.withSize(16),NSAttributedString.Key.foregroundColor:AppColors.themeColor]
        tapableRange1 = (string as NSString).range(of: boldString1)
        attributedString.addAttributes(boldFontAttribute, range: tapableRange1)
        changeToEmailLbl.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(_:)))
        changeToEmailLbl.addGestureRecognizer(tap)
        return attributedString
    }
    
    @objc func tapLabel(_ gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: changeToEmailLbl, inRange: tapableRange1) {
            let vc = EmailVerifyVC.instantiate(fromAppStoryboard: .Main)
            vc.viewModel = viewModel
            AppRouter.pushViewController(self, vc)
        } else{
            printDebug("Tapped none")
        }
    }
    
    
    @IBAction func goToOtp(_ sender: Any) {
        viewModel.phoneNo = phone.text ?? ""
        viewModel.type = .phone
        guard viewModel.validatePhone() else { return }
        viewModel.hitForSignup()

    }
}

