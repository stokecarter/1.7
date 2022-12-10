//
//  ContactUsVC.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import UIKit
import IQKeyboardManagerSwift

class ContactUsVC: BaseVC {
    
    @IBOutlet weak var optionsTF: AppTextField!
    @IBOutlet weak var dropDownviewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var descBgView: UIView!
    @IBOutlet weak var descTextView: IQTextView!
    @IBOutlet weak var cancelbtn: AppButton!
    @IBOutlet weak var saveBtn: AppButton!
    
    var isDropdownShown = false
    
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
    var viewModel:ContactusVM!
    var user:UserProfileModel!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dropDownView.roundCorner([.bottomLeft,.bottomRight], radius: 10)
        dropDownView.setBorder(width: 1, color: #colorLiteral(red: 0.8275570273, green: 0.8275765181, blue: 0.8275660276, alpha: 1))
        dropDownView.shadowColor = #colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1)
        dropDownView.shadowOffset = .zero
        dropDownView.shadowRadius = 4
        dropDownView.shadowOpacity = 1
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ContactusVM(NetworkLayer())
        viewModel.popBack = { [weak self] in
            self?.pop()
        }
        dropDownviewHeightConstant.constant = CGFloat.leastNormalMagnitude
        enableBtn = false
        descBgView.cornerRadius = 10
        descBgView.setBorder(width: 1.0, color: #colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1))
        optionsTF.setupAs = .defaultTf
        optionsTF.placeholder = "Please Select"
        optionsTF.textLeftPadding = 10
        optionsTF.setIconOnRight(#imageLiteral(resourceName: "ic_drop_down"))
        optionsTF.editingBegain = { [weak self] in
            self?.animatedropdown(self?.isDropdownShown ?? false)
            self?.isDropdownShown.toggle()
        }
        cancelbtn.btnType = .whiteColor
        descTextView.delegate = self
        setNavigationBar(title: "Contact Us", backButton: true)
        applyTransparentBackgroundToTheNavigationBar(100)
        optionsTF.font = AppFonts.Medium.withSize(16)
        descTextView.font = AppFonts.Medium.withSize(14)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTransparentBackgroundToTheNavigationBar(100)

    }
    
    @IBAction func paymnetTapped(_ sender: Any) {
        viewModel.type = "Verification Request"
        optionsTF.text = "Verification Request"
        checkForEnablingBtn()
        isDropdownShown = false
        animatedropdown(isDropdownShown)
    }
    @IBAction func othersTapped(_ sender: Any) {
        viewModel.type = "Other"
        optionsTF.text = "Other"
        checkForEnablingBtn()
        isDropdownShown = false
        animatedropdown(isDropdownShown)
    }
    
    @IBAction func canceltapped(_ sender: Any) {
        pop()
    }
    
    @IBAction func submittapped(_ sender: Any) {
        if UserModel.main.email.isEmpty{
            let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
            vc.delegate = self
            vc.isForDelete = true
            vc.headingText = "Email Required!"
            vc.subheadingTxt = "Please add your email to before proceeding for the query."
            vc.firstbtnTitle = "Cancel"
            vc.secondbtnTitle = "Add"
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
        }else{
            viewModel.hitConatctus()
        }
    }
    
    
    private func animatedropdown(_ flag:Bool){
        view.endEditing(true)
        if flag{
            UIView.animate(withDuration: 0.33) {
                self.dropDownviewHeightConstant.constant = 100
                self.view.layoutIfNeeded()
            } completion: { (flag) in
                printDebug("......")
            }
        }else{
            UIView.animate(withDuration: 0.33) {
                self.dropDownviewHeightConstant.constant = CGFloat.leastNormalMagnitude
                self.view.layoutIfNeeded()
            } completion: { (flag) in
                printDebug("......")
            }
        }
    }
    
    private func checkForEnablingBtn(){
        guard let a = optionsTF.text, let b = descTextView.text else { enableBtn = false
            return }
        if a.isEmpty || b.isEmpty{
            enableBtn = false
        }else{
            enableBtn = true
        }
    }
    

}

extension ContactUsVC : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        descBgView.cornerRadius = 10
        descBgView.setBorder(width: 1.0, color: #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1))
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            descBgView.cornerRadius = 10
            descBgView.setBorder(width: 1.0, color: #colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1))
        }else{
            descBgView.cornerRadius = 10
            descBgView.setBorder(width: 1.0, color: #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1))
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" {
            self.viewModel.desc = textView.text
            self.checkForEnablingBtn()
            return true
        }
        if textView.text.count > 1500{
            return false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.viewModel.desc = textView.text
            self?.checkForEnablingBtn()
        }
        return true
    }
    
}

extension ContactUsVC : GenericPopupDelegate{
    func optionTapped(_ flag: Bool, isDelete: Bool, id: String) {
        if flag{
            let vc = PersonalInfoVC.instantiate(fromAppStoryboard: .Events)
            vc.model = self.user
            AppRouter.pushViewController(self, vc)
        }
    }
}
