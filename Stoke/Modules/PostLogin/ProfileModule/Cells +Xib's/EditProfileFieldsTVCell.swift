//
//  EditProfileFieldsTVCell.swift
//  Stoke
//
//  Created by Admin on 17/05/21.
//

import UIKit
import IQKeyboardManagerSwift

class EditProfileFieldsTVCell: UITableViewCell {
    
    @IBOutlet weak var nameTF: AppTextField!
    @IBOutlet weak var userNameTF: AppTextField!
    @IBOutlet weak var bioBgView: UIView!
    @IBOutlet weak var bioTextView: IQTextView!
    
    var getBio:((String)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bioTextView.delegate = self
        userNameTF.setupAs = .userName
        nameTF.setupAs = .lastname
        nameTF.placeholder = "Name"
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        bioBgView.cornerRadius = 10
        bioBgView.setBorder(width: 1.0, color: #colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1))
    }
    
}

extension EditProfileFieldsTVCell : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        bioBgView.cornerRadius = 10
        bioBgView.setBorder(width: 1.0, color: #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1))
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            bioBgView.cornerRadius = 10
            bioBgView.setBorder(width: 1.0, color: #colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1))
        }else{
            bioBgView.cornerRadius = 10
            bioBgView.setBorder(width: 1.0, color: #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1))
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let bio =  self.getBio { bio(textView.text) }
            }
            return true
        }
        if textView.text.count > 200{
            return false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let bio =  self.getBio { bio(textView.text) }
        }
        return true
    }
    
}
