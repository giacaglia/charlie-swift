//
//  NSDate+BladeKit.swift
//  BladeKit
//
//  Created by Doug on 4/21/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import Foundation

public extension NSDate {
    
    private static var standardDateDisplay: NSDateFormatter = {
        let df = NSDateFormatter()
        df.timeStyle = .ShortStyle
        df.dateStyle = .ShortStyle
        return df
    }()
    
    /**
    Calculate a rough approximate relative time and get a display string.
    
    - returns: String A formatted display string, such as *just now* or *12 seconds ago*.
    */
    public func relativeTimeDisplay() -> String {
        let time = self.timeIntervalSince1970
        let now = NSDate().timeIntervalSince1970
        
        let seconds = now - time
        let minutes = round(seconds/60)
        let hours = round(minutes/60)
        let days = round(hours/24)
        let months = round(days/30) // This isn't quite perfect. TODO: A more formal solution
        if seconds < 10 {
            return NSLocalizedString("just now", comment: "relative time")
        } else if seconds < 60 {
            return NSLocalizedString("\(Int(seconds)) seconds ago", comment: "relative time")
        }
        
        if minutes < 60 {
            if minutes == 1 {
                return NSLocalizedString("1 minute ago", comment: "relative time")
            } else {
                return NSLocalizedString("\(Int(minutes)) minutes ago", comment: "relative time")
            }
        }
        
        if hours < 24 {
            if hours == 1 {
                return NSLocalizedString("1 hour ago", comment: "relative time")
            } else {
                return NSLocalizedString("\(Int(hours)) hours ago", comment: "relative time")
            }
        }
        
        if days < 30 {
            if days == 1 {
                return NSLocalizedString("1 day ago", comment: "relative time")
            } else {
                return NSLocalizedString("\(Int(days)) days ago", comment: "relative time")
            }
        }

        if months < 12 {
            if months == 1 {
                return NSLocalizedString("1 month ago", comment: "relative time")
            } else {
                return NSLocalizedString("\(Int(months)) months ago", comment: "relative time")
            }
        }
        
        return NSDate.standardDateDisplay.stringFromDate(self)
    }
    
    public func genericDateDisplay() -> String {
        return NSDate.standardDateDisplay.stringFromDate(self)
    }
}
