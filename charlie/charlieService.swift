//
//  charlieService.swift
//  charlie
//
//  Created by James Caralis on 6/8/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

//import BladeKit
import CloudKit

var httpStatusCode:Int = 0

//dev
var srGetToken = ServerRequest(url: URL(string:  "https://tartan.plaid.com/exchange_token") as NSURL?)
var srConnect = ServerRequest(url: URL(string:  "https://tartan.plaid.com/connect") as NSURL?)
var srCategory = ServerRequest(url: URL(string:  "https://tartan.plaid.com/categories") as NSURL?)
var srConnectGet = ServerRequest(url: URL(string:  "https://tartan.plaid.com/connect/get") as NSURL?)
var srInstitutions = ServerRequest(url: URL(string:  "https://tartan.plaid.com/institutions") as NSURL?)
var bladeServerToken = ServerRequest(url: URL(string:  "https://blade-analytics.herokuapp.com/charlie/dev/track") as NSURL?)
var apiKey = "jj859i3mfp230p34"

////production
//var srGetToken = ServerRequest(url: NSURL(string:  "https://api.plaid.com/exchange_token"))
//var srConnect = ServerRequest(url: NSURL(string:  "https://api.plaid.com/connect"))
//var srCategory = ServerRequest(url: NSURL(string:  "https://api.plaid.com/categories"))
//var srConnectGet = ServerRequest(url: NSURL(string:  "https://api.plaid.com/connect/get"))
//var srInstitutions = ServerRequest(url: NSURL(string:  "https://api.plaid.com/institutions"))
//var apiKey = "jj859i3mfp230p34"
//var bladeServerToken = ServerRequest(url: NSURL(string:  "https://blade-analytics.herokuapp.com/charlie/production/track"))

//var srSwipeSave = ServerRequest(url: NSURL(string:  "https://localhost:3000/transactions"))

var srSwipeSave = ServerRequest(url: URL(string:  "https://evening-anchorage-6916.herokuapp.com/transactions") as NSURL?)

class charlieService {

    init(){
    }

    
    func saveAccessToken(_ token:String, callback: @escaping (Bool)->()) {
        let parameters = [
            "type": "token",
            "context": token,
        ]
        
        let sr = ServerRequest(url: URL(string:  "https://blade-analytics.herokuapp.com/charlie/production/track") as NSURL?) // DEV
 //       let sr = ServerRequest(url: NSURL(string:  "https://blade-analytics.herokuapp.com/charlie/dev/track")) // PROD
        sr.httpMethod = .Post
        sr.headerDict["X-Charlie-API-Key"] = apiKey
        
        sr.httpMethod = .Post
        sr.parameters = parameters
        
        ServerClient.performRequest(sr, completion: { (response) -> Void in
           // println(response)
            callback(true)
        })
    }
    
   
    
    
    func saveSwipe(_ direction:Int, transactionIndex:Int, callback: @escaping (Bool)->())
    {
        var lat = 0.0
        var lng = 0.0
        var category_id = 0
        var city = ""
        var state = ""
        var address = ""
        var zip = ""        
        
        if ((transactionItems[transactionIndex].meta?.location?.coordinates?.lat) != nil)
        {
            lat = (transactionItems[transactionIndex].meta?.location?.coordinates?.lat)!
        }
      
        if ((transactionItems[transactionIndex].meta?.location?.coordinates?.lon) != nil)
        {
            lng = (transactionItems[transactionIndex].meta?.location?.coordinates?.lon)!
        }
  

        if ((transactionItems[transactionIndex].categories?.id) != nil)
        {
            category_id = Int((transactionItems[transactionIndex].categories?.id)!)!
        }
        
       
        if ((transactionItems[transactionIndex].meta?.location?.city) != nil)
        {
            city = (transactionItems[transactionIndex].meta?.location?.city)!
        }
        
        if ((transactionItems[transactionIndex].meta?.location?.state) != nil)
        {
            state = (transactionItems[transactionIndex].meta?.location?.state)!
        }
       
        if ((transactionItems[transactionIndex].meta?.location?.address) != nil)
        {
            address = (transactionItems[transactionIndex].meta?.location?.address)!
        }
        
        if ((transactionItems[transactionIndex].meta?.location?.zip) != nil)
        {
            zip = (transactionItems[transactionIndex].meta?.location?.zip)!
        }
        
                   
       
        
        
//        if ((transactionItems[transactionIndex].meta?.location?.zip) != nil)
//        {
//            zip = (transactionItems[transactionIndex].meta?.location?.zip)!
//        }
        
        
        
        if let _ = keyChainStore.get("client_id"),
            let _ = keyChainStore.get("client_secret"),
               let uuid = keyChainStore.get("uuid")
        {
            
            let parameters = [

                "name":   transactionItems[transactionIndex].name,
                "account": uuid,
                "transaction_date": String(transactionItems[transactionIndex].date),
                "amount": transactionItems[transactionIndex].amount,
                "swipe_type": direction,
                "location_type": transactionItems[transactionIndex].placeType,
                "category_id": category_id,
                "city": city,
                "state": state,
                "address": address,
                "zip": zip,
                "lat": lat,
                "lng": lng

            ]
            
            srSwipeSave.parameters = parameters as? [String : AnyObject]
        }
        
        
        srSwipeSave.httpMethod = .Post
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            ServerClient.performRequest(srSwipeSave, completion: { (response) -> Void in
                print(JSON(response.results()))
                if let errorMsg:String = response.error?.description {
                    print(errorMsg)
                    callback(false)
                }
                else {
                    httpStatusCode = response.rawResponse!.statusCode
                    if httpStatusCode == 200 {
                        print(JSON(response.results()))
                    }
                    else { //can process data
                        print("ERROR")
                    }
                    callback(true)
                }
            })
            
        })
    }
    
    
    
    func getAccessToken(_ public_token:String, callback: @escaping (NSDictionary)->()) {
        if let client_id = keyChainStore.get("client_id"),
           let client_secret = keyChainStore.get("client_secret") {
            let parameters = [
                "client_id": "test_id",
                "secret": "test_secret",
                "public_token": public_token
            ]
            
            
            srGetToken.httpMethod = .Post
            srGetToken.parameters = parameters
            
            ServerClient.performRequest(srGetToken, completion: { (response) -> Void in
                if let errorMsg:String = response.error?.description {
                    print(errorMsg)
                    let emptyDic = Dictionary<String, String>()
                    callback(emptyDic)
                }
                else {
                    httpStatusCode = response.rawResponse!.statusCode
                    if httpStatusCode == 201 {
                        //needs mfa
                       // println(JSON(response.results()))
                    }
                    else {
                        //can process data
                       // println(JSON(response.results()))
                    }
                    callback(response.results() as! NSDictionary)
                }
            })
        }
    }
   
    
    func updateAccount(_ access_token:String, dayLength:Int, callback: @escaping (NSDictionary)->()) {
        if let client_id = keyChainStore.get("client_id"),
            let client_secret = keyChainStore.get("client_secret") {
        
            if dayLength > 0 {
                let options = [
                    "pending": false,
                    "gte": "\(dayLength) days ago"
                ] as [String : Any]
           
                let parameters = [
                    "client_id": client_id,
                    "secret": client_secret,
                    "access_token": access_token,
                    "options": options
                ]
            
               // println(parameters)
                srConnectGet.parameters = parameters
            }
            else {
                let options = [
                    "pending": false
                ]
                
                let parameters = [
                    "client_id": client_id,
                    "secret": client_secret,
                    "access_token": access_token,
                    "options": options
                ]
               // println(parameters)
                srConnectGet.parameters = parameters as? [String : AnyObject]
            }
            srConnectGet.httpMethod = .Post
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                //All stuff here
                ServerClient.performRequest(srConnectGet, completion: { (response) -> Void in
                  //  println(JSON(response.results()))
                    if let errorMsg:String = response.error?.description {
                        print(errorMsg)
                        let emptyDic = Dictionary<String, String>()
                        callback(emptyDic)
                    }
                    else {
                        httpStatusCode = response.rawResponse!.statusCode
                        if httpStatusCode == 200 {
                            // println(JSON(response.results()))
                        }
                        else { //can process data
                            print("ERROR")
                        }
                        callback(response.results() as! NSDictionary)
                    }
                })
            })
        }
    }

    func getCategories(_ callback: @escaping (NSArray)->()) {
        srCategory.httpMethod = .Get
        ServerClient.performRequest(srCategory, completion: { (response) -> Void in
            httpStatusCode = response.rawResponse!.statusCode
            if httpStatusCode == 201 {//needs mfa
               // println(JSON(response.results()))
            }
            else {//can process data
                //println(JSON(response.results()))
            }
            callback(response.results() as! NSArray)
        })
    }
}
