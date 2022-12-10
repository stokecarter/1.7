//
//  MarginTextField.swift
//  Onboarding
//
//  Created by Bhavneet Singh on 11/07/18.
//  Copyright © 2018 Gurdeep Singh. All rights reserved.
//

import UIKit

// MARK:- Margin Label
//=======================

// MARK:- Custom TextField
//=================================
class AppTextField: MarginTextField {
    
    // MARK:- Variables
    //===================
    enum TextFieldType {
        case email
        case phone
        case otp
        case date
        case userName
        case password
        case defaultTf
        case firstname
        case lastname
        case buddy
        case buddyEmpty
        case countryCode
        case generic
        case chatroom
        case eventname
        case creditCard
        case cvv
        case name
        case location
    }
    
    var errorLabel = UILabel()
    private weak var revealPasswordBtn: UIButton?
    private weak var loader:UIActivityIndicatorView?
    var isSecured: Bool = true {
        didSet{
            self.isSecureTextEntry = !self.isSecureTextEntry
        }
    }
    var errorMsg:String = "" {
        didSet{
            errorLabel.text = errorMsg
        }
    }
    
    var editingChange:(()->())?
    var editingBegain:(()->())?
    var editingEnd:(()->())?
    var textFieldShouldReturn: ((AppTextField)->Bool)?
    var startAnimating:Bool = false{
        didSet{
            if startAnimating{
                loader?.isHidden = false
                loader?.startAnimating()
            }else{
                loader?.isHidden = true
                loader?.stopAnimating()
            }
        }
    }
    
    var setupAs: TextFieldType = .defaultTf {
         didSet {
             setupSubviews()
         }
     }
    
     @IBInspectable var textLeftPadding: CGFloat = 45 {
         didSet {
             layoutMarginsDidChange()
         }
     }
     
     @IBInspectable var textRightPadding: CGFloat = 45 {
         didSet {
             layoutMarginsDidChange()
         }
     }
    
    private var pickerData: [String] = []
    
    // MARK:- Initializers
    //======================
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupSubviews()
        self.setupErrorLabel()
    }
    
    open override var delegate: UITextFieldDelegate? {
        set {
            if let newValue = newValue, newValue is AppTextField {
                super.delegate = newValue
            } else {
                assertionFailure("Sorry this delegate is not for use outside this subclass.")
            }
        }
        get {
            return super.delegate
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = bounds.inset(by: UIEdgeInsets(top: 0, left: textLeftPadding, bottom: 0, right: textRightPadding))
        return rect
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let rect = bounds.inset(by: UIEdgeInsets(top: 0, left: textLeftPadding, bottom: 0, right: textRightPadding))
        return rect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = bounds.inset(by: UIEdgeInsets(top: 0, left: textLeftPadding, bottom: 0, right: textRightPadding))
        return rect
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: 0 , height: bounds.height)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 60, y: 0, width: 60 , height: bounds.height)
    }
    
    // MARK:- Layout Subviews
    //=========================
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupErrorLabelFrames()
    }
    
    
}

// MARK:- Private Setup Functions
//================================
extension AppTextField {
    
    /// Setup Subviews
    private func setupSubviews() {
        clipsToBounds = false
        borderStyle = .none
        font = AppFonts.Regular.withSize(18.0)
        textColor = .black
        setBorder(width: 1, color: AppColors.borderColor)
        layer.cornerRadius = 10
        delegate = self
        switch setupAs {
        case .defaultTf:
            setDefaultTextField()
        case .email:
            setupEmailUsernameTF()
        case .password:
            setupPasswordTF()
        case .firstname:
            setupFirstNameTF()
        case .lastname:
            setupLastNameTF()
        case .date:
            setupDOBTF()
        case .userName:
            setupUserNameTF()
        case .phone:
            setupPhoneTF()
        case .buddy:
            buddyTF()
        case .buddyEmpty:
            buddyEmptyTF()
        case .countryCode:
            setupCountryCode()
        case .generic:
            setupGeneric()
        case .chatroom:
            setupChatRoomName()
        case .eventname:
            textLeftPadding = 15
            setupEventName()
        case .cvv:
            setupCvv()
        case .location:
            setupLocation()
        default:
            setDefaultTextField()
        }
    }
    
    /// Setup Error Label
    private func setupErrorLabel() {
        self.errorLabel.font = AppFonts.Regular.withSize(12)
        self.errorLabel.textColor = .red
        self.errorLabel.adjustsFontSizeToFitWidth = true
        self.errorLabel.textAlignment = .left
        errorLabel.numberOfLines = 0
        self.addSubview(self.errorLabel)
    }
    
    /// Setup Error Label Frames
    private func setupErrorLabelFrames() {
        
//        self.errorLabel.frame = CGRect(x: 0, y: self.frame.height,
//                                       width: self.frame.width, height: self.frame.height/2)
        self.errorLabel.frame = CGRect(x: 0, y: self.frame.height,
                                             width: self.frame.width, height: (self.frame.height)-20)
        
    }
    
    /// Show Button Tapped
    @objc private func revealPasswordBtnTapped(_ sender: UIButton) {
        isSecureTextEntry.toggle()
        sender.isSelected.toggle()
    }
}


// MARK:- Setup Functions
//==========================
extension AppTextField {
    
    
    private func removeRevealPasswordBtn() {
         rightView = nil
    }
    
    private func addRevealPasswordBtn() {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ic_password_unhide"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "ic-unhide-password"), for: .selected)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.addTarget(self, action: #selector(revealPasswordBtnTapped), for: .touchUpInside)
        revealPasswordBtn = button
        textRightPadding = 60
        rightView = revealPasswordBtn
        rightView?.frame.size = CGSize(width: 60, height: 60)
        rightViewMode = .always
    }
    
    private func addActivityLoader(){
        let activity = UIActivityIndicatorView(style: .gray)
        activity.color = AppColors.themeColor
        loader = activity
        rightView = loader
        rightView?.frame.size = CGSize(width: 60, height: 60)
        rightViewMode = .always
    }
    
    private func setDefaultTextField() {
        keyboardType = .default
    }
    
    private func setupEmailUsernameTF(){
        setPlaceHolder("Email")
        keyboardType = .emailAddress
        setIcon(#imageLiteral(resourceName: "ic_email_inactive"))
    }
    
    private func setupPasswordTF(){
        setPlaceHolder("Password")
        keyboardType = .default
        isSecured = true
        textContentType = .password
        setIcon(#imageLiteral(resourceName: "ic_password"))
        addRevealPasswordBtn()
    }
    
    private func setupFirstNameTF(){
        keyboardType = .alphabet
        autocapitalizationType = .words
        setPlaceHolder("First Name")
        
    }
    
    private func buddyTF(){
        textAlignment = .center
        attributedPlaceholder = NSAttributedString(string: "*name here*", attributes: [NSAttributedString.Key.font:AppFonts.Bold.withSize(32),NSAttributedString.Key.foregroundColor:UIColor.white])
        font = AppFonts.Bold.withSize(32)
        textColor = .white
        tintColor = .white
    }
    
    private func buddyEmptyTF(){
           textAlignment = .center
           attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.font:AppFonts.Bold.withSize(32),NSAttributedString.Key.foregroundColor:UIColor.white])
           font = AppFonts.Bold.withSize(32)
           textColor = .white
           tintColor = .white
       }
    
    private func setupLastNameTF(){
        keyboardType = .alphabet
        autocapitalizationType = .words
        setPlaceHolder("Full Name")
        setIcon(#imageLiteral(resourceName: "ic_user_name"))
    }
    
    private func setupDOBTF(){
        setPlaceHolder("Birth Date")
    }
    
    private func setupUserNameTF(){
        setPlaceHolder("Username")
        keyboardType = .emailAddress
        textContentType = .username
        autocorrectionType = .no
        loader?.isHidden = true
        setIcon(#imageLiteral(resourceName: "ic_user_name"))
        addActivityLoader()
    }
    
    private func setupCvv(){
        placeholder = "CVV"
        isSecureText = true
        keyboardType = .numberPad
        textLeftPadding = 10
        textRightPadding = 10
    }
    
    private func setupPhoneTF(){
        setPlaceHolder("Phone Number")
        keyboardType = .phonePad
        setIcon(#imageLiteral(resourceName: "ic_phone_number_inactive"))
    }
    
    private func setupCountryCode(){
        keyboardType = .phonePad
        textAlignment = .center
    }
    
    private func setupGeneric(){
        setIcon(#imageLiteral(resourceName: "ic_user_name"))
        setPlaceHolder("Username, phone or email")
        autocorrectionType = .no
        keyboardType = .emailAddress
        textAlignment = .left
    }
    
    private func setupChatRoomName(){
        setIcon(#imageLiteral(resourceName: "ic_chatroom_input"))
        setPlaceHolder("Room Name")
        keyboardType = .alphabet
        textAlignment = .left
    }
    
    private func setupEventName(){
        setIconOnRight(#imageLiteral(resourceName: "ic_black_arrow"))
        setPlaceHolder("Select Event Name")
        keyboardType = .alphabet
        textAlignment = .left
        
    }
    
    private func setupLocation(){
        setIcon(#imageLiteral(resourceName: "ic_location_info_light"))
        setPlaceHolder("My Location")
        keyboardType = .alphabet
        textAlignment = .left
    }
    
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
                                    CGRect(x: 15, y: (self.bounds.height/2) - 10, width: 20, height: 20))
        iconView.image = image
        iconView.contentMode = .center
        let iconContainerView: UIView = UIView(frame:
                                                CGRect(x: 25, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }

    func setIconOnRight(_ image: UIImage) {
        let iconView = UIImageView(frame:
                                    CGRect(x: 25, y: (self.bounds.height/2) - 10, width: 20, height: 20))
        iconView.image = image
        iconView.contentMode = .center
        let iconContainerView: UIView = UIView(frame:
                                                CGRect(x: 35, y: 0, width: 30, height: 30))
        iconView.isUserInteractionEnabled = false
        iconContainerView.addSubview(iconView)
        rightView = iconContainerView
        rightViewMode = .always
        rightView?.isUserInteractionEnabled = false
        leftView = nil
    }
    
    /// DOB TextField
    func setupDOBTextField(start: Date? = nil, end: Date? = nil, current: Date = Date(), didSelectDate: @escaping ((Date) -> Void)) {
        self.createDatePicker(start: start, end: end, current: current, didSelectDate: didSelectDate)
    }
    
    
    func setPlaceHolder(_ text:String){
        attributedPlaceholder =  NSAttributedString(string: text,
                                                    attributes: [NSAttributedString.Key.foregroundColor: AppColors.labelColor,
                                                                 NSAttributedString.Key.font:AppFonts.Regular.withSize(16)])
    }
   

    /// Create Picker
    //================
    func createPicker(stringsArray: [String], didSelectDate: @escaping ((String) -> Void)) {
        
        guard inputView == nil else { return }
        
        self.pickerData = stringsArray
        
        var picker = UIPickerView()
        
        /// Picker
        picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIDevice.width, height: 216))
        picker.backgroundColor = UIColor.white
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        self.inputView = picker

        // ToolBar
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain) { (_) in
            
            self.text = stringsArray[picker.selectedRow(inComponent: 0)]
            self.resignFirstResponder()
            
            didSelectDate(stringsArray[picker.selectedRow(inComponent: 0)])
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


// MARK:- Picker View Delegate and Datasource
//==============================================
extension AppTextField: UIPickerViewDelegate, UIPickerViewDataSource {

    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }
}

extension AppTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldShouldReturn?(textField as! AppTextField) ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (range.location == 0 && string == " ") ||  textField.textInputMode == nil {return false}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let editing = self.editingChange { editing()}
        }
        
        guard let userEnteredString = textField.text else { return false }
        let newString = (userEnteredString as NSString).replacingCharacters(in: range, with: string) as NSString
        let s = String(newString)
        switch setupAs {
        case .userName:
             if string == ""{
                return true
            }
            if string == " "{
                return false
            }
            if string == "@"{
                return false
            }
            if string.containsEmoji{
                return false
            }
            return true
        case .buddy,.buddyEmpty:
            if string == ""{
                return true
            }
            if string == " "{
                return false
            }else if s.count > 12{
                return false
            }else{
                return true
            }
        case .generic:
            if string == ""{
                return true
            }
            if string == " "{
                return false
            }
            if string.containsEmoji{
                return false
            }
            return true
        case .password:
            if string == ""{
                return true
            }
            if string == " "{
                return false
            }else if s.count > 30{
                return false
            }else{
                return true
            }
        case .firstname,.lastname:
            if string == ""{
                return true
            }
            if s.count < 40{
                return true
            }else{
                return false
            }
        case .otp:
            if string == ""{
                return true
            }
            if s.count > 8{
                return false
            }
            
            if (textField.text?.count == 3 && s.count == 4) {
               textField.text = textField.text! + "-" + string
                return false
            }
            
            if (textField.text?.count == 5 && s.count == 4) {
                let text = textField.text!
                textField.text = String(text.prefix(3))
                return false
            }
             return true
            
        case .phone:
            if string == ""{
                return true
            }
            if s.count > 12{
                return false
            }
            
            if (textField.text?.count == 3 && s.count == 4) || (textField.text?.count == 7 && s.count == 8){
                textField.text = textField.text! + "-" + string
                return false
            }
            if (textField.text?.count == 5 && s.count == 4) {
                let text = textField.text!
                textField.text = String(text.prefix(3))
                return false
            }else if (textField.text?.count == 9 && s.count == 8) {
                let text = textField.text!
                textField.text = String(text.prefix(7))
                return false
            }
            return true
        case .chatroom:
            if string == ""{
                return true
            }
            if s.count > 40{
                return false
            }
            return true
        case .countryCode:
            if string == ""{
                if s.count == 0{
                    return false
                }else{
                    return true
                }
            }
            if s.contains(s: "+") && string == "+"{
                return false
            }else{
                return true
            }
        case .creditCard:
            return formatCardNumber(textField: textField, shouldChangeCharactersInRange: range, replacementString: string)
        case .cvv:
            if string == ""{
                return true
            }
            if s.count > 3{
                return false
            }
            return true
        default:
            return true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.setBorder(width: 1, color: AppColors.selectedBorder)
        manageIcons(text: " ")
        if let edit = editingBegain { edit()}
        
    }
    
    func formatCardNumber(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let replacementStringIsLegal = string.rangeOfCharacter(from: NSCharacterSet(charactersIn: "0123456789").inverted) == nil
        
        if !replacementStringIsLegal {
            return false
        }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let components = newString.components(separatedBy: NSCharacterSet(charactersIn: "0123456789").inverted)
        let decimalString = components.joined(separator: "") as NSString
        let length = decimalString.length
        let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
        
        if length == 0 || (length > 16 && !hasLeadingOne) || length > 19 {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
            
            return (newLength > 16) ? false : true
        }
        var index = 0 as Int
        let formattedString = NSMutableString()
        
        if hasLeadingOne {
            formattedString.append("1 ")
            index += 1
        }
        if length - index > 4 {
            let prefix = decimalString.substring(with: NSRange(location: index, length: 4))
            formattedString.appendFormat("%@ ", prefix)
            index += 4
        }
        
        if length - index > 4 {
            let prefix = decimalString.substring(with: NSRange(location: index, length: 4))
            formattedString.appendFormat("%@ ", prefix)
            index += 4
        }
        if length - index > 4 {
            let prefix = decimalString.substring(with: NSRange(location: index, length: 4))
            formattedString.appendFormat("%@ ", prefix)
            index += 4
        }
        
        let remainder = decimalString.substring(from: index)
        formattedString.append(remainder)
        textField.text = formattedString as String
        return false
    }
        

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        manageIcons(text: textField.text ?? "")
        if let text = textField.text, !text.isEmpty{
            textField.setBorder(width: 1, color: AppColors.selectedBorder)
        }else{
            textField.setBorder(width: 1, color: AppColors.borderColor)
        }
        if let end = editingEnd { end()}
    }
    
    private func manageIcons(text:String){
        switch setupAs {
        case .email:
            if !text.isEmpty{
                setIcon(#imageLiteral(resourceName: "ic_email_active"))
            }else{
                setIcon(#imageLiteral(resourceName: "ic_email_inactive"))
            }
        case .password:
            if !text.isEmpty{
                setIcon(#imageLiteral(resourceName: "ic_password_active"))
            }else{
                setIcon(#imageLiteral(resourceName: "ic_password"))
            }
        case .userName,.generic:
            if !text.isEmpty{
                setIcon(#imageLiteral(resourceName: "ic_user_name_active"))
            }else{
                setIcon(#imageLiteral(resourceName: "ic_user_name"))
            }
        case .phone:
            if !text.isEmpty{
                setIcon(#imageLiteral(resourceName: "ic_phone_number_active"))
            }else{
                setIcon(#imageLiteral(resourceName: "ic_phone_number_inactive"))
            }
        case .chatroom:
            if !text.isEmpty{
                setIcon(#imageLiteral(resourceName: "ic_chatroom_input_active"))
            }else{
                setIcon(#imageLiteral(resourceName: "ic_chatroom_input"))
            }
        case .lastname:
            if !text.isEmpty{
                setIcon(#imageLiteral(resourceName: "ic_user_name_active"))
            }else{
                setIcon(#imageLiteral(resourceName: "ic_user_name"))
            }
        case .location:
            if !text.isEmpty{
                setIcon(#imageLiteral(resourceName: "ic_location_info"))
            }else{
                setIcon(#imageLiteral(resourceName: "ic_location_info_light"))
            }
        default:
            printDebug("Do noting...")
        }
    }
}




class MarginLabel: UILabel {
    
    /// Draw Text
    override func drawText(in rect: CGRect) {
        let rect = CGRect(x: bounds.origin.x+10, y: bounds.origin.y,
                          width: bounds.width-20, height: bounds.height)
        super.drawText(in: rect)
    }
}

// MARK:- Margin TextField
//===========================
class MarginTextField: UITextField {
    
    /// Draw Text
    override func drawText(in rect: CGRect) {
        let rect = CGRect(x: bounds.origin.x+20, y: rect.origin.y + 4,
                          width: rect.width-30, height: rect.height - 4)
        super.drawText(in: rect)
    }
    
    /// Text Rect
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = CGRect(x: bounds.origin.x+20, y: bounds.origin.y + 4,
                          width: bounds.width-30, height: bounds.height - 4)
        return super.textRect(forBounds: rect)
    }
    
    /// Alignment Rect
    override func alignmentRect(forFrame frame: CGRect) -> CGRect {
        let rect = CGRect(x: bounds.origin.x+20, y: frame.origin.y + 4,
                          width: frame.width-30, height: frame.height - 4)
        return super.alignmentRect(forFrame: rect)
    }
    
    /// Editing Rect
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = CGRect(x: bounds.origin.x+20, y: bounds.origin.y + 4,
                          width: bounds.width-30, height: bounds.height - 4)
        return super.editingRect(forBounds: rect)
    }
    
    /// Placeholder Rect
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let rect = CGRect(x: bounds.origin.x + 25, y: bounds.origin.y + 4,
                          width: bounds.width - 35, height: bounds.height - 4)
        return super.placeholderRect(forBounds: rect)
    }
}
