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

open class ServerRequest : BaseObject {
    
    open var headerDict = Dictionary<String,String>()
    open var url : URL?
    open var httpMethod : HTTPMethod = .Get
    open var timeoutOverride = ServerClient.urlTimeout

    open var parameters : [String:AnyObject]?
    open var parsingClosure : ((_ data: Data?, _ error: NSError?) -> ServerResponse) = {data, error in
        let sr = ServerResponse()
        if error != nil || data == nil {
            sr.error = error
        } else {
            if let rd = data {
                // default to JSON Serialization
                if let parsed: AnyObject = try? JSONSerialization.jsonObject(with: rd, options: JSONSerialization.ReadingOptions.mutableContainers) {
                    sr.genericResults = parsed
                }
            }
        }
        return sr
    }
    
    public convenience init(url : URL?) {
        self.init()
        self.url = url
    }
    
    open func urlRequest() -> NSMutableURLRequest {
        let req = NSMutableURLRequest()
        req.timeoutInterval = timeoutOverride
        for (key, value) in self.headerDict {
            req.setValue(value, forHTTPHeaderField: key)
        }
        req.url = url
        req.httpMethod = self.httpMethod.rawValue
        if let params = parameters {
            var error: NSError?
            switch self.httpMethod {
            case .Post:
                let options = JSONSerialization.WritingOptions()
                do {
                    let data = try JSONSerialization.data(withJSONObject: params, options: options)
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.httpBody = data
                } catch let error1 as NSError {
                    error = error1
                }
                if error != nil {
                    let e = NSException(name:NSExceptionName(rawValue: "BladeKit Exception"), reason:"BLADEKIT error with serializing parameters", userInfo:nil)
                    e.raise()
                }
            default:
                let e = NSException(name:NSExceptionName(rawValue: "BladeKit Exception"), reason:"BLADEKIT only supports JSON and POST for raw params at the moment", userInfo:nil)
                e.raise()
            }
        }
        return req
    }
}
