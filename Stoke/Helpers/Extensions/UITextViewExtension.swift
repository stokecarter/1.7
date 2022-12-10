//
//  UITextViewExtension.swift
//  JobCaster
//
//  Created by Appinventiv on 25/08/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit

// MARK: - Methods
public extension UITextView {
    
    /// SwifterSwift: Scroll to the bottom of text view
    public func scrollToBottom() {
        let range = NSMakeRange((text as NSString).length - 1, 1)
        scrollRangeToVisible(range)
    }
    
    /// SwifterSwift: Scroll to the top of text view
    public func scrollToTop() {
        let range = NSMakeRange(0, 1)
        scrollRangeToVisible(range)
    }
    
    /// Check Empty Text View 
    public func validate() -> Bool {
        
        guard let text =  self.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }
}
