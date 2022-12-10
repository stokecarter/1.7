//
//  UITextFieldExtension.swift
//  WoshApp
//
//  Created by Saurabh Shukla on 19/09/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//


import Foundation
import UIKit

extension UITextField{
    
    ///Sets and gets if the textfield has secure text entry
    var isSecureText:Bool{
        get{
            return self.isSecureTextEntry
        }
        set{
            let font = self.font
            self.isSecureTextEntry = newValue
            if let text = self.text{
                self.text = ""
                self.text = text
            }
            self.font = nil
            self.font = font
            self.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        }
    }
    
    // STOP SPECIAL CHARACTERS
    //===========================
    func stopSpecialCharacters() {
        let ACCEPTABLE_CHARACTERS = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@"
        let cs = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered: String = (text!.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
        
        if text != filtered {
            text?.removeLast()
        }
    }
    // SET IMAGE TO LEFT VIEW
    //=========================
    func setImageToLeftView(img : UIImage, size: CGSize?) {
        
        self.leftViewMode = .always
        let leftImage = UIImageView(image: img)
        self.leftView = leftImage
        
        leftImage.contentMode = UIView.ContentMode.center
        if let imgSize = size {
            self.leftView?.frame.size = imgSize
        } else {
            self.leftView?.frame.size = CGSize(width: 50, height: self.frame.height)
        }
        leftImage.frame = self.leftView!.frame
    }
    
    // SET IMAGE TO RIGHT VIEW
    //=========================
    func setImageToRightView(img : UIImage, size: CGSize?) {
        
        self.rightViewMode = .always
        let rightImage = UIImageView(image: img)
        self.rightView = rightImage
        
        rightImage.contentMode = UIView.ContentMode.center
        if let imgSize = size {
            self.rightView?.frame.size = imgSize
        } else {
            self.rightView?.frame.size = CGSize(width: 20, height: self.frame.height)
        }
        rightImage.frame = self.rightView!.frame
    }
    
    // SET BUTTON TO RIGHT VIEW
    //=========================
    func setButtonToRightView(btn : UIButton, selectedImage : UIImage?, normalImage : UIImage?, size: CGSize?) {
        
        self.rightViewMode = .always
        self.rightView = btn
        
        btn.isSelected = false
        
        if let selectedImg = selectedImage { btn.setImage(selectedImg, for: .selected) }
        if let unselectedImg = normalImage { btn.setImage(unselectedImg, for: .normal) }
        if let btnSize = size {
            self.rightView?.frame.size = btnSize
        } else {
            self.rightView?.frame.size = CGSize(width: btn.intrinsicContentSize.width+10, height: self.frame.height)
        }
    }
    
    // SET VIEW TO RIGHT VIEW
    //=========================
    func setViewToRightView(view : UIView, size: CGSize?) {
        
        self.rightViewMode = .always
        self.rightView = view
        
        if let btnSize = size {
            self.rightView?.frame.size = btnSize
        } else {
            self.rightView?.frame.size = CGSize(width: view.intrinsicContentSize.width+10, height: self.frame.height)
        }
    }
    
    /// CREATE DATE PICKER
    //=========================
    func createDatePicker(start: Date?, end: Date?, current: Date, didSelectDate: @escaping ((Date) -> Void)) {
        
        guard inputView == nil else { return }
        
        var datePicker = UIDatePicker()
        
        // DatePicker
        datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: UIDevice.width, height: 216))
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.minimumDate = start
        datePicker.maximumDate = end
        datePicker.setDate(current, animated: true)
        self.inputView = datePicker
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            
        }
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain) { (_) in
            
            self.text = datePicker.date.convertToString()
            self.resignFirstResponder()
            
            didSelectDate(datePicker.date)
        }
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain) { (_) in
            self.resignFirstResponder()
        }
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.inputAccessoryView = toolBar
    }
}
