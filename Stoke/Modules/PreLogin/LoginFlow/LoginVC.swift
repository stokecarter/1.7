//
//  LoginVC.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import UIKit
import GoogleSignIn

class LoginVC: BaseVC {
    
    //    MARK:- IBOutlets
    
    @IBOutlet weak var usernameTF: AppTextField!
    @IBOutlet weak var passwordTF: AppTextField!
    @IBOutlet weak var forgotPwdBtn: UIButton!
    @IBOutlet weak var loginBtn: AppButton!
    @IBOutlet weak var fbBtn: AppButton!
    @IBOutlet weak var googleBtn: AppButton!
    @IBOutlet weak var appleBtn: AppButton!
    @IBOutlet weak var guestBtn: AppButton!
    @IBOutlet weak var signupLable: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var innerView: UIView!
    
    var isRoot:Bool = false
    
    var enabledBtn:Bool = false{
        didSet{
            if enabledBtn{
                loginBtn.alpha = 1.0
                loginBtn.isEnabled = true
            }else{
                loginBtn.alpha = 0.6
                loginBtn.isEnabled = false
            }
        }
        
    }
    
    
    var tapableRange1:NSRange!
    var viewModel:LoginVM!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setWhiteNavigationBar(title: "", backButton: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoginVM(NetworkLayer())
        if view.bounds.height > 812{
            innerView.frame = CGRect(x: 0, y: 0, width: view.width, height: 812)
        }
        
    }
    
    override func initalSetup() {
        enabledBtn = false
        loginBtn.btnType = .themeColor
        fbBtn.btnType = .facebook
        googleBtn.btnType = .google
        appleBtn.btnType = .apple
        guestBtn.btnType = .noborder
        usernameTF.setupAs = .generic
        passwordTF.setupAs = .password
        passwordTF.editingChange = { [weak self] in
            self?.checkForBtn()
        }
        usernameTF.editingChange = {[weak self] in
            self?.checkForBtn()
            
        }
        setUpActiveLabel()
    }
    
    override func setupFounts() {
        
        loginBtn.setTitle("Log In", for: .normal)
        fbBtn.setTitle("Sign in with Facebook", for: .normal)
        googleBtn.setTitle("Sign in with Google", for: .normal)
        appleBtn.setTitle("Sign in with Apple", for: .normal)
        guestBtn.setTitle("Explore as Guest", for: .normal)
        forgotPwdBtn.setTitleColor(AppColors.themeColor, for: .normal)
        forgotPwdBtn.titleLabel?.font = AppFonts.Medium.withSize(14)
        loginLabel.textColor = AppColors.labelColor
    }
    
    override func backButtonTapped() {
        if isRoot{
            AppRouter.goToWelcomeScreen()
        }else{
            pop()
        }
    }
    
    
    //    MARK:- IBActions
    
    @IBAction func forgotPwdTapped(_ sender: Any) {
        let vc = ForgotByPhoneVC.instantiate(fromAppStoryboard: .Main)
        AppRouter.pushViewController(self, vc)
        
    }
    @IBAction func loginTapped(_ sender: Any) {
        view.endEditing(true)
        guard CommonFunctions.checkForInternet() else { return }
        viewModel.userName = usernameTF.text ?? ""
        viewModel.password = passwordTF.text ?? ""
        guard viewModel.vaildatePageOne() else { return }
        viewModel.hitLogin()
    }
    @IBAction func facebookTapped(_ sender: Any) {
        FacebookController.shared.getFacebookUserInfo(fromViewController: self, success: { (model) in
            self.viewModel.checkFBUser(model) { (flag) in
                if flag{
                    let vm = SocialSignupVM(NetworkLayer(), type: .facebook)
                    vm.fbmodel = model
                    vm.type = .facebook
                    vm.hitSocail(true)
                }else{
                    let vc = UserNamePopupVC.instantiate(fromAppStoryboard: .Main)
                    vc.modalTransitionStyle = .coverVertical
                    vc.fbModel = model
                    vc.type = .facebook
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }) { (e) in
            printDebug(e?.localizedDescription)
        }
    }
    @IBAction func googleTapped(_ sender: Any) {
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
    
    private func checkForBtn(){
        self.enabledBtn = !(self.passwordTF.text ?? "").isEmpty && !(self.usernameTF.text ?? "").isEmpty
    }
    
    
}



extension LoginVC {
    private func setUpActiveLabel(){
        
        let customType1    = "Sign Up"
        let text           = "Don’t have an account? Sign Up"
        signupLable.attributedText = attributedText(withString: text, boldString1: customType1, font: AppFonts.Regular.withSize(16))
    }
    
    private func attributedText(withString string: String, boldString1: String,font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:AppColors.labelColor])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Medium.withSize(16),NSAttributedString.Key.foregroundColor:AppColors.themeColor]
        tapableRange1 = (string as NSString).range(of: boldString1)
        attributedString.addAttributes(boldFontAttribute, range: tapableRange1)
        signupLable.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(_:)))
        signupLable.addGestureRecognizer(tap)
        return attributedString
    }
    
    @objc func tapLabel(_ gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: signupLable, inRange: tapableRange1) {
            goToSignin()
        } else{
            printDebug("Tapped none")
        }
    }
    
    private func goToSignin(){
        var flag = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: SignUpVC.self) {
                flag.toggle()
                self.navigationController!.popToViewController(controller, animated: true)
                return
            }
        }
        if !flag{
            let vc = SignUpVC.instantiate(fromAppStoryboard: .Main)
            AppRouter.pushViewController(self, vc)
        }
    }
}

