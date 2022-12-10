//
//  StringExtention.swift
//  WoshApp
//
//  Created by Saurabh Shukla on 19/09/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//


import Foundation
import UIKit

extension String {
    
    ///Removes all spaces from the string
    var removeSpaces:String{
        return self.replacingOccurrences(of: " ", with: "")
    }

    ///Removes all HTML Tags from the string
    var removeHTMLTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }

    ///Returns a localized string
    var localized:String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    ///Removes leading and trailing white spaces from the string
    var byRemovingLeadingTrailingWhiteSpaces:String {
        
        let spaceSet = CharacterSet.whitespaces
        return self.trimmingCharacters(in: spaceSet)
    }
    
    public func trimTrailingWhitespace() -> String {
        if let trailingWs = self.range(of: "\\s+$", options: .regularExpression) {
            return self.replacingCharacters(in: trailingWs, with: "")
        } else {
            return self
        }
    }
    ///Returns 'true' if the string is any (file, directory or remote etc) url otherwise returns 'false'
    var isAnyUrl:Bool{
        return (URL(string:self) != nil)
    }
    
    ///Returns the json object if the string can be converted into it, otherwise returns 'nil'
    var jsonObject:Any? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        return nil
    }
    
    ///Returns the base64Encoded string
    var base64Encoded:String {
        
        return Data(self.utf8).base64EncodedString()
    }
    
    ///Returns the string decoded from base64Encoded string
    var base64Decoded:String? {
        
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func heightOfText(_ width: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
    
    func widthOfText(_ height: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.width
    }

    func localizedString(lang:String) ->String {
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        printDebug(path)
        let bundle = Bundle(path: path!)
        printDebug(bundle)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    ///Returns 'true' if string contains the substring, otherwise returns 'false'
    func contains(s: String) -> Bool
    {
        return self.range(of: s) != nil ? true : false
    }
    
    ///Replaces occurances of a string with the given another string
    func replace(string: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: string, with: withString, options: String.CompareOptions.literal, range: nil)
    }
    
    ///Converts the string into 'Date' if possible, based on the given date format and timezone. otherwise returns nil
    func toDate(dateFormat:String,timeZone:TimeZone = TimeZone.current)->Date?{
        
        let frmtr = DateFormatter()
//        frmtr.locale = Locale(identifier: "en_US_POSIX")
        frmtr.dateFormat = dateFormat
//        frmtr.timeZone = timeZone
        return frmtr.date(from: self)
    }

    func toDateText(inputDateFormat: String, outputDateFormat: String, timeZone: TimeZone = TimeZone.current) -> String{
        
        if let date = self.toDate(dateFormat: inputDateFormat, timeZone: timeZone) {
            return date.toString(dateFormat: outputDateFormat, timeZone: timeZone)
        } else {
            return ""
        }
    }

    func checkIfValid(_ validityExression : ValidityExression) -> Bool {
        
        let regEx = validityExression.rawValue
        
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        
        return test.evaluate(with: self)
    }
    
    func checkIfInvalid(_ validityExression : ValidityExression) -> Bool {
        
        return !self.checkIfValid(validityExression)
    }
    
    ///Capitalize the very first letter of the sentence.
    var capitalizedFirst: String {
        guard !isEmpty else { return self }
        var result = self
        let substr1 = String(self[startIndex]).uppercased()
        result.replaceSubrange(...startIndex, with: substr1)
        return result
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}

extension String {
    
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? self.removeHTMLTags
    }
}

enum ValidityExression : String {
    
    case userName = ##"^(?=.*[a-zA-Z])[a-zA-Z0-9!#$%^&*()_?\-\/+.]+$"##//"/^(?=.*a-zA-Z)[a-zA-Z0-9!#$%^&*()_?\\-\\/+.]+$/"
    //"^(?=.*\\d)(?=.*\\D)([a-zA-Z0-9!@_#$%&*]{3,30})$"
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9-]+\\.[A-Za-z]{2,}"
    case mobileNumber = "^[0-9]{6,20}$"
    case password = "^[a-zA-Z0-9!@#$%&*]{8,}"
    case name = "^[a-zA-Z]{2,15}"
    case webUrl = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
}

extension String {

    func isAlphanumeric() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }

    func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
        if ignoreDiacritics {
            return self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && self != ""
        }
        else {
            return self.isAlphanumeric()
        }
    }

}

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    
    func grouping(every groupSize: String.IndexDistance, with separator: Character) -> String {
           let cleanedUpCopy = replacingOccurrences(of: String(separator), with: "")
           return String(cleanedUpCopy.enumerated().map() {
                $0.offset % groupSize == 0 ? [separator, $0.element] : [$0.element]
           }.joined().dropFirst())
        }
    
    
}


extension Double{
    
    func removeZerosFromEnd() -> String {
        let s = String(self)
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = (s.components(separatedBy: ".").last)!.count
        return String(formatter.string(from: number) ?? "")
    }
    
    var toCurrency:String{
        return "$\(removeZerosFromEnd())"
    }
    
}

extension String{
    
    func insertTrustedBadge(after name:String) -> NSAttributedString{
        let st = NSAttributedString(string: self.replace(string: name, withString: ""))
        let font = AppFonts.Regular.withSize(14)
        let badge = NSTextAttachment()
        badge.image = #imageLiteral(resourceName: "ic-user-trusted")
        badge.bounds = CGRect(x: 0.0, y: font.descender, width: badge.image!.size.width, height: badge.image!.size.height)
        let imageString = NSAttributedString(attachment: badge)
        let finalAttributedString = NSMutableAttributedString(string: name + " ")
        finalAttributedString.append(imageString)
        finalAttributedString.append(st)
        return finalAttributedString
    }
    
    var removeEmoji:String{
        return self.unicodeScalars
            .filter { !$0.properties.isEmojiPresentation}
            .reduce("") { $0 + String($1) }
    }
}
