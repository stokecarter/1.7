//
//  ResetPasswordVC.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import UIKit

class ResetPasswordVC: BaseVC {
    
    
    @IBOutlet weak var oldPwdTF: AppTextField!
    @IBOutlet weak var newPwdTF: AppTextField!
    @IBOutlet weak var confirmPwdTF: AppTextField!
    @IBOutlet weak var cancelBtn: AppButton!
    @IBOutlet weak var saveBtn: AppButton!
    
    var viewModel:ResetPasswordVM!
    var enableBtn:Bool = false{
        didSet{
            if enableBtn{
                saveBtn.alpha = 1.0
                saveBtn.isUserInteractionEnabled = true
            }else{
                saveBtn.alpha = 0.6
                saveBtn.isUserInteractionEnabled = false
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ResetPasswordVM(NetworkLayer())
        setNavigationBar(title: "Change Password", backButton: true)
        applyTransparentBackgroundToTheNavigationBar(100)

    }
    
    override func initalSetup() {
        enableBtn = false
        cancelBtn.btnType = .whiteColor
        saveBtn.btnType = .themeColor
        oldPwdTF.setupAs = .password
        newPwdTF.setupAs = .password
        confirmPwdTF.setupAs = .password
        oldPwdTF.placeholder = "Current Password"
        newPwdTF.placeholder = "New Password"
        confirmPwdTF.placeholder = "Confirm Password"
        newPwdTF.editingChange = { [weak self] in
            self?.checkForSaveBtn()
        }
        oldPwdTF.editingChange = { [weak self] in
            self?.checkForSaveBtn()
        }
        confirmPwdTF.editingChange = { [weak self] in
            self?.checkForSaveBtn()
        }
    }
    
    private func checkForSaveBtn(){
        guard let a = oldPwdTF.text,let b = newPwdTF.text, let c = confirmPwdTF.text else{
            enableBtn = false
            return
        }
        if a.isEmpty || b.isEmpty || c.isEmpty{
            enableBtn = false
        }else{
            enableBtn = true
        }
    }
    
    
    @IBAction func canceltapped(_ sender: Any) {
        pop()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        viewModel.currentPwd = oldPwdTF.text ?? ""
        viewModel.newPwd = newPwdTF.text ?? ""
        viewModel.cnfPwd = confirmPwdTF.text ?? ""
        viewModel.hitChangePassword { [weak self] in
            self?.pop()
        }
    }
}
