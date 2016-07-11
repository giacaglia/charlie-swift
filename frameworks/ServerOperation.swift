//
//  BaseOperation.swift
//  BladeKit
//
//  Created by Doug on 4/2/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import Foundation

public class ServerOperation : NSOperation {
    
    public var request: ServerRequest
    public var response: ServerResponse
    
    public init(request: ServerRequest) {
        self.request = request
        self.response = ServerResponse()
        super.init()
    }
    
    override public func main() {
        let urlReq = self.request.urlRequest()
        var err: NSError?
        var response: NSURLResponse?
        let data: NSData?
        do {
            data = try NSURLConnection.sendSynchronousRequest(urlReq, returningResponse: &response)
        } catch let error as NSError {
            err = error
            data = nil
        }
        self.response = self.request.parsingClosure(data:data, error:err)
        self.response.rawResponse = response as? NSHTTPURLResponse
    }
}
