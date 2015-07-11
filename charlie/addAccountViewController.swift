//
//  addAccountViewController.swift
//  charlie
//
//  Created by James Caralis on 7/2/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//


import UIKit
import BladeKit
import RealmSwift
import WebKit


class addAccountViewController: UIViewController, UIWebViewDelegate, WKScriptMessageHandler {

    let users = realm.objects(User)
    
    
    var timer = NSTimer()
    var cHelp = cHelper()
    @IBOutlet weak var webViewView: UIView!

   
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        spinner.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        


        let req = NSURLRequest(URL: NSURL.fileURLWithPath(filePath!)!)
        
        var webView: WKWebView?
        var contentController = WKUserContentController();
        
        let source: NSString = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=.90, maximum-scale=.90, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);";
        let script: WKUserScript = WKUserScript(source: source as String, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
        
        
        
        
        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        
        contentController.addUserScript(script)
        
        
        var config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(
            frame: self.view.bounds,
            configuration: config
        )
        
        
        self.webViewView.addSubview(webView!)
        
        
       
        
        webView?.sizeToFit()
        webView!.loadRequest(req)
        
        

        
         
    
    }
    
    
    func pathForBuggyWKWebView(filePath: String?) -> String? {
        let fileMgr = NSFileManager.defaultManager()
        let tmpPath = NSTemporaryDirectory().stringByAppendingPathComponent("www")
        var error: NSErrorPointer = nil
        if !fileMgr.createDirectoryAtPath(tmpPath, withIntermediateDirectories: true, attributes: nil, error: error) {
            println("Couldn't create www subdirectory. \(error)")
            return nil
        }
        let dstPath = tmpPath.stringByAppendingPathComponent(filePath!.lastPathComponent)
        if !fileMgr.fileExistsAtPath(dstPath) {
            if !fileMgr.copyItemAtPath(filePath!, toPath: dstPath, error: error) {
                println("Couldn't copy file to /tmp/www. \(error)")
                return nil
            }
        }
        return dstPath
    }
    
    
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            
            //get access_token
            
            var public_token = message.body as! String
            
            if public_token == "exit"
            {
                println("Exit")
                dismissViewControllerAnimated(true, completion: nil)
                spinner.stopAnimating()
                
            }
            else if public_token == "loaded"
            {
               println("finished loading")
               spinner.stopAnimating()
                
            }
            else
            {
                spinner.startAnimating()
                cService.getAccessToken(public_token)
                    {
                        (response) in
                        var access_token = response["access_token"] as! String
                        realm.beginWrite()
                        self.users[0].access_token = access_token
                        realm.commitWrite()
                        
                        
                        cService.updateAccount(access_token, dayLength: 30)
                            {
                                (response) in
                                
                                println("Got token")
                                
                                let accounts = response["accounts"] as! [NSDictionary]
                                realm.write {
                                    // Save one Venue object (and dependents) for each element of the array
                                    for account in accounts {
                                        realm.create(Account.self, value: account, update: true)
                                        println("saved accounts")
                                    }
                                }
                                self.dismissViewControllerAnimated(true, completion: nil)
         
//                                
//                                var transactions = response["transactions"] as! [NSDictionary]
//                                // Save one Venue object (and dependents) for each element of the array
//                                for transaction in transactions {
//                                    println("saved")
//                                    
//                                    realm.write {
//                                        
//                                        //clean up name
//                                        var dictName = transaction.valueForKey("name") as? String
//                                        transaction.setValue(self.cHelp.cleanName(dictName!), forKey: "name")
//                                        
//                                        println(dictName)
//                                        
//                                        //convert string to date before insert
//                                        var dictDate = transaction.valueForKey("date") as? String
//                                        transaction.setValue(self.cHelp.convertDate(dictDate!), forKey: "date")
//                                        
//                                        
//                                        //add category
//                                        if let category_id = transaction.valueForKey("category_id") as? String
//                                        {
//                                            let predicate = NSPredicate(format: "id = %@", category_id)
//                                            var categoryToAdd = realm.objects(Category).filter(predicate)
//                                            var newTrans =  realm.create(Transaction.self, value: transaction, update: true)
//                                            newTrans.categories = categoryToAdd[0]
//                                        }
//                                        else
//                                        {
//                                            var newTrans =  realm.create(Transaction.self, value: transaction, update: true)
//                                            
//                                        }
//                                        
//                                    }
//                                }
                                
                                //run through transactions and see if they can be preliminarly categorized
                                
                                 transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
                                
                                
                                println(transactionItems.count)
                                self.spinner.stopAnimating()
                                
                               self.dismissViewControllerAnimated(true, completion: nil)
                                
                              

                                
                                
                                
                                
                        }
                        
                        
                    
                        
                        
                }
                
            }
        }
    }
    
   
   
    

    
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    

}