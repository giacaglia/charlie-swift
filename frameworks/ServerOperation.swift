//
//  BaseOperation.swift
//  BladeKit
//
//  Created by Doug on 4/2/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import Foundation

open class ServerOperation : Operation {
    
    open var request: ServerRequest
    open var response: ServerResponse
    
    public init(request: ServerRequest) {
        self.request = request
        self.response = ServerResponse()
        super.init()
    }
    
    override open func main() {
        let urlReq = self.request.urlRequest()
        var err: NSError?
        var response: URLResponse?
        let data: Data?
        do {
            data = try NSURLConnection.sendSynchronousRequest(urlReq as URLRequest, returning: &response)
        } catch let error as NSError {
            err = error
            data = nil
        }
        self.response = self.request.parsingClosure(data as NSData?, err)
        self.response.rawResponse = response as? HTTPURLResponse
    }
}
