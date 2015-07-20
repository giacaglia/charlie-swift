//
//  charlieService.swift
//  charlie
//
//  Created by James Caralis on 6/8/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import BladeKit
import CoreData




var client_id = "556e4fd33b5cadf40371c32c"
var client_secret = "56c550d30f65794124f7a6b5e180bd"
var httpStatusCode:Int = 0


var srGetToken = ServerRequest(url: NSURL(string:  "https://tartan.plaid.com/exchange_token"))
var srConnect = ServerRequest(url: NSURL(string:  "https://tartan.plaid.com/connect"))
var srCategory = ServerRequest(url: NSURL(string:  "https://tartan.plaid.com/categories"))
var srConnectGet = ServerRequest(url: NSURL(string:  "https://tartan.plaid.com/connect/get"))
var srInstitutions = ServerRequest(url: NSURL(string:  "https://tartan.plaid.com/institutions"))

class charlieService {

init(){
    
    
}

    
    func getAccessToken(public_token:String, callback: NSDictionary->())
    
    {
        
        let parameters = [
            "client_id": client_id,
            "secret": client_secret,
            "public_token": public_token
        ]
        
        
        srGetToken.httpMethod = .Post
        srGetToken.parameters = parameters
        
        ServerClient.performRequest(srGetToken, completion: { (response) -> Void in
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
            
            
        })
        
        
        
        
        
    }
    
    func updateAccount(access_token:String, dayLength:Int, callback: NSDictionary->())
    {
        
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
            httpStatusCode = response.rawResponse!.statusCode
            if httpStatusCode == 201 //needs mfa
            {
             //   println(JSON(response.results()))
            }
                
            else //can process data
            {
                //println(JSON(response.results()))
            }
            
            
            
            callback(response.results() as! NSDictionary)
            
            
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


