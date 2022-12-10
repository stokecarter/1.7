//
//  SignupSucessVC.swift
//  Stoke
//
//  Created by Admin on 26/02/21.
//

import UIKit

protocol SignupSucessDelegate:AnyObject {
    func okTapped()
}

class SignupSucessVC: BaseVC {

    @IBOutlet weak var okBtn: AppButton!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subHeading: UILabel!
    @IBOutlet weak var tickIcon: UIImageView!
    weak var delegate: SignupSucessDelegate?
    
    
    
    var isFromSignup:Bool = false
    var msg:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initalSetup() {
        okBtn.btnType = .themeColor
    }
    
    override func setupFounts() {
        headingLabel.font = AppFonts.Medium.withSize(18)
        subHeading.font = AppFonts.Regular.withSize(16)
        if let m = msg{
            subHeading.text = m
        }else{
            subHeading.text = isFromSignup ? "Password reset successfully. Log In to continue" : "We have sent you an email with the verification link to veify your email. Kindly follow the intructions to verify the email."
        }
        subHeading.textColor = AppColors.labelColor
    }
    
    @IBAction func okTapped(_ sender: Any) {
        delegate?.okTapped()
        dismiss(animated: false, completion: nil)
    }
    

}
