//
//  FeedbackVC.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import UIKit
import IQKeyboardManagerSwift

class FeedbackVC: BaseVC {
    
    
    @IBOutlet weak var descBgView: UIView!
    @IBOutlet weak var cancelbtn: AppButton!
    @IBOutlet weak var submitBtn: AppButton!
    @IBOutlet weak var descTextView: IQTextView!
    
    var viewModel:FeedbackVm!
    var enableBtn:Bool = false{
        didSet{
            if enableBtn{
                submitBtn.alpha = 1.0
                submitBtn.isUserInteractionEnabled = true
            }else{
                submitBtn.alpha = 0.6
                submitBtn.isUserInteractionEnabled = false
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(title: "Feedback", backButton: true)
        applyTransparentBackgroundToTheNavigationBar(100)
        viewModel = FeedbackVm(NetworkLayer())
        viewModel.popBack = { [weak self] in
            self?.pop()
        }
        enableBtn = false
        descTextView.delegate = self
        descBgView.cornerRadius = 10
        descBgView.setBorder(width: 1.0, color: #colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1))
        cancelbtn.btnType = .whiteColor
        submitBtn.btnType = .themeColor
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        pop()
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        viewModel.hitForFeedback()
    }
    
    private func checkForEnableBtn(){
        if viewModel.desc.isEmpty{
            enableBtn = false
        }else{
            enableBtn = true
        }
    }
}

extension FeedbackVC : UITextViewDelegate {
    
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
            self.checkForEnableBtn()
            return true
        }
        if textView.text.count > 1500{
            return false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.viewModel.desc = textView.text
            self?.checkForEnableBtn()
            
        }
        return true
    }
    
}
