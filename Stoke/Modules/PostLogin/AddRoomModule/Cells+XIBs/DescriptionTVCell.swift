//
//  DescriptionTVCell.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import UIKit
import IQKeyboardManagerSwift

class DescriptionTVCell: UITableViewCell {

    @IBOutlet weak var descTextView: IQTextView!
    
    var descriptionText:((String)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setInitailSetup()
    }
    
    private func setInitailSetup(){
        descTextView.delegate = self
        descTextView.keyboardType = .default
    }
    
}

extension DescriptionTVCell : UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == ""{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let desc = self.descriptionText { desc(textView.text)}
            }
            return true
        }
        if textView.text.count > 200{
            return false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let desc = self.descriptionText { desc(textView.text)}
        }
        return true
    }
}
