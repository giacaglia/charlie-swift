//
//  charlieGroup.swift
//  Charlie
//
//  Created by Jim Caralis on 8/20/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import Foundation
import RealmSwift

class charlieGroup : Object {
    dynamic var name:            String = ""
    dynamic var worthCount:      Int    = 0
    dynamic var notWorthCount:   Int    = 0
    dynamic var worthValue:      Double = 0
    dynamic var notWorthValue:   Double = 0
    dynamic var happyPercentage: Int    = 0
    dynamic var date:            NSDate = NSDate()
    
    var transactions : Int {
        get {
            return worthCount + notWorthCount
        }
    }
    override static func primaryKey() -> String? {
        return "name"
    }
}