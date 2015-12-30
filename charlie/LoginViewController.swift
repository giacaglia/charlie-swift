//
//  loginViewController.swift
//  charlie
//
//  Created by James Caralis on 6/6/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
import RealmSwift

var realm = try! Realm()
let users = realm.objects(User)
var cHelp = cHelper()

class LoginViewController: UIViewController, ABPadLockScreenSetupViewControllerDelegate {
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var pinSetValidated = false
    var access_token = ""
    var email_address = ""
    var keyChainStore = KeychainHelper()
    var nextButton = UIButton()
    var user_happy_flow : Double = 0
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

        if keyStore.stringForKey("access_token") != nil && keyStore.stringForKey("email_address") != nil {
            self.access_token = keyStore.stringForKey("access_token")!
            self.email_address = keyStore.stringForKey("email_address")!
        }
        
        if pinSetValidated == true {
            //already completed pin setup and can go to mainscreen (this should prob never get called...
            performSegueWithIdentifier("segueFromLoginToMain", sender: self)
        }
        else if users.count > 0 {
            //if user was setup but for some reason the passcode has not been set yet
            let ABPinSetup = ABPadLockScreenSetupViewController(delegate: self)
            ABPinSetup.view.backgroundColor = listBlue
            ABPinSetup.setEnterPasscodeLabelText("Please choose a Charlie passcode")
            presentViewController(ABPinSetup, animated: false, completion: nil)
        }
        else if access_token != "" && users.count == 0 {
            alertUserRecoverData()
        }
        else {
            emailAddress.becomeFirstResponder()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailAddress.delegate = self
       
        nextButton = UIButton(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 80))
        nextButton.backgroundColor = listBlue
        nextButton.setTitle("Next", forState: .Normal)
        nextButton.addTarget(self, action: "didPressNext", forControlEvents: .TouchUpInside)
        nextButton.titleLabel?.font = UIFont(name: "Montserrat-ExtraBold", size: 20)
//        nextButton.hidden = true
        emailAddress.inputAccessoryView = nextButton
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
    
    func alertUserRecoverData() {
        guard let access_token = keyStore.stringForKey("access_token") else {
            return
        }
        
        guard let email = keyStore.stringForKey("email_address") else {
            return
        }
     
        let refreshAlert = UIAlertController(title: "Hello again!", message: "Continue as \(email)?", preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction) in
            self.activityIndicator.startAnimating()
            self.emailAddress.enabled = false
            self.nextButton.hidden = false
            charlieAnalytics.track("Account Recovered")
            
            //get categories
            cService.getCategories() { (responses) in
                for response in responses {
                    let cat = Category()
                    let id:String = response["id"] as! String
                    let type:String = response["type"] as! String
                    cat.id = id
                    cat.type = type
                    let categories = (response["hierarchy"] as! Array).joinWithSeparator(",")
                    cat.categories = categories
                    try! realm.write {
                        realm.add(cat, update: true)
                    }
                }
                //add user
                let user = User()
                user.email = email
                user.password = "password"
                user.happy_flow = self.user_happy_flow
                try! realm.write {
                    realm.add(user, update: true)
                }
                
                self.keyChainStore.set(access_token, key: "access_token")
                cService.saveAccessToken(access_token) { (response) in
                }
                
                keyStore.setString(access_token, forKey: "access_token")
                keyStore.setString(self.email_address, forKey: "email_address")
                keyStore.synchronize()
                Mixpanel.sharedInstance().people.set(["$email":self.email_address])
                
                cHelp.addUpdateResetAccount(1, dayLength: 0) { (response) in
                    let ABPinSetup = ABPadLockScreenSetupViewController(delegate: self)
                    ABPinSetup.view.backgroundColor = listBlue
                    
                    ABPinSetup.setEnterPasscodeLabelText("Please choose a Charlie passcode")
                    
                    self.presentViewController(ABPinSetup, animated: true, completion: nil)
                    self.createUser(self.email_address)
                }
                self.activityIndicator.stopAnimating()
                
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction) in
            //do nothing and allow user to sign up again
        }))
        
        self.presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    
    func didPressNext() {
        self.validateEmail()
    }
    
   
    func validateEmail() {
        if emailAddress.text!.isValidEmail() {
            // Register for notifications
            let type: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
            let setting = UIUserNotificationSettings(forTypes: type, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(setting)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            let ABPinSetup = ABPadLockScreenSetupViewController(delegate: self)
            ABPinSetup.view.backgroundColor = listBlue
            ABPinSetup.setEnterPasscodeLabelText("Please choose a Charlie passcode")
            presentViewController(ABPinSetup, animated: true, completion: nil)
            createUser(emailAddress.text!)
            Mixpanel.sharedInstance().people.set(["$email":self.email_address])
            charlieAnalytics.track("Email Added")
        }
        else {
            let alert = UIAlertController(title: "Whoops", message: "Looks like there is a problem with your email address", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    func createUser(email:String) {
        let user = User()
        user.email = email
        user.password = "password"
        user.happy_flow = self.user_happy_flow
        try! realm.write {
            realm.add(user, update: true)
        }
    }
    
    @IBAction func openLink(sender: UIButton) {
        if sender.tag == 0 {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.charliestudios.com/terms")!)
        }
        else {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.charliestudios.com/privacy")!)
        }
    }
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.validateEmail()
        return true
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}