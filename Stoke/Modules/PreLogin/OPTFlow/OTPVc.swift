//
//  OTPVc.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import UIKit

class OTPVc: BaseVC {
    
    @IBOutlet weak var tf1: UITextField!
    @IBOutlet weak var tf2: UITextField!
    @IBOutlet weak var tf3: UITextField!
    @IBOutlet weak var tf4: UITextField!
    @IBOutlet weak var headingLabel:UILabel!
    @IBOutlet weak var subheading:UILabel!
    @IBOutlet weak var verifyBtn:AppButton!
    @IBOutlet weak var resendLabel: UILabel!
    
    var time = 60
    var timer:Timer!
    
    //    MARK:- Properties
    
    
    var isfromSettings = false
    var isResetPwd:Bool = false
    var viewModel:OtpVerificationVM!
    var mobile = ""
    var countryCode = ""
    var userId = ""
    var code1 = "",code2 = "",code3 = "",code4 = ""
    var loginRange:NSRange!
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
        setWhiteNavigationBar(title: "", backButton: true)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initalSetup() {
        enableBtn = false
        viewModel = OtpVerificationVM(NetworkLayer())
        viewModel.phoneNo = mobile
        viewModel.countryCode = countryCode
        viewModel.userId = userId
        [tf1,tf2,tf3,tf4].forEach{
            $0?.attributedPlaceholder = returnAttributedPlaceHolder()
            $0?.font = AppFonts.Medium.withSize(24)
            $0?.delegate = self
            $0?.layer.cornerRadius = 10
            $0?.textAlignment = .center
            $0?.keyboardType = .phonePad
            $0?.setBorder(width: 1, color: AppColors.borderColor)
        }
        verifyBtn.btnType = .themeColor
        setUptextField()
        viewModel.openResetPwdScreen = { [weak self] token in
            guard let self = self else { return }
            AppRouter.openRestPassword(token)
        }
        viewModel.popBackTosettings = { [weak self] in
            self?.popToSpecificViewController(atIndex: 0)
        }
    }
    
    override func setupFounts() {
        subheading.font = AppFonts.Regular.withSize(16)
        headingLabel.font = AppFonts.Medium.withSize(18)
        subheading.textColor = AppColors.labelColor
        startTimer()
//        setUpActiveLabel()
    }
    
    @IBAction func verifyTapped(_ sender: Any) {
        view.endEditing(true)
        guard CommonFunctions.checkForInternet() else { return }
        guard (code1 + code2 + code3 + code4).count == 4 else {
            CommonFunctions.showToastWithMessage("Please enter a valid OTP")
            return
        }
        viewModel.enteredOtp = (code1 + code2 + code3 + code4)
        if isResetPwd{
            viewModel.hitVerifyRestOtp()
        }else{
            viewModel.hitToVerifyOtp(isfromSettings)
        }
    }
    
    private func startTimer(){
        resendLabel.font = AppFonts.Regular.withSize(16)
        resendLabel.textColor = .black
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self](timer) in
            guard let self = self else { return }
            if self.time == 0{
                self.setUpActiveLabel()
            }else{
                self.time -= 1
                self.resendLabel.text = "00:\(self.time)"
            }
        })
    }
    
    
    private func returnAttributedPlaceHolder() -> NSAttributedString{
        return NSAttributedString(string: "_",
                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor(r: 137, g: 137, b: 137, alpha: 1),NSAttributedString.Key.font:AppFonts.Medium.withSize(28)])
    }
    
    
    private func setUpActiveLabel(){
        
        let loginType    = "Resend Code"
        let text1        = "Didn't receive code? Resend Code"
        resendLabel.attributedText = attributedTextLogin(withString: text1, boldString1: loginType, font: AppFonts.Regular.withSize(16))
    }
    
    private func attributedTextLogin(withString string: String, boldString1: String,font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:AppColors.labelColor])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Medium.withSize(16),NSAttributedString.Key.foregroundColor:AppColors.themeColor]
        loginRange = (string as NSString).range(of: boldString1)
        attributedString.addAttributes(boldFontAttribute, range: loginRange)
        resendLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabelLogin(_:)))
        resendLabel.addGestureRecognizer(tap)
        return attributedString
    }
    
    @objc func tapLabelLogin(_ gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: resendLabel, inRange: loginRange)
        {
            clearTF()
            time = 60
            timer.invalidate()
            startTimer()
            if isResetPwd{
                viewModel.hitResendForgotOtp()
            }else{
                viewModel.hitResendOtp()
            }
        }else{
            printDebug("Do nothing...")
        }
    }
    
    private func clearTF(){
        code1 = ""
        code2 = ""
        code3 = ""
        code4 = ""
        [tf1,tf2,tf3,tf4].forEach{
            $0?.text = nil
        }
    }

    private func setUptextField(){
        tf1.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        tf2.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        tf3.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        tf4.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        tf1.becomeFirstResponder()
    }
    
    @objc
    func textFieldDidChange(_ textField: UITextField){
        let text = textField.text
        if  text?.count == 1 {
            switch textField{
            case tf1:
                code1 = text ?? ""
                tf2.becomeFirstResponder()
            case tf2:
                code2 = text ?? ""
                tf3.becomeFirstResponder()
            case tf3:
                code3 = text ?? ""
                tf4.becomeFirstResponder()
            case tf4:
                code4 = text ?? ""
                tf4.resignFirstResponder()
            default:
                break
            }
        }
        if  text?.count == 0 {
            switch textField{
            case tf1:
                code1 = ""
                tf1.becomeFirstResponder()
            case tf2:
                code2 = ""
                tf1.becomeFirstResponder()
            case tf3:
                code3 = ""
                tf2.becomeFirstResponder()
            case tf4:
                code4 = ""
                tf3.becomeFirstResponder()
            default:
                break
            }
        }
        else{
            textField.resignFirstResponder()
        }
        if (code1 + code2 + code3 + code4).count == 4{
            enableBtn = true
        }else{
            enableBtn = false
        }
    }
}


extension OTPVc : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        
        if (textField.text ?? "").count > 0{
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.setBorder(width: 1, color: AppColors.selectedBorder)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty{
            textField.setBorder(width: 1, color: AppColors.selectedBorder)
        }else{
            textField.setBorder(width: 1, color: AppColors.borderColor)
        }
    }
}

