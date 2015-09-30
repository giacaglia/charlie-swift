//
//  charlieAnalytics.swift
//  charlie
//
//  Created by Jim Caralis on 8/4/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import Foundation

class charlieAnalytics {
    class func track(name:String) {
        var properties:[String:AnyObject] = [:]
        
        if users.count > 0 {
            properties["user_id"] = users[0].email
        }
        
        Mixpanel.sharedInstance().track(name, properties: properties)
    }
}