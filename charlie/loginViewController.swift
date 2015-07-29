//
//  loginViewController.swift
//  charlie
//
//  Created by James Caralis on 6/6/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
import RealmSwift

var realm = Realm()




class loginViewController: UIViewController, ABPadLockScreenSetupViewControllerDelegate {
    
   var pinSetValidated = false
    
    override func viewDidAppear(animated: Bool) {
        
        if pinSetValidated == false
        {
            var ABPinSetup = ABPadLockScreenSetupViewController(delegate: self)
            presentViewController(ABPinSetup, animated: true, completion: nil)
        }
        else
        {
           performSegueWithIdentifier("segueFromLoginToMain", sender: self) 
        }
        
        
        
        //let users = realm.objects(User)
       
        
//        if users.count  == 0
//        {
//            // Create a Person object
//            let user = User()
//            user.email = "test@charlie.com"
//            user.pin = "0000"
//            user.password = "password"
//            realm.write {
//                realm.add(user, update: true)
//            }
//            
//        }
//        else
//        {
//            performSegueWithIdentifier("segueFromLoginToMain", sender: self)
//        }

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
           }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func pinSet(pin: String!, padLockScreenSetupViewController padLockScreenViewController: ABPadLockScreenSetupViewController!) {
        
        
        defaults.setObject(pin, forKey: "pin")
        pinSetValidated = true
        //let users = realm.objects(User)


            // Create a Person object
            let user = User()
            user.email = "test@charlie.com"
            user.pin = "0000"
            user.password = "password"
            realm.write {
                realm.add(user, update: true)
            }

        

        padLockScreenViewController.dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("segueFromLoginToMain", sender: self)
        
        
        
        
    }
    
    func unlockWasCancelledForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
        
        
    }
    
    
}
