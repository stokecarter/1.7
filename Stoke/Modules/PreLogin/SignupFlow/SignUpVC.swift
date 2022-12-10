//
//  SignUpVC.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import UIKit
import GoogleSignIn

class SignUpVC: BaseVC {
    
    
    @IBOutlet weak var usernameTF: AppTextField!
    @IBOutlet weak var passwordTF: AppTextField!
    @IBOutlet weak var nextBtn: AppButton!
    @IBOutlet weak var guestBtn: AppButton!
    @IBOutlet weak var appleBtn: AppButton!
    @IBOutlet weak var googleBtn: AppButton!
    @IBOutlet weak var fbBtn: AppButton!
    @IBOutlet weak var tnclable: UILabel!
    @IBOutlet weak var signlabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    
    var isRoot = false
    
    
    var tncRange,loginRange:NSRange!
    var viewModel:SignupVM!
    var enabledBtn:Bool = false{
        didSet{
            if enabledBtn{
                nextBtn.alpha = 1.0
                nextBtn.isEnabled = true
            }else{
                nextBtn.alpha = 0.6
                nextBtn.isEnabled = false
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setWhiteNavigationBar(title: "", backButton: true, showTextOnRightBtn: "1/2")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpActiveLabel()
    }
    
    override func initalSetup() {
        enabledBtn = false
        viewModel = SignupVM(NetworkLayer())
        usernameTF.setupAs = .userName
        passwordTF.setupAs = .password
        nextBtn.btnType = .themeColor
        fbBtn.btnType = .facebook
        googleBtn.btnType = .google
        appleBtn.btnType = .apple
        guestBtn.btnType = .noborder
        usernameTF.editingChange = { [weak self] in
            self?.checkForBtn()
        }
        passwordTF.editingChange = { [weak self] in
            self?.checkForBtn()
        }
        usernameTF.editingBegain = {[weak self] in
            self?.usernameTF.startAnimating = false
            
        }
        usernameTF.editingEnd = { [weak self] in
            if let un = self?.usernameTF.text, !un.isEmpty{
                self?.usernameTF.startAnimating = true
                self?.viewModel.userName = self?.usernameTF.text ?? ""
                self?.usernameTF.isUserInteractionEnabled = false
                self?.checkForBtn()
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
        signlabel.font = AppFonts.Regular.withSize(16)
        signlabel.textColor = AppColors.labelColor
        guestBtn.setTitle("Explore as Guest", for: .normal)
        nextBtn.setTitle("Sign Up", for: .normal)
        fbBtn.setTitle("Sign up with Facebook", for: .normal)
        googleBtn.setTitle("Sign up with Google", for: .normal)
        appleBtn.setTitle("Sign up with Apple", for: .normal)
        
    }
    
    override func backButtonTapped() {
        if isRoot{
            AppRouter.goToWelcomeScreen()
        }else{
            pop()
        }
    }
    
    
    private func checkForBtn(){
        self.enabledBtn = !(self.usernameTF.text ?? "").isEmpty && !(self.passwordTF.text ?? "").isEmpty
    }
    
    private func setUpActiveLabel(){
        
        let loginType    = "Log In"
        let text1        = "Already have an account? Log In"
        let tncType      = "Terms of Service"
        let text         = "By clicking next you agree to our Terms of Service"
        tnclable.attributedText = attributedText(withString: text, boldString1: tncType, font: AppFonts.Regular.withSize(12))
        loginLabel.attributedText = attributedTextLogin(withString: text1, boldString1: loginType, font: AppFonts.Regular.withSize(16))
    }
    
    private func attributedTextLogin(withString string: String, boldString1: String,font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:AppColors.labelColor])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Medium.withSize(16),NSAttributedString.Key.foregroundColor:AppColors.themeColor]
        loginRange = (string as NSString).range(of: boldString1)
        attributedString.addAttributes(boldFontAttribute, range: loginRange)
        loginLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabelLogin(_:)))
        loginLabel.addGestureRecognizer(tap)
        return attributedString
    }
    
    private func attributedText(withString string: String, boldString1: String,font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:AppColors.labelColor])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Regular.withSize(12),NSAttributedString.Key.foregroundColor:AppColors.appDarkGray,
                                                                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        tncRange = (string as NSString).range(of: boldString1)
        attributedString.addAttributes(boldFontAttribute, range: tncRange)
        tnclable.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(_:)))
        tnclable.addGestureRecognizer(tap)
        return attributedString
    }

    
    @objc func tapLabel(_ gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: tnclable, inRange: tncRange) {
            let vc = StaticWebKitVC.instantiate(fromAppStoryboard: .Events)
            vc.heading = "Terms of Service"
            vc.type = .tnc
            AppRouter.pushViewController(self, vc)
        }else{
            printDebug("Do nothing...")
        }
    }
    @objc func tapLabelLogin(_ gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: loginLabel, inRange: loginRange) {
            goToLogin()
        }else{
            printDebug("Do nothing...")
        }
    }
    
    
    @IBAction func nextTapped(_ sender: Any) {
        view.endEditing(true)
        guard CommonFunctions.checkForInternet() else { return }
        viewModel.password = passwordTF.text ?? ""
        guard viewModel.vaildatePageOne() else{ return }
        let vc = PhoneVerifyVC.instantiate(fromAppStoryboard: .Main)
        vc.viewModel = self.viewModel
        AppRouter.pushViewController(self, vc)
    }
    
    @IBAction func fbTapped(_ sender: Any) {
        view.endEditing(true)
        guard CommonFunctions.checkForInternet() else { return }
        FacebookController.shared.getFacebookUserInfo(fromViewController: self, success: { (model) in
            self.viewModel.checkFBUser(model) { (flag) in
                if flag{
                    let vm = SocialSignupVM(NetworkLayer(), type: .facebook)
                    vm.fbmodel = model
                    vm.hitSocail(true)
                }else{
                    let vc = UserNamePopupVC.instantiate(fromAppStoryboard: .Main)
                    vc.modalTransitionStyle = .coverVertical
                    vc.fbModel = model
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                
            }
        }) { (e) in
            printDebug(e?.localizedDescription)
        }
    }
    @IBAction func googleTapped(_ sender: Any) {
        view.endEditing(true)
        guard CommonFunctions.checkForInternet() else { return }
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GoogleLoginController.shared.login(fromViewController: self, success: { (model) in
            self.viewModel.checkGoogleUser(model) { (flag) in
                if flag{
                    let vm = SocialSignupVM(NetworkLayer(), type: .facebook)
                    vm.googlemodel = model
                    vm.type = .google
                    vm.hitSocail(true)
                }else{
                    let vc = UserNamePopupVC.instantiate(fromAppStoryboard: .Main)
                    vc.modalTransitionStyle = .coverVertical
                    vc.googlemodel = model
                    vc.type = .google
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }) { (e) in
            printDebug(e.localizedDescription)
        }
    }
    @IBAction func appleTapped(_ sender: Any) {
        AppleController.shared.handelAuthentication()
        AppleController.shared.gettingData = { [weak self] model in
            self?.viewModel.checkAppleUser(model) { (flag) in
                if flag{
                    let vm = SocialSignupVM(NetworkLayer(), type: .facebook)
                    vm.appleModel = model
                    vm.type = .apple
                    vm.hitSocail(true)
                }else{
                    let vc = UserNamePopupVC.instantiate(fromAppStoryboard: .Main)
                    vc.modalTransitionStyle = .coverVertical
                    vc.appleModel = model
                    vc.type = .apple
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: true, completion: nil)
                }
            }
        }
        
    }
    @IBAction func guestTapped(_ sender: Any) {
        view.endEditing(true)
        guard CommonFunctions.checkForInternet() else { return }
        CommonFunctions.guestLogin()
    }
    
    private func goToLogin(){
        var flag = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                flag.toggle()
                self.navigationController!.popToViewController(controller, animated: true)
                return
            }
        }
        if !flag{
            let vc = LoginVC.instantiate(fromAppStoryboard: .Main)
            AppRouter.pushViewController(self, vc)
        }
    }
    
}
