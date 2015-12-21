//
//  Extensions.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 12/7/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//

import Foundation

extension NSDate {
    func startOfMonth() -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let currentDateComponents = calendar.components([.Year, .Month], fromDate: self)
        let startOfMonth = calendar.dateFromComponents(currentDateComponents)
        return startOfMonth
    }
    
    func dateByAddingMonths(monthsToAdd: Int) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let months = NSDateComponents()
        months.month = monthsToAdd
        return calendar.dateByAddingComponents(months, toDate: self, options: [])
    }
    

    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    
    func dateByAddingDays(daysToAdd: Int) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let days = NSDateComponents()
        days.day = daysToAdd
        return calendar.dateByAddingComponents(days, toDate: self, options: [])
    }
    
    func endOfMonth() -> NSDate? {
        //let calendar = NSCalendar.currentCalendar()
        if let plusOneMonthDate = dateByAddingMonths(1) {
            
            let plusOneBegining = plusOneMonthDate.startOfMonth()
            
            let endOfMonth = plusOneBegining?.dateByAddingDays(-1)
            
            return endOfMonth
        }
        return nil
    }

    func monthString() -> String {
        let calendar = NSCalendar.currentCalendar()
        let currentDateComponents = calendar.components([.Month], fromDate: self)
        let month = currentDateComponents.month
        return NSDate.abbrMonthArray()[month - 1]
    }
    
    static func abbrMonthArray() -> [String] {
        return ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    }
}

extension NSString {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
}

extension NSAttributedString {
    static func createAttributedString(font: UIFont, string1: String, color1: UIColor, string2: String, color2: UIColor) -> NSAttributedString {
        let attrsA = [NSFontAttributeName: font, NSForegroundColorAttributeName: color1]
        let a = NSMutableAttributedString(string:string1, attributes:attrsA)
        let attrsB = [NSFontAttributeName: font, NSForegroundColorAttributeName: color2]
        let b = NSAttributedString(string:string2, attributes:attrsB)
        a.appendAttributedString(b)
        return a
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
}
