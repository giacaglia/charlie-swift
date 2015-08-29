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


var cHelp = cHelper()


class loginViewController: UIViewController, ABPadLockScreenSetupViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var pinSetValidated = false
    
    var access_token = ""
    var email_address = ""

    var keyChainStore = KeychainHelper()
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        var user_count = users.count
        
        if keyStore.stringForKey("access_token") != nil && keyStore.stringForKey("email_address") != nil
        {
            access_token = keyStore.stringForKey("access_token")!
            email_address = keyStore.stringForKey("email_address")!
        }
        
        
        if pinSetValidated == true //already completed pin setup and can go to mainscreen (this should prob never get called...
        {
            performSegueWithIdentifier("segueFromLoginToMain", sender: self)
        }
        else if user_count > 0 //if user was setup but for some reason the passcode has not been set yet
        {
            var ABPinSetup = ABPadLockScreenSetupViewController(delegate: self)
            ABPinSetup.view.backgroundColor = listBlue
            ABPinSetup.setEnterPasscodeLabelText("Please choose a Charlie passcode")

            
            presentViewController(ABPinSetup, animated: false, completion: nil)
        }
        else if access_token != "" && users.count == 0
        {
          alertUserRecoverData()
         
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
        
        
        //defaults.setObject(pin, forKey: "pin")
        
        keyChainStore.set(pin, key: "pin")
        
        
        charlieAnalytics.track("Pin Code Created")
        
        pinSetValidated = true
        
        defaults.setObject("no", forKey: "firstLoad")
        defaults.synchronize()

        

        padLockScreenViewController.dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("segueFromLoginToMain", sender: self)
        
        
        
        
    }
    
    func unlockWasCancelledForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
        
        
    }
    
    func alertUserRecoverData()
    {
        
        var uuid = ""
        var properties:[String:AnyObject] = [:]
        
    if let access_token = keyStore.stringForKey("access_token")
    {
        if let email = keyStore.stringForKey("email_address")
        
        {
        var refreshAlert = UIAlertController(title: "Hello again!", message: "Continue as \(email)?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            
            self.activityIndicator.startAnimating()
            self.emailAddress.enabled = false
            self.nextButton.enabled = false

            charlieAnalytics.track("Account Recovered")

            
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
                    
                    
                    //add user
                    // Create a Person object
                    let user = User()
                    user.email = email
                    user.password = "password"
                    //user.access_token = access_token
                    realm.write {
                        realm.add(user, update: true)
                    }
                    
                     self.keyChainStore.set(access_token, key: "access_token")
                    
                     cService.saveAccessToken(access_token)
                        {
                            (response) in
                            
                        }
                    
                    
                    if let uuid = keyStore.stringForKey("uuid")
                    {
                       //all set
                    }
                    else
                    {
                        let uuid = NSUUID().UUIDString
                    }
                   
                    
                    
                    keyStore.setString(access_token, forKey: "access_token")
                    keyStore.setString(self.email_address, forKey: "email_address")
                    keyStore.setString(uuid, forKey: self.email_address)
                    keyStore.synchronize()
                    
                    Mixpanel.sharedInstance().identify(self.email_address)
                    properties["$email"] = self.email_address
                    Mixpanel.sharedInstance().people.set(properties)

                    
                    
                    
                    
                    cHelp.addUpdateResetAccount(1, dayLength: 0)
                        {
                            (response) in
                            
                            
                            var ABPinSetup = ABPadLockScreenSetupViewController(delegate: self)
                            ABPinSetup.view.backgroundColor = listBlue

                            ABPinSetup.setEnterPasscodeLabelText("Please choose a Charlie passcode")
                            
                            self.presentViewController(ABPinSetup, animated: true, completion: nil)
                            self.createUser(self.email_address)
                            
                            
                    }
                    
                    
                    self.activityIndicator.stopAnimating()
                    
            }
            
            
            
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
            //do nothing and allow user to sign up again
        }))
        
        self.presentViewController(refreshAlert, animated: true, completion: nil)
        
        }
    }
        
    }

    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        
        
        if isValidEmail(emailAddress.text)
        {
            var ABPinSetup = ABPadLockScreenSetupViewController(delegate: self)
            ABPinSetup.view.backgroundColor = listBlue
            ABPinSetup.setEnterPasscodeLabelText("Please choose a Charlie passcode")
            presentViewController(ABPinSetup, animated: true, completion: nil)


            createUser(emailAddress.text)
            
            var uuid = NSUUID().UUIDString
            Mixpanel.sharedInstance().identify(emailAddress.text)
            
            keyStore.setString(uuid, forKey: emailAddress.text)
            
              charlieAnalytics.track("Email Added")
        
            
            
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
      
                    var properties:[String:AnyObject] = [:]
        
                    // Create a Person object
                    let user = User()
                    user.email = email
                    user.password = "password"
                    realm.write {
                        realm.add(user, update: true)
                    }
        
                   
                  
        
        
        

        
    }
    
    
}
