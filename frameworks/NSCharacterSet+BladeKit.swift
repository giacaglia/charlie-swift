//
//  NSCharacterSet+BladeKit.swift
//  BladeKit
//
//  Created by Brian Bates on 4/29/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import Foundation

extension NSCharacterSet {
    
    // Determine if a given Character is contained in this set
    public func containsCharacter(character: Character) -> Bool {
        let string = String(character)
        let start = string.startIndex
        let end = string.endIndex
        let result = string.rangeOfCharacterFromSet(self, options: [], range: start..<end)
        return result != nil
    }
}