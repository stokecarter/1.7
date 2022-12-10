//
//  UIDeviceExtension.swift
//  DittoFashionMarketBeta
//
//  Created by Appinventiv Technologies on 06/02/18.
//  Copyright © 2018 Bhavneet Singh. All rights reserved.
//

import AVFoundation
import UIKit

// MARK:- UIDEVICE
//==================
extension UIDevice {
    
    static let size = UIScreen.main.bounds.size
    
    static let height = UIScreen.main.bounds.height
    
    static let width = UIScreen.main.bounds.width

    @available(iOS 11.0, *)
    static var bottomSafeArea = UIApplication.shared.keyWindow!.safeAreaInsets.bottom

    @available(iOS 11.0, *)
    static let topSafeArea = UIApplication.shared.keyWindow!.safeAreaInsets.top
    
    static func vibrate() {
        let feedback = UIImpactFeedbackGenerator.init(style: UIImpactFeedbackGenerator.FeedbackStyle.heavy)
        feedback.prepare()
        feedback.impactOccurred()
    }
}
