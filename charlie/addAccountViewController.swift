//
//  addAccountViewController.swift
//  charlie
//
//  Created by James Caralis on 7/2/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
//import BladeKit
import RealmSwift
import WebKit

class addAccountViewController: UIViewController, UIWebViewDelegate, WKScriptMessageHandler {
    
    @IBOutlet weak var webViewView: UIView!
    
    let users = realm.objects(User)
    var keyStore = NSUbiquitousKeyValueStore()
    var keyChainStore = KeychainHelper()
    var timer = Timer()
    var cHelp = cHelper()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        SwiftLoader.show(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        charlieAnalytics.track("Find Bank Button Pressed")
        
        let req = URLRequest(url: URL(fileURLWithPath: filePath!))
        var webView: WKWebView?
        let contentController = WKUserContentController();
        
        let source: NSString = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=.90, maximum-scale=.90, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);";
        
        let script: WKUserScript = WKUserScript(source: source as String, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        contentController.add(self, name: "callbackHandler")
        contentController.addUserScript(script)
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(frame: self.view.bounds, configuration: config)
        self.webViewView.addSubview(webView!)
        webView?.sizeToFit()
        webView?.isUserInteractionEnabled =  true
        webView!.load(req)
    }
    
    func userContentController(_ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage) {
        if message.name == "callbackHandler" {
            //get access_token
            let public_token = message.body as! String
            if public_token == "exit" {
                print("Exit")
                dismiss(animated: true, completion: nil)
                SwiftLoader.hide()
            }
            else if public_token == "loaded" {
                print("finished loading")
                SwiftLoader.hide()
            }
            else {
                SwiftLoader.show(true)
                cService.getAccessToken(public_token) { (response) in
                    // var uuid = NSUUID().UUIDString
                    let access_token = response["access_token"] as! String
                    let email_address = self.users[0].email
                    self.keyStore.set(access_token, forKey: "access_token")
                    self.keyStore.set(email_address, forKey: "email_address")
                    self.keyStore.synchronize()
                    Mixpanel.sharedInstance().people.set(["$email":email_address])
                    
                    let uuid = UIDevice.current.identifierForVendor!.uuidString
                    self.keyChainStore.set(uuid, key: "uuid")
                    
                    self.keyChainStore.set(access_token, key: "access_token")
                    print("ACCESS TOKEN\n")
                    print(access_token)
                    cService.saveAccessToken(access_token) { (response) in
                        print("Access token saved to server")
                    }
                    
                    //download categories if don't exist
                    _ = realm.objects(Category)
                    cService.getCategories() { (responses) in
                        for response in responses {
                            let category = Category()
                            let id:String = response["id"] as! String
                            let type:String = response["type"] as! String
                            category.id = id
                            category.type = type
                            let categories = (response["hierarchy"] as! Array).joined(separator: ",")
                            category.categories = categories
                            try! realm.write {
                                realm.add(category, update: true)
                            }
                        }
                        
                        cService.updateAccount(access_token, dayLength: 0) { (response) in
                            let accounts = response["accounts"] as! [NSDictionary]
                            try! realm.write {
                                // Save one Venue object (and dependents) for each element of the array
                                for account in accounts {
                                  
                                    realm.create(Account.self, value: account, update: true)
                                  
                                }
                            }
                            charlieAnalytics.track("Accounts Added")
                            self.dismiss(animated: true, completion: nil)
                            transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
                            SwiftLoader.hide()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        else {
            print("something else")
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
}
