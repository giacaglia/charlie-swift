//
//  String+Formatting.swift
//  BladeKit
//
//  Originally Created by Brian Bates on 4/14/15.
//  Added to BladeKit by Doug 4/14/15
//  Copyright (c) 2015 Blade. All rights reserved.
//

import Foundation

public extension String {
    
    // Ability to pass an integer range in string subscripts
    public subscript(range: Range<Int>) -> String? {
        get {
            if range.startIndex < 0 || range.startIndex > self.characters.count ||
                range.endIndex > self.characters.count {
                    return nil
            }
            return self.simpleSubstring(range.startIndex, end: range.endIndex)
        }
    }
    
    // Ability to pass an integer index for a string subscript
    // Returns nill if invalid index passed
    public subscript(index: Int) -> Character? {
        get {
            if index < 0 || index > self.characters.count {
                return nil
            }
            let idx = self.startIndex.advancedBy(index)
            // safety
            if idx == self.endIndex {
                return nil
            } else {
                return self[idx]
            }
        }
    }
    
    // Get a formatted phone number representation of the given string.
    // If the string cannot be parsed as a valid phone number, then return nil
    // NOTE: Currently only supports US phone numbers
    public var asPhoneNumber: String? {
        if self == "" {
            return nil
        }
        
        let numberComponents = self.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let numbersOnly = numberComponents.joinWithSeparator("")
        
        var formatted : String? = nil
        if numbersOnly.characters.count == 11 && numbersOnly[0] == "1" {
            //let firstThree: String! = numbersOnly.simpleSubstring(1, end: 3)
            let firstThree: String! = numbersOnly[1...3]
            let secondThree: String! = numbersOnly[4...6]
            let lastFour: String! = numbersOnly[7...10]
            formatted = "1-\(firstThree)-\(secondThree)-\(lastFour)"
        } else if numbersOnly.characters.count == 10 {
            //let firstThree: String! = numbersOnly.simpleSubstring(0, end: 2)
            let firstThree: String! = numbersOnly[0...2]
            let secondThree: String! = numbersOnly[3...5]
            let lastFour: String! = numbersOnly[6...9]
            formatted = "(\(firstThree)) \(secondThree)-\(lastFour)"
        } else if numbersOnly.characters.count == 7 {
            let firstThree: String! = numbersOnly[0...2]
            let lastFour: String! = numbersOnly[3...6]
            formatted = "\(firstThree)-\(lastFour)"
        }
        return formatted
    }
    
    public func doesContainSubstring(subsr: String) -> Bool {
        return (self.lowercaseString.rangeOfString(subsr.lowercaseString) != nil)
    }

    
    // Get substring between start and end, inclusive on for the start, non-inclusive for the end
    private func simpleSubstring(start:Int, end:Int) -> String? {
        return self.substringWithRange(Range<String.Index>(self.startIndex.advancedBy(start)..<self.startIndex.advancedBy(end)))
    }
    
    // See if a string contains only items in the given character set
    public func containsOnlyCharactersInSet(set: NSCharacterSet) -> Bool {
        for character in self.characters {
            if !set.containsCharacter(character) {
                return false
            }
        }
        return true
    }
    
    public func rangeOfFirstStringMatchingUrlRegex() -> Range<String.Index>? {
        // https://mathiasbynens.be/demo/url-regex
        // using @imme-emosol for simplicity, removing the beginning and ending mod
        let urlRegex = "(https?|ftp)://(-\\.)?([^\\s/?\\.#-]+\\.?)+(/[^\\s]*)?"
        return self.rangeOfStringMatchingRegex(urlRegex)
    }
    
    public func rangeOfStringMatchingRegex(regex: String) -> Range<String.Index>? {
        return self.rangeOfString(regex, options: ([.RegularExpressionSearch, .CaseInsensitiveSearch]))
    }
    
    // Replace characters in range using NSRange (useful when using the UITextField delegate)
    func stringByReplacingCharactersInRange(range: NSRange, withString replacement: String) -> String {
        return (self as NSString).stringByReplacingCharactersInRange(range, withString: replacement)
    }
}