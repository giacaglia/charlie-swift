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
    var keyStore = NSUbiquitousKeyValueStore()
    var keyChainStore = KeychainHelper()
    
    
    var timer = NSTimer()
    var cHelp = cHelper()
    @IBOutlet weak var webViewView: UIView!

   
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    
    
    
    
    
    func willEnterForeground(notification: NSNotification!) {
        
        
        
        if defaults.stringForKey("firstLoad") != nil //else this is the first time the user has opened the app so don't ask for passcode
        {
            
            if let resultController = storyboard!.instantiateViewControllerWithIdentifier("passcodeViewController") as? passcodeViewController {
                presentViewController(resultController, animated: true, completion: nil)
                
                
            }
            
            
        }
        else
        {
            defaults.setObject("no", forKey: "firstLoad")
            defaults.synchronize()
            
        }
        
        
        imageView.removeFromSuperview()
    }
    
    
    
    
    
    func didEnterBackgroundNotification(notification: NSNotification)
    {
        
        cHelp.splashImageView()
        self.view.addSubview(imageView)
        
        
        
        
        
    }
    

    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        spinner.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackgroundNotification:", name: UIApplicationDidEnterBackgroundNotification, object: nil)

        


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
                        
                        
                        var uuid = NSUUID().UUIDString
                         var properties:[String:AnyObject] = [:]
                        
                        var access_token = response["access_token"] as! String
                        let email_address = self.users[0].email
                         self.keyStore.setString(access_token, forKey: "access_token")
                         self.keyStore.setString(email_address, forKey: "email_address")
                         self.keyStore.setString(uuid, forKey: "uuid")
                         self.keyStore.synchronize()
                        
                        Mixpanel.sharedInstance().identify(uuid)
                        properties["$email"] = email_address
                        Mixpanel.sharedInstance().people.set(properties)
                        
                        self.keyChainStore.set(access_token, key: "access_token")

                        
                        
                        cService.saveAccessToken(access_token)
                            {
                                (response) in
                                
                                println("Access token saved to server")
                        }
                        
                        
                        
                        //download categories if don't exist
                        let cats = realm.objects(Category)
                        cService.getCategories()
                                {
                                    (responses) in
                
                                        for response in responses
                                        {
                    
                                            var cat = Category()
                                            var id:String = response["id"] as! String
                                            var type:String = response["type"] as! String
                                            cat.id = id
                                            cat.type = type
                                            let categories = ",".join(response["hierarchy"] as! Array)
                                            cat.categories = categories
                                            realm.write {
                                                realm.add(cat, update: true)
                                            }
                                        }
     
                                    cService.updateAccount(access_token, dayLength: 0)
                                    {
                                        (response) in
                                        let accounts = response["accounts"] as! [NSDictionary]
                                        realm.write {
                                            // Save one Venue object (and dependents) for each element of the array
                                            for account in accounts {
                                                realm.create(Account.self, value: account, update: true)
                                                println("saved accounts")
                                            }
                                        }
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                        transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
                                        self.spinner.stopAnimating()
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                        
                                        
                                }
                                    
                        }
                        
                      
                }
                
            }
        }
    }
    
   
   
    

    
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    

}