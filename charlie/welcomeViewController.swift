//
//  welcomeViewController.swift
//  charlie
//
//  Created by James Caralis on 7/18/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
import RealmSwift


class welcomeViewController: UIViewController {
    
    var keyStore = NSUbiquitousKeyValueStore()
    
    let users = realm.objects(User)
    var cHelp = cHelper()
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        //if no users and we have icloud access token we should restore user
        
        
        
        
        var access_token = ""
        if keyStore.stringForKey("access_token") != nil
        {
            access_token = keyStore.stringForKey("access_token")!
        }
        
        
        
        
        if access_token != "" && users.count == 0
        {
            //recover user
            println("Need to recover user")
            
            
            //get categories
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
                    
                    let access_token = self.keyStore.stringForKey("access_token")!
                    
                    
                    // Create a user object
                    let user = User()
                    user.email = "test@charlie.com"
                    user.pin = "0000"
                    user.password = "password"
                    user.access_token = access_token
                    realm.write {
                        realm.add(user, update: true)
                    }
                    
                    self.keyStore.setString("test@charlie.com", forKey: "email")
                    self.keyStore.setString("password", forKey: "password")
                    self.keyStore.setString(access_token, forKey: "access_token")
                    self.keyStore.synchronize()
                    
                    
                    
                    
                    self.cHelp.addUpdateResetAccount(1, dayLength: 0)
                        {
                            (response) in
                            
                        
                            self.performSegueWithIdentifier("skipOnboarding", sender: self)
                            
                    }
                    
            }
            
            
        }
            //no icloud token and no users so show onboarding
        else if users.count == 0
        {
            println("no user so show onboarding")
            
        }
            //if we have users skip onboarding
        else
        {
            println("have user")
            
            performSegueWithIdentifier("skipOnboarding", sender: self)
            
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    
    
    
    
    
   
    
   
    
    
    
}
