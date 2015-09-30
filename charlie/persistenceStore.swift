//
//  persistenceStore.swift
//  charlie
//
//  Created by James Caralis on 8/4/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import Foundation
import CloudKit


class persistenceStore {
    var access_token:String
    var uuid:String?
    var email:String?
    
    init(access_token:String) {
        self.access_token = access_token
    }
    
    func isActive() -> Bool {
        if var _:NSURL = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil) {
            print("True")
            return true
        }
        else {
            print("False")
            return false
        }
    }    
}