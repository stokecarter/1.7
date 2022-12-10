//
//  UILabelExtension.swift
//  MaanBeta
//
//  Created by Appinventiv on 04/07/18.
//  Copyright © 2018 Bhavneet Singh. All rights reserved.
//

import Foundation
import UIKit
    
class InsetLabel: UILabel {
    
    var setTopInset = CGFloat(0)
    var setBottomInset = CGFloat(0)
    var setLeftInset = CGFloat(0)
    var setRightInset = CGFloat(0)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: setTopInset, left: setLeftInset, bottom: setBottomInset, right: setRightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += setTopInset + setBottomInset
        intrinsicSuperViewContentSize.width += setLeftInset + setRightInset
        return intrinsicSuperViewContentSize
    }
    
    func edgeInsets(topInset: CGFloat, bottomInset: CGFloat, leftInset: CGFloat, rightInset: CGFloat) {
        
        setTopInset = topInset
        setBottomInset = bottomInset
        setLeftInset = leftInset
        setRightInset = rightInset
    }
}

