//
//  Request.swift
//  BladeKit
//
//  Created by Doug on 4/2/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case Options = "OPTIONS"
    case Get = "GET"
    case Head = "HEAD"
    case Post = "POST"
    case Put = "PUT"
    case Delete = "DELETE"
}

public class ServerRequest : BaseObject {
    
    public var headerDict = Dictionary<String,String>()
    public var url : NSURL?
    public var httpMethod : HTTPMethod = .Get
    public var timeoutOverride = ServerClient.urlTimeout

    public var parameters : [String:AnyObject]?
    public var parsingClosure : ((data: NSData?, error: NSError?) -> ServerResponse) = {data, error in
        let sr = ServerResponse()
        if error != nil || data == nil {
            sr.error = error
        } else {
            if let rd = data {
                // default to JSON Serialization
                if let parsed: AnyObject = try? NSJSONSerialization.JSONObjectWithData(rd, options: NSJSONReadingOptions.MutableContainers) {
                    sr.genericResults = parsed
                }
            }
        }
        return sr
    }
    
    public convenience init(url : NSURL?) {
        self.init()
        self.url = url
    }
    
    public func urlRequest() -> NSMutableURLRequest {
        let req = NSMutableURLRequest()
        req.timeoutInterval = timeoutOverride
        for (key, value) in self.headerDict {
            req.setValue(value, forHTTPHeaderField: key)
        }
        req.URL = url
        req.HTTPMethod = self.httpMethod.rawValue
        if let params = parameters {
            var error: NSError?
            switch self.httpMethod {
            case .Post:
                let options = NSJSONWritingOptions()
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(params, options: options)
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.HTTPBody = data
                } catch let error1 as NSError {
                    error = error1
                }
                if error != nil {
                    let e = NSException(name:"BladeKit Exception", reason:"BLADEKIT error with serializing parameters", userInfo:nil)
                    e.raise()
                }
            default:
                let e = NSException(name:"BladeKit Exception", reason:"BLADEKIT only supports JSON and POST for raw params at the moment", userInfo:nil)
                e.raise()
            }
        }
        return req
    }
}
