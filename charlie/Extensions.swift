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

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
}
