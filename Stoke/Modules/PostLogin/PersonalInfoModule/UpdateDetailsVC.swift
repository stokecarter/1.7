//
//  UpdateDetailsVC.swift
//  Stoke
//
//  Created by Admin on 28/05/21.
//

import UIKit

class UpdateDetailsVC: BaseVC {
    
    
    @IBOutlet weak var emailTF: AppTextField!
    @IBOutlet weak var updateBtn: AppButton!
    
    var viewModel:PersonalInfoVM!
    var isEmail:Bool = true
    var enableUpdateBtn:Bool = false{
        didSet{
            if enableUpdateBtn{
                updateBtn.alpha = 1.0
                updateBtn.isUserInteractionEnabled = true
            }else{
                updateBtn.alpha = 0.6
                updateBtn.isUserInteractionEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let t = isEmail ? (viewModel.model.email.isEmpty ? "Add" : "Update") : (viewModel.model.mobileNo.isEmpty ? "Add" : "Update")
        updateBtn.setTitle(t, for: .normal)
        enableUpdateBtn = false
        let ti = isEmail ? "Email" : "Phone Number"
        setNavigationBar(title: ti, backButton: true)
        emailTF.editingChange = { [weak self] in
            self?.enableUpdateBtn = !(self?.emailTF.text ?? "" ).isEmpty
        }
        setupView()
        emailTF.font = AppFonts.Medium.withSize(16)
    }
    
    private func setupView(){
        if isEmail{
            emailTF.setupAs = .email
            emailTF.placeholder = "Enter New Email"
        }else{
            emailTF.setupAs = .phone
            emailTF.placeholder = "Enter New Phone Number"
        }
    }
    
    private func gotoOtp(){
        let vc = OTPVc.instantiate(fromAppStoryboard: .Main)
        vc.mobile = viewModel.mobile.replace(string: "-", withString: "").byRemovingLeadingTrailingWhiteSpaces
        vc.countryCode = "+1"
        vc.isfromSettings = true
        vc.userId = viewModel.model._id
        AppRouter.pushViewController(self, vc)
    }
    
    
    @IBAction func updateBtnTapped(_ sender: Any) {
        if isEmail{
            viewModel.email = emailTF.text ?? ""
            viewModel.updateInfo(true) { [weak self] in
                self?.pop()
            }
        }else{
            viewModel.mobile = emailTF.text ?? ""
            viewModel.updateInfo(false) { [weak self] in
                self?.gotoOtp()
            }
        }
    }
    
}
