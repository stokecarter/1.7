//
//  AppButton.swift
//  Onboarding
//
//  Created by Bhavneet Singh on 06/07/18.
//  Copyright © 2018 Gurdeep Singh. All rights reserved.
//

import UIKit

class AppButton: UIButton {

    // MARK: Enums
    //==============
    enum CustomButtonType {
        case themeColor, whiteColor, themeRound, whiteRound, facebook, google, apple, noborder
    }
    
    // MARK: Variables
    //===================
    var btnType = CustomButtonType.themeColor {
        didSet{
            self.setupSubviews()
        }
    }
    
    // MARK: Initializers
    //=====================
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupSubviews()
    }
    
    // MARK: Life Cycle Functions
    //==============================
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupLayouts()
    }
}

// MARK: Private Functions
//==========================
extension AppButton {
    
    /// Setup Subviews
    private func setupSubviews() {
        self.titleLabel?.font = AppFonts.Medium.withSize(18)
        switch btnType {
        case .themeColor:
            self.backgroundColor = AppColors.themeColor
            self.setTitleColor(AppColors.whiteColor, for: .normal)
            self.layer.borderWidth = CGFloat.leastNormalMagnitude
            self.layer.cornerRadius = 10
        case .whiteColor:
            self.backgroundColor = AppColors.whiteColor
            self.setTitleColor(AppColors.themeColor, for: .normal)
            self.layer.borderColor = AppColors.borderColor.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 10
        case .facebook,.apple,.google:
            self.backgroundColor = AppColors.whiteColor
            self.setTitleColor(.black, for: .normal)
            self.layer.borderColor = AppColors.borderColor.cgColor
            self.layer.borderWidth = 1
            addTextandIconOnBtn(type: btnType)
            self.layer.cornerRadius = 10
        case .themeRound:
            self.backgroundColor = AppColors.themeColor
            self.setTitleColor(AppColors.whiteColor, for: .normal)
            self.layer.borderWidth = CGFloat.leastNormalMagnitude
            DispatchQueue.main.async {
                self.layer.cornerRadius = self.bounds.height/2
            }
        case .whiteRound:
            self.backgroundColor = AppColors.whiteColor
            self.setTitleColor(AppColors.labelColor, for: .normal)
            self.setBorder(width: 1, color: AppColors.borderColor)
            DispatchQueue.main.async {
                self.layer.cornerRadius = self.bounds.height/2
            }
        case .noborder:
            self.backgroundColor = .clear
            self.setTitleColor(AppColors.themeColor, for: .normal)
            self.setBorder(width: CGFloat.leastNormalMagnitude, color: .clear)
            DispatchQueue.main.async {
                self.layer.cornerRadius = 0
            }
        }
        self.clipsToBounds = true
        
    }
    
    /// Setup Layouts
    private func setupLayouts() {
        
//        self.layer.cornerRadius = 10
    }
    
    private func addTextandIconOnBtn(type:CustomButtonType){
        var title = ""
        var img:UIImage?
        switch type {
        case .google:
            img = #imageLiteral(resourceName: "google")
            title = "Google"
        case .apple:
            img = #imageLiteral(resourceName: "ic_apple")
            title = "Apple"
        default:
            img = #imageLiteral(resourceName: "facebook")
            title = "Facebook"
        }
        contentHorizontalAlignment = .left
        setImage(img, for: .normal)
        setTitle(title, for: .normal)
        imageEdgeInsets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 10)
        titleEdgeInsets = UIEdgeInsets(top: 5, left: 45, bottom: 5, right: 0)
        self.titleLabel?.font = AppFonts.Regular.withSize(16)
    }
}

// MARK: Functions
//===================
extension AppButton {
    

}
