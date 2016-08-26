//
//  Extensions.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 12/7/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//

import Foundation

extension Date {
    func startOfMonth() -> Date? {
        let calendar = NSCalendar.current
        let currentDateComponents = (calendar as NSCalendar).components([.year, .monthSymbols], from: self)
        let startOfMonth = calendar.date(from: currentDateComponents)
        return startOfMonth
    }
    
    func dateByAddingMonths(_ monthsToAdd: Int) -> Date? {
        let calendar = NSCalendar.current
        var months = DateComponents()
        months.month = monthsToAdd
        return (calendar as NSCalendar).date(byAdding: months, to: self, options: [])
    }
    

    func monthsFrom(_ date:Date) -> Int{
        return NSCalendar.current.components(.monthSymbols, from: date, to: self, options: []).month
    }
    
    func dateByAddingDays(_ daysToAdd: Int) -> Date? {
        let calendar = NSCalendar.current
        var days = DateComponents()
        days.day = daysToAdd
        return (calendar as NSCalendar).date(byAdding: days, to: self, options: [])
    }
    
    func endOfMonth() -> Date? {
        //let calendar = NSCalendar.currentCalendar()
        if let plusOneMonthDate = dateByAddingMonths(1) {
            
            let plusOneBegining = plusOneMonthDate.startOfMonth()
            
            let endOfMonth = plusOneBegining?.dateByAddingDays(-1)
            
            return endOfMonth
        }
        return nil
    }

    func monthString() -> String {
        let calendar = NSCalendar.current
        let currentDateComponents = (calendar as NSCalendar).components([.monthSymbols], from: self)
        let month = currentDateComponents.month
        return Date.abbrMonthArray()[month - 1]
    }
    
    static func abbrMonthArray() -> [String] {
        return ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    }
}

extension NSString {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}

extension NSAttributedString {
    static func createAttributedString(_ font: UIFont, string1: String, color1: UIColor, string2: String, color2: UIColor) -> NSAttributedString {
        let attrsA = [NSFontAttributeName: font, NSForegroundColorAttributeName: color1]
        let a = NSMutableAttributedString(string:string1, attributes:attrsA)
        let attrsB = [NSFontAttributeName: font, NSForegroundColorAttributeName: color2]
        let b = NSAttributedString(string:string2, attributes:attrsB)
        a.append(b)
        return a
    }
    
    static func twoFontsAttributedString(_ string1: String, font1: UIFont, color1: UIColor, string2: String, font2: UIFont, color2: UIColor) -> NSAttributedString {
        let attrsA = [NSFontAttributeName: font1, NSForegroundColorAttributeName: color1]
        let a = NSMutableAttributedString(string:string1, attributes:attrsA)
        let attrsB = [NSFontAttributeName: font2, NSForegroundColorAttributeName: color2]
        let b = NSAttributedString(string:string2, attributes:attrsB)
        a.append(b)
        return a
    }
}

extension UIColor {
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
}
