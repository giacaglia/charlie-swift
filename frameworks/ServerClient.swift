//
//  ServerClient.swift
//  BladeKit
//
//  Created by Doug on 4/1/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import Foundation

public final class ServerClient {
    
    public static var urlTimeout: TimeInterval = 30
    
    // MARK: Internal OperationQueue
    fileprivate let operationQueue : OperationQueue = {
        let opQueue = OperationQueue()
        opQueue.maxConcurrentOperationCount = 5
        return opQueue
    }()
    
    // MARK: - Singleton
    fileprivate static let sharedInstance = ServerClient()
    
    // MARK: - Making Requests
    /**
    The main networking call, which will run asynchronously on a NSOperationQueue.
    
    - parameter request: The configured ServerRequest object with a variety of interesting information for your networking call.
    - parameter delayedStart: Should the ServerClient start the request immediately. Useful for operation dependencies or otherwise configuring starting the requests at a different time. Default is `false`, (ie, begin immediately)
    - parameter completion: A completion block containing the ServerResponse after the networking call is completed, this will be called on the main thread.

    - returns: NSOperation
    */
    public class func performRequest(_ request: ServerRequest, delayedStart: Bool = false, completion:@escaping (_ response: ServerResponse) -> Void) -> Operation {
        let op = ServerOperation(request: request)
        op.completionBlock = { [unowned op] in
            if op.isCancelled == false {
                DispatchQueue.main.sync(execute: { () -> Void in
                    completion(response: op.response)
                })
            }
        }
        if !delayedStart {
            ServerClient.enQueueOperation(op)
        }
        return op
    }
    
    /**
    The a repeating networking call, which will repeat itself asynchronously on a NSOperationQueue based on the timeInterval.
    
    - parameter ServerRequest: The configured object with a variety of interesting information for your networking call.
    - parameter NSTimeInterval: The repeat interval for the request.
    - parameter ServerResponse: After the networking call is completed, this will be called on the main thread.
    
    - returns: NSTimer
    */
    public class func performRepeatingRequest(_ request: ServerRequest, timeInterval:TimeInterval, completion:@escaping (_ response: ServerResponse) -> Void) -> Timer {
        let timer = Timer.schedule(repeatInterval: timeInterval, handler:{ nTimer in
            if nTimer.isValid {
                ServerClient.performRequest(request, completion:completion)
            }
        })
        return timer
    }
    
    /**
    If one or more requests have been created with the delayedStart flag set, this is how to start them
    
    - parameter operations: The operations to begin executing.
    */
    public class func beginOperations(_ operations: [Operation]) {
        for op in operations {
            ServerClient.enQueueOperation(op)
        }
    }
    
    // MARK: NSOperationQueue convenience
    fileprivate class func enQueueOperation(_ operation: Operation) {
        self.sharedInstance.operationQueue.addOperation(operation)
    }
}
