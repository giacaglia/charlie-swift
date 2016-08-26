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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        if keyStore.string(forKey: "access_token") != nil && keyStore.string(forKey: "email_address") != nil {
            self.access_token = keyStore.string(forKey: "access_token")!
            self.email_address = keyStore.string(forKey: "email_address")!
        }
        
        if pinSetValidated == true {
            //already completed pin setup and can go to mainscreen (this should prob never get called...
            performSegue(withIdentifier: "segueFromLoginToMain", sender: self)
        }
        else if users.count > 0 {
            //if user was setup but for some reason the passcode has not been set yet
            let ABPinSetup = ABPadLockScreenSetupViewController(delegate: self)
            ABPinSetup?.view.backgroundColor = listBlue
            ABPinSetup?.setEnterPasscodeLabelText("Please choose a Charlie passcode")
            present(ABPinSetup!, animated: false, completion: nil)
        }
        else if access_token != "" && users.count == 0 {
            alertUserRecoverData()
        }
        else {
            emailAddress.becomeFirstResponder()
                charlieAnalytics.track("Email Asked")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailAddress.delegate = self
       
        nextButton = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 80))
        nextButton.backgroundColor = listBlue
        nextButton.setTitle("Next", for: UIControlState())
        nextButton.addTarget(self, action: #selector(LoginViewController.didPressNext), for: .touchUpInside)
        nextButton.titleLabel?.font = UIFont(name: "Montserrat-ExtraBold", size: 20)
//        nextButton.hidden = true
        emailAddress.inputAccessoryView = nextButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pinSet(_ pin: String!, padLockScreenSetupViewController padLockScreenViewController: ABPadLockScreenSetupViewController!) {
        
        //defaults.setObject(pin, forKey: "pin")
        keyChainStore.set(pin, key: "pin")
        charlieAnalytics.track("Pin Code Created")
        pinSetValidated = true
        defaults.set("no", forKey: "firstLoad")
        defaults.synchronize()
        padLockScreenViewController.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "segueFromLoginToMain", sender: self)
    }
    
    func unlockWasCancelled(forPadLockScreenViewController padLockScreenViewController: ABPadLockScreenAbstractViewController!) {

    }
    
    func alertUserRecoverData() {
        guard let access_token = keyStore.string(forKey: "access_token") else {
            return
        }
        
        guard let email = keyStore.string(forKey: "email_address") else {
            return
        }
     
        let refreshAlert = UIAlertController(title: "Hello again!", message: "Continue as \(email)?", preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) in
            self.activityIndicator.startAnimating()
            self.emailAddress.isEnabled = false
            self.nextButton.isHidden = false
            charlieAnalytics.track("Account Recovered")
            
            //get categories
            cService.getCategories() { (responses) in
                for response in responses {
                    let cat = Category()
                    let id:String = response["id"] as! String
                    let type:String = response["type"] as! String
                    cat.id = id
                    cat.type = type
                    let categories = (response["hierarchy"] as! Array).joined(separator: ",")
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
                
                
                let uuid = UIDevice.current.identifierForVendor!.uuidString
                self.keyChainStore.set(uuid, key: "uuid")
                
                self.keyChainStore.set(access_token, key: "access_token")
                cService.saveAccessToken(access_token) { (response) in
                }
                
                keyStore.set(access_token, forKey: "access_token")
                keyStore.set(self.email_address, forKey: "email_address")
                keyStore.synchronize()
                Mixpanel.sharedInstance().people.set(["$email":self.email_address])
                
                cHelp.addUpdateResetAccount(dayLength: 0) { (response) in
                    let ABPinSetup = ABPadLockScreenSetupViewController(delegate: self)
                    ABPinSetup?.view.backgroundColor = listBlue
                    
                    ABPinSetup?.setEnterPasscodeLabelText("Please choose a Charlie passcode")
                    
                    self.present(ABPinSetup!, animated: true, completion: nil)
                    self.createUser(self.email_address)
                }
                self.activityIndicator.stopAnimating()
                
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction) in
            //do nothing and allow user to sign up again
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    func didPressNext() {
        self.validateEmail()
    }
    
   
    func validateEmail() {
        if emailAddress.text!.isValidEmail() {
            // Register for notifications
            let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
            let setting = UIUserNotificationSettings(types: type, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()
            
            let ABPinSetup = ABPadLockScreenSetupViewController(delegate: self)
            ABPinSetup?.view.backgroundColor = listBlue
            ABPinSetup?.setEnterPasscodeLabelText("Please choose a Charlie passcode")
            present(ABPinSetup!, animated: true, completion: nil)
            createUser(emailAddress.text!)
            Mixpanel.sharedInstance().people.set(["$email":self.email_address])
            charlieAnalytics.track("Email Added")
        }
        else {
            let alert = UIAlertController(title: "Whoops", message: "Looks like there is a problem with your email address", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func createUser(_ email:String) {
        let user = User()
        user.email = email
        user.password = "password"
        user.happy_flow = self.user_happy_flow
        try! realm.write {
            realm.add(user, update: true)
        }
    }
    
    @IBAction func openLink(_ sender: UIButton) {
        if sender.tag == 0 {
            UIApplication.shared.openURL(URL(string: "http://www.charliestudios.com/terms")!)
        }
        else {
            UIApplication.shared.openURL(URL(string: "http://www.charliestudios.com/privacy")!)
        }
    }
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.validateEmail()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
