//
//  ServerClient.swift
//  BladeKit
//
//  Created by Doug on 4/1/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import Foundation

public final class ServerClient {
    
    public static var urlTimeout: NSTimeInterval = 30
    
    // MARK: Internal OperationQueue
    private let operationQueue : NSOperationQueue = {
        let opQueue = NSOperationQueue()
        opQueue.maxConcurrentOperationCount = 5
        return opQueue
    }()
    
    // MARK: - Singleton
    private static let sharedInstance = ServerClient()
    
    // MARK: - Making Requests
    /**
    The main networking call, which will run asynchronously on a NSOperationQueue.
    
    - parameter request: The configured ServerRequest object with a variety of interesting information for your networking call.
    - parameter delayedStart: Should the ServerClient start the request immediately. Useful for operation dependencies or otherwise configuring starting the requests at a different time. Default is `false`, (ie, begin immediately)
    - parameter completion: A completion block containing the ServerResponse after the networking call is completed, this will be called on the main thread.

    - returns: NSOperation
    */
    public class func performRequest(request: ServerRequest, delayedStart: Bool = false, completion:(response: ServerResponse) -> Void) -> NSOperation {
        let op = ServerOperation(request: request)
        op.completionBlock = { [unowned op] in
            if op.cancelled == false {
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
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
    public class func performRepeatingRequest(request: ServerRequest, timeInterval:NSTimeInterval, completion:(response: ServerResponse) -> Void) -> NSTimer {
        let timer = NSTimer.schedule(repeatInterval: timeInterval, handler:{ nTimer in
            if nTimer.valid {
                ServerClient.performRequest(request, completion:completion)
            }
        })
        return timer
    }
    
    /**
    If one or more requests have been created with the delayedStart flag set, this is how to start them
    
    - parameter operations: The operations to begin executing.
    */
    public class func beginOperations(operations: [NSOperation]) {
        for op in operations {
            ServerClient.enQueueOperation(op)
        }
    }
    
    // MARK: NSOperationQueue convenience
    private class func enQueueOperation(operation: NSOperation) {
        self.sharedInstance.operationQueue.addOperation(operation)
    }
}
