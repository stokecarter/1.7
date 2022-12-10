//
//  AppFonts.swift
//  DannApp
//
//  Created by Aakash Srivastav on 20/04/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import UIKit


enum AppFonts : String {
    case heavy = "SFProText-Heavy"
    case Regular = "SFProText-Regular"
    case Medium = "SFProText-Medium"
    case Bold = "SFProText-Bold"
    case Semibold = "SFProText-Semibold"
}

extension AppFonts {
    
    func withSize(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    func withDefaultSize() -> UIFont {
        return UIFont(name: self.rawValue, size: 12.0) ?? UIFont.systemFont(ofSize: 12.0)
    }
    
}
