//
//  NSError+BladeKit.swift
//  BladeKit
//
//  Created by Doug on 4/6/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import Foundation

public extension NSError {
    public class func errorWithDomain(_ domain: String, code:Int, localizedDescription:String) -> NSError {
        return NSError(domain: domain, code: code, userInfo:[NSLocalizedDescriptionKey:localizedDescription])
    }
}
