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
var srConnectStep = ServerRequest(url: NSURL(string:  "https://tartan.plaid.com/connect/step"))
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
    
    func updateAccount(access_token:String, callback: NSDictionary->())
    {
        let parameters = [
            "client_id": client_id,
            "secret": client_secret,
            "access_token": access_token
        ]
        
        
        srConnectGet.httpMethod = .Post
        srConnectGet.parameters = parameters
        
        
        
        ServerClient.performRequest(srConnectGet, completion: { (response) -> Void in
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
    
    func addAccount(username:String, password:String, bank:String, callback: NSDictionary->())
    {

    let parameters = [
        "client_id": client_id,
        "secret": client_secret,
        "username": username,
        "password": password,
        "type": bank
    ]
    
    srConnect.httpMethod = .Post
    srConnect.parameters = parameters
    
    ServerClient.performRequest(srConnect, completion: { (response) -> Void in
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
    
    
    
    
    func submitMFA(access_token:String, mfa_response:String,  callback: NSDictionary->())
    {
        let parameters = [
            "client_id": client_id,
            "secret": client_secret,
            "mfa": mfa_response,
            "access_token": access_token
        ]
        
        srConnectStep.httpMethod = .Post
        srConnectStep.parameters = parameters
        
        
       ServerClient.performRequest(srConnectStep, completion: { (response) -> Void in
            httpStatusCode = response.rawResponse!.statusCode
            
            
            println("MFA Submit Response - \(httpStatusCode)")
            println(JSON(response.results()))
            
            callback(response.results() as! NSDictionary)

            
            
        })
        
       
        
    }
    
    
    func getTransactions(access_token:String, callback: NSDictionary->())
    {
        
        let parameters = [
            "client_id": client_id,
            "secret": client_secret,
            "acess_token": access_token
        ]
        
        srConnect.httpMethod = .Post
        srConnect.parameters = parameters
        
        ServerClient.performRequest(srConnect, completion: { (response) -> Void in
            httpStatusCode = response.rawResponse!.statusCode
            if httpStatusCode == 200 //no mfa
            {
                
                println(JSON(response.results()))
                
            }
                
            else if httpStatusCode == 201//mfa
            {
                
                let mfa:NSDictionary = response.genericResults as! NSDictionary
                if (mfa.objectForKey("mfa") != nil)
                {
                    println("MFAAAAA")
                }
                else
                {
                    println("MFA but not key???")
                }
                
                
            }
            
            
            callback(response.results() as! NSDictionary)
            
            
        })
        
        
    }
    
   // let mfa:NSDictionary = response.genericResults as! NSDictionary
    
    
}


