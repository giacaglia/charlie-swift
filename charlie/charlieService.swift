//
//  charlieService.swift
//  charlie
//
//  Created by James Caralis on 6/8/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import BladeKit
import CloudKit

var httpStatusCode:Int = 0
var srGetToken = ServerRequest(url: NSURL(string:  "https://tartan.plaid.com/exchange_token"))
var srConnect = ServerRequest(url: NSURL(string:  "https://tartan.plaid.com/connect"))
var srCategory = ServerRequest(url: NSURL(string:  "https://tartan.plaid.com/categories"))
var srConnectGet = ServerRequest(url: NSURL(string:  "https://tartan.plaid.com/connect/get"))
var srInstitutions = ServerRequest(url: NSURL(string:  "https://tartan.plaid.com/institutions"))

var apiKey = "jj859i3mfp230p34"
var bladeServerToken = ServerRequest(url: NSURL(string:  "https://blade-analytics.herokuapp.com/charlie/dev/track"))


class charlieService {

init(){
    
  
  
   
}

    
    
    
    func saveAccessToken(token:String, callback: Bool->())
    {
        
        
        
        var parameters = [
            "type": "token",
            "context": token,
        ]
        
        var sr = ServerRequest(url: NSURL(string:  "https://blade-analytics.herokuapp.com/charlie/dev/track"))
        sr.httpMethod = .Post
        sr.headerDict["X-Charlie-API-Key"] = apiKey
        
        sr.httpMethod = .Post
        sr.parameters = parameters
        
        ServerClient.performRequest(sr, completion: { (response) -> Void in
            
            println(response)
            callback(true)
            
        })
        
        
        
        
        
        
    }
    
    
    func getAccessToken(public_token:String, callback: NSDictionary->())
    
    {
        
       
        var client_id = keyChainStore.get("client_id")!
        var client_secret = keyChainStore.get("client_secret")!

        
        
                    let parameters = [
                        "client_id": client_id,
                        "secret": client_secret,
                        "public_token": public_token
                    ]
                    
                    
                    srGetToken.httpMethod = .Post
                    srGetToken.parameters = parameters
                    
                    ServerClient.performRequest(srGetToken, completion: { (response) -> Void in
                       
                        if let errorMsg:String = response.error?.description {
                            println(errorMsg)
                            var emptyDic = Dictionary<String, String>()
                            callback(emptyDic)
                        }
                        else
                        {

                        
                        httpStatusCode = response.rawResponse!.statusCode
                        if httpStatusCode == 201 //needs mfa
                        {
                            println(JSON(response.results()))
                        }
                            
                        else //can process data
                        {
                            println(JSON(response.results()))
                        }
                        
                        
                        
                        callback(response.results() as! NSDictionary)
                        
                        }
                    })
    }
   
    
    
    func updateAccount(access_token:String, dayLength:Int, callback: NSDictionary->())
    {
      
        var client_id = keyChainStore.get("client_id")!
        var client_secret = keyChainStore.get("client_secret")!

        
        
        if dayLength > 0
        {
        
            var options = [
                "pending": false,
                "gte": "\(dayLength) days ago"
            ]
       
            var parameters = [
                "client_id": client_id,
                "secret": client_secret,
                "access_token": access_token,
                "options": options
            ]
        
           // println(parameters)

            srConnectGet.parameters = parameters
        
        }
        else
        {
            
            var options = [
                "pending": false
            ]
            
            var parameters = [
                "client_id": client_id,
                "secret": client_secret,
                "access_token": access_token,
                "options": options
            ]
           // println(parameters)

            
            srConnectGet.parameters = parameters as! [String : AnyObject]
        }
      
        
        
        srConnectGet.httpMethod = .Post
       
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //All stuff here

        
        ServerClient.performRequest(srConnectGet, completion: { (response) -> Void in
            println(JSON(response.results()))
            
            if let errorMsg:String = response.error?.description {
                println(errorMsg)
                var emptyDic = Dictionary<String, String>()
                callback(emptyDic)
            }
            else
            {
            
            httpStatusCode = response.rawResponse!.statusCode
            if httpStatusCode == 200 
            {
               println(JSON(response.results()))
            }
                
            else //can process data
            {
                println("ERROR")
            }
            
            
            
                callback(response.results() as! NSDictionary)
            }
            
        })
        
    })
        
        
        
        
        
    }
    
    
    func getCategories(callback: NSArray->())
    {
       
        srCategory.httpMethod = .Get
        ServerClient.performRequest(srCategory, completion: { (response) -> Void in
            httpStatusCode = response.rawResponse!.statusCode
            if httpStatusCode == 201 //needs mfa
            {
               // println(JSON(response.results()))
            }
                
            else //can process data
            {
                //println(JSON(response.results()))
            }
            
            
            
            callback(response.results() as! NSArray)
            
            
        })
        
    }
    
   
    
    
    
    
    
}


