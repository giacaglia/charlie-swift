//
//  Response.swift
//  BladeKit
//
//  Created by Doug on 4/2/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import Foundation

public class ServerResponse : BaseObject {
    public var error : NSError?
    public var rawResponse : NSHTTPURLResponse?
    public var genericResults: AnyObject = [:]
    
    /**
    The main access point for the response body of a given request. In subclasses, this can/should be overriden to return what the subclass deems an appropriate 'result'

    - returns: AnyObject So consider using *if let ... as? __something__*
    */
    public func results() -> AnyObject {
        return self.genericResults
    }
}
