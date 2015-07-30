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

  let users = realm.objects(User)


class loginViewController: UIViewController, ABPadLockScreenSetupViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var emailAddress: UITextField!
    
   var pinSetValidated = false
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        
        if pinSetValidated == true //already completed pin setup and can go to mainscreen (this should prob never get called...
        {
            performSegueWithIdentifier("segueFromLoginToMain", sender: self)
        }
        else if users.count > 0 //if user was setup but for some reason the passcode has not been set yet
        {
            var ABPinSetup = ABPadLockScreenSetupViewController(delegate: self)
            presentViewController(ABPinSetup, animated: true, completion: nil)

        }
        else
        {
            emailAddress.becomeFirstResponder() 

        }
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailAddress.delegate = self

        
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
    
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        
        
        if isValidEmail(emailAddress.text)
        {
            var ABPinSetup = ABPadLockScreenSetupViewController(delegate: self)
            presentViewController(ABPinSetup, animated: true, completion: nil)
            createUser(emailAddress.text)
        }
        else
        {
            var alert = UIAlertController(title: "Whoops", message: "Looks like there is a problem with your email address", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    
    func createUser(email:String)
    {
      
        
        
                    // Create a Person object
                    let user = User()
                    user.email = email
                    user.password = "password"
                    realm.write {
                        realm.add(user, update: true)
                    }
        
        

        
    }
    
    
}
