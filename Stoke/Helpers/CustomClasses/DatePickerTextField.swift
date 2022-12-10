//
//  DatePickerTextField.swift
//  Onboarding
//
//  Created by Bhavneet Singh on 06/07/18.
//  Copyright © 2018 Gurdeep Singh. All rights reserved.
//

import UIKit

class DatePickerTextField: UITextField {
    
    // MARK:- Initializers
    //=======================
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupDatePicker()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupDatePicker()
    }
    
    /// Text Rect
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width - 10, height: bounds.height)
    }
    
    /// Editing Rect
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width - 10, height: bounds.height)
    }
    
    /// Placeholder Rect
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width - 10, height: bounds.height)
    }
}

// MARK:- Delegate
//=================
extension DatePickerTextField : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = Date.DateFormat.yyyy_MM_dd.rawValue
        
        var currDate = Date()
        if textField.text != nil && !textField.text!.isEmpty {
            if let curDate = formatter.date(from: textField.text!){
                currDate = curDate
            }
        }
        
        DatePicker.openPicker(in: self, currentDate: currDate, minimumDate: date, maximumDate: nil, pickerMode: UIDatePicker.Mode.date) { (selectedDate) in
            
            let result = formatter.string(from: selectedDate)
            self.text = result
        }
    }
}

// MARK:- Private Functions
//===========================
extension DatePickerTextField {
    
    /// Setup Date Picker
    private func setupDatePicker(){
        
        let dummyButton = UIButton()
        dummyButton.isEnabled = false
        self.setButtonToRightView(btn: dummyButton, selectedImage: nil, normalImage: nil, size: nil)
        self.rightView?.frame.size.width += 15
        self.textAlignment = .left
        self.layer.borderWidth = 1
        self.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        self.delegate = self
    }
}

// MARK:- DatePicker Class Implementation
//==========================================
class DatePicker : UIDatePicker {
    
    internal typealias PickerDone = (_ date : Date) -> Void
    
    private var doneBlock : PickerDone!
    
    class func openPicker(in textField: UITextField, currentDate: Date?, minimumDate: Date?, maximumDate: Date?, pickerMode: UIDatePicker.Mode, doneBlock: @escaping PickerDone) {
        
        let picker = DatePicker()
        picker.doneBlock = doneBlock
        picker.openPickerInTextField(textField: textField, currentDate: currentDate, minimumDate: minimumDate, maximumDate: maximumDate, pickerMode: pickerMode)
        
    }
    
    private func openPickerInTextField(textField: UITextField, currentDate: Date?, minimumDate: Date?, maximumDate: Date?, pickerMode: UIDatePicker.Mode) {
        
        self.datePickerMode = pickerMode
        
        self.maximumDate = maximumDate //?? NSDate() //NSDate(timeIntervalSinceNow: -1.577e+8)
        self.date = currentDate ?? Date()
        self.minimumDate = minimumDate //?? NSDate() //NSDate(timeIntervalSince1970: -1000000000)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(DatePicker.pickerDoneButtonTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action:nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(DatePicker.pickerCancelButtonTapped))
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let array = [cancelButton,spaceButton, doneButton]
        toolbar.setItems(array, animated: true)
        toolbar.backgroundColor = UIColor.lightText
        
        textField.inputView = self
        textField.inputAccessoryView = toolbar
        
    }
    
    @IBAction private func pickerDoneButtonTapped(){
        
        UIApplication.shared.keyWindow?.endEditing(true)
        self.doneBlock(self.date)
    }
    
    @IBAction private func pickerCancelButtonTapped(){
        
        UIApplication.shared.keyWindow?.endEditing(true)
        self.setDate(Calendar.current.date(byAdding: .year, value: 0, to: Date(), wrappingComponents: false)!, animated: false)
    }
}

