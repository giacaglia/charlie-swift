//
//  charlieGroup.swift
//  Charlie
//
//  Created by Jim Caralis on 8/20/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import Foundation


class charlieGroup {
    var name:            String
    var lastDate:        String
    var worthCount:      Int    = 0
    var notWorthCount:   Int    = 0
    var notSwipedCount:   Int    = 0
    var worthValue:      Double = 0
    var notSwipedValue:      Double = 0
    var notWorthValue:   Double = 0
    var happyPercentage: Int    = 0
    var totalAmount:     Double = 0

    init(name:String, lastDate:String) {
        self.name = name
        self.lastDate = lastDate
    }
    
    var transactions : Int {
        get {
            return worthCount + notWorthCount + notSwipedCount
        }
    }
   
}


