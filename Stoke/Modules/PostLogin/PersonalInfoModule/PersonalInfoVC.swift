//
//  PersonalInfoVC.swift
//  Stoke
//
//  Created by Admin on 28/05/21.
//

import UIKit

class PersonalInfoVC: BaseVC {
    
    
    @IBOutlet weak var emailFieldView: UIView!
    @IBOutlet weak var phoneFieldView: UIView!
    @IBOutlet weak var emailbtn: UIButton!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var emailVerificationStatusIcon: UIImageView!
    @IBOutlet weak var phoneVerificationStatusIcon: UIImageView!
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var emailVerifyBtn: UIButton!
    @IBOutlet weak var phoneverifyBtn: UIButton!
    @IBOutlet weak var emailOptonBtn: UIButton!
    @IBOutlet weak var phoneOptionBtn: UIButton!
    
    var model:UserProfileModel!
    var viewModel:PersonalInfoVM!
    
    var emailVerified:Bool = false{
        didSet{
            emailVerificationStatusIcon.isHidden = false
            if !emailVerified{
                emailVerificationStatusIcon.image = #imageLiteral(resourceName: "ic_login_successful-1")
            }else{
                emailVerificationStatusIcon.image = #imageLiteral(resourceName: "ic-check-active")
            }
        }
    }
    
    var phoneVerified:Bool = false{
        didSet{
            phoneVerificationStatusIcon.isHidden = false
            if !phoneVerified{
                phoneVerificationStatusIcon.image = #imageLiteral(resourceName: "ic_login_successful-1")
            }else{
                phoneVerificationStatusIcon.image = #imageLiteral(resourceName: "ic-check-active")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModel = PersonalInfoVM(NetworkLayer(), model: model)
        viewModel.update = { [weak self] in
            self?.model = self?.viewModel.model
            self?.setupView()
        }
        setNavigationBar(title: "Personal Information", backButton: true)
        [emailVerifyBtn,phoneverifyBtn].forEach {
            $0?.titleLabel?.font = AppFonts.Medium.withSize(14)
            $0?.setTitleColor(AppColors.themeColor, for: .normal)
        }
        [phoneTf,emailTf].forEach {
            $0?.isUserInteractionEnabled = false
        }
        emailbtn.setImage(#imageLiteral(resourceName: "ic_email_inactive"), for: .normal)
        emailbtn.setImage(#imageLiteral(resourceName: "ic_email_active"), for: .selected)
        phoneBtn.setImage(#imageLiteral(resourceName: "ic_phone_number_inactive"), for: .normal)
        phoneBtn.setImage(#imageLiteral(resourceName: "ic_phone_number_active"), for: .selected)
        emailOptonBtn.addTarget(self, action: #selector(updateEmail), for: .touchUpInside)
        phoneOptionBtn.addTarget(self, action: #selector(updatePhone), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = viewModel{
            viewModel.getProfile()
        }
    }
    
    @objc func updateEmail(){
        if model.isEmailVerified{
            goToUpdateScreen(true)
        }else{
            if model.email.isEmpty{
                goToUpdateScreen(true)
            }else{
                showEmailVerification()
            }
        }
    }
    
    @objc func updatePhone(){
        if model.isMobileVerified{
            goToUpdateScreen(false)
        }else{
            if model.mobileNo.isEmpty{
                goToUpdateScreen(false)
            }else{
                showMobileVerification()
            }
        }
    }
    
    private func goToUpdateScreen(_ viaEmail:Bool){
        let vc = UpdateDetailsVC.instantiate(fromAppStoryboard: .Events)
        vc.isEmail = viaEmail
        vc.viewModel = viewModel
        AppRouter.pushFromTabbar(vc,true)
    }
    
    private func showEmailVerification(){
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegate = self
        vc.isForDelete = true
        vc.headingText = ""
        vc.subheadingTxt = "The email address entered is not yet verified. Resend verification email or update your email address."
        vc.firstbtnTitle = "Update"
        vc.secondbtnTitle = "Resend"
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    private func showMobileVerification(){
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegate = self
        vc.isForDelete = false
        vc.headingText = ""
        vc.subheadingTxt = "This phone number is not verified. Verify phone number or update your phone number."
        vc.firstbtnTitle = "Update"
        vc.secondbtnTitle = "Resend"
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    
    
    private func setupView(){
        if model.isEmailVerified{
            emailTf.text = model.email
            emailFieldView.setBorderCurve(width: 1, color: #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1),corner: 10)
            emailVerifyBtn.setTitle("Update", for: .normal)
            emailVerified = true
            emailbtn.isSelected = true
        }else{
            if model.email.isEmpty{
                emailTf.text = ""
                emailVerifyBtn.setTitle("Add", for: .normal)
                emailVerificationStatusIcon.isHidden = true
                emailbtn.isSelected = false
                emailFieldView.setBorderCurve(width: 1, color: #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1),corner: 10)
            }else{
                emailTf.text = model.email
                emailVerifyBtn.setTitle("Resend", for: .normal)
                emailVerified = false
                emailbtn.isSelected = true
                emailFieldView.setBorderCurve(width: 1, color: #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1),corner: 10)
            }
            
        }
        if model.isMobileVerified{
            phoneTf.text = model.countryCode + " " + model.mobileNo
            phoneFieldView.setBorderCurve(width: 1, color:#colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1),corner: 10)
            phoneverifyBtn.setTitle("Update", for: .normal)
            phoneVerified = true
            phoneBtn.isSelected = true
        }else{
            if model.mobileNo.isEmpty{
                phoneTf.text = ""
                phoneverifyBtn.setTitle("Add", for: .normal)
                phoneVerificationStatusIcon.isHidden = true
                phoneBtn.isSelected = false
                phoneFieldView.setBorderCurve(width: 1, color: #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1),corner: 10)
            }else{
                phoneTf.text = model.countryCode + " " + model.mobileNo
                phoneverifyBtn.setTitle("Resend", for: .normal)
                phoneVerified = false
                phoneBtn.isSelected = true
                phoneFieldView.setBorderCurve(width: 1, color:#colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1),corner: 10)
            }
            
        }
    }
    
    private func presentPopupView(){
        CommonFunctions.showToastWithMessage("Verification email sent.", theme: .success)
//        let vc = SignupSucessVC.instantiate(fromAppStoryboard: .Main)
//        vc.delegate = self
//        vc.modalTransitionStyle = .crossDissolve
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: false, completion: nil)
    }
    
    private func gotoOtp(){
        let vc = OTPVc.instantiate(fromAppStoryboard: .Main)
        vc.mobile = viewModel.model.mobileNo.byRemovingLeadingTrailingWhiteSpaces
        vc.countryCode = "+1"
        vc.isfromSettings = true
        vc.userId = viewModel.model._id
        AppRouter.pushViewController(self, vc)
    }

}

extension PersonalInfoVC : SignupSucessDelegate {
    func okTapped() {
        printDebug("Do noting....")
    }
}

extension PersonalInfoVC : GenericPopupDelegate {
    
    func optionTapped(_ flag: Bool, isDelete: Bool, id: String) {
        if isDelete{
            if flag{
                viewModel.resendVerificaitionmale { [weak self] in
                    self?.presentPopupView()
                }
            }else{
                goToUpdateScreen(true)
            }
        }else{
            if flag{
                viewModel.resendOtp { [weak self] in
                    self?.gotoOtp()
                }
            }else{
                goToUpdateScreen(false)
            }
        }
    }
}
