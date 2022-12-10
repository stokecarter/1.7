//
//  AddCardTVCell.swift
//  Stoke
//
//  Created by Admin on 07/05/21.
//

import UIKit

class AddCardTVCell: UITableViewCell {

    @IBOutlet weak var cardNoTF: AppTextField!
    @IBOutlet weak var cardholderNameTF: AppTextField!
    @IBOutlet weak var cvvTF: AppTextField!
    @IBOutlet weak var ddMMTF: AppTextField!
    @IBOutlet weak var saveCardBtn: UIButton!
    
    
    var month:UInt = 0
    var year:UInt = 0
    var model = CardDetails(cardNo: "", cardholderName: "", cvv: "", expMonth: 0, expYear: 0)
    var addCardTapped:((CardDetails)->())?
    var expiryDatePicker:MonthYearPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        saveCardBtn.setImage(#imageLiteral(resourceName: "ic-check-inactive"), for: .normal)
        saveCardBtn.setImage(#imageLiteral(resourceName: "ic-check-active"), for: .selected)
        [cardNoTF,cardholderNameTF,cvvTF,ddMMTF].forEach {
            $0.textLeftPadding = 10
        }
        cardNoTF.setupAs = .creditCard
        expiryDatePicker = MonthYearPickerView()
        ddMMTF.inputView = expiryDatePicker
        expiryDatePicker.onDateSelected = { (month: Int, year: Int) in
            self.month = UInt(month)
            self.year = UInt(year)
            self.model.expMonth = self.month
            self.model.expYear = self.year
            self.ddMMTF.text = "\(month)/\(year)"
            if let tap = self.addCardTapped { tap(self.model) }
        }
        cardNoTF.keyboardType = .numberPad
        cvvTF.setupAs = .cvv
        [cardNoTF,cardholderNameTF,cvvTF,ddMMTF].forEach {
            $0?.addTarget(self, action: #selector(textFieldEditing(_:)), for: .editingChanged)
        }
        cardNoTF.editingChange = { [weak self] in
            guard let self = self else { return }
            if let tap = self.addCardTapped { tap(self.model) }
        }
    }
    
    @IBAction func saveCardTapped(_ sender: UIButton) {
        saveCardBtn.isSelected = !sender.isSelected
        let m = CardDetails(cardNo: cardNoTF.text?.replace(string: " ", withString: "") ?? "", cardholderName: cardholderNameTF.text ?? "", cvv: cvvTF.text ?? "", expMonth: month, expYear: year,isDefault: saveCardBtn.isSelected)
        if let tap = addCardTapped { tap(m) }
    }
    
    @objc private func textFieldEditing(_ tf:AppTextField){
        model.cardNo = cardNoTF.text?.replace(string: " ", withString: "") ?? ""
        model.cvv = cvvTF.text ?? ""
        model.cardholderName = cardholderNameTF.text?.byRemovingLeadingTrailingWhiteSpaces ?? ""
        model.expMonth = self.month
        model.expYear = self.year
        if let tap = addCardTapped { tap(model) }
    }
    
    
}
