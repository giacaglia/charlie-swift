//
//  tutorialViewController.swift
//  charlie
//
//  Created by James Caralis on 6/5/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
import RealmSwift


class TutorialViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderAmount: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    
    var access_token =  ""
    
    let blueThumb = UIImage(named: "slider_neutral")
    let redThumb = UIImage(named: "slider_sad")
    let greenThumb = UIImage(named: "slider_happy")
    
    
    override func viewDidAppear(animated: Bool) {
        
       
        
        if (keyStore.stringForKey("access_token") != nil) {
            self.access_token = keyStore.stringForKey("access_token")!
            alertUserRecoverData()
            
            
        }
        else
        {
            sliderAmount.textColor = listBlue
            nextButton.backgroundColor = listBlue
            nextButton.layer.cornerRadius = 10
            
            slider.setThumbImage(blueThumb, forState: UIControlState.Normal)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    func alertUserRecoverData() {
        guard let access_token = keyStore.stringForKey("access_token") else {
            return
        }
        
        
        
        let refreshAlert = UIAlertController(title: "Hello again!", message: "Would you like to recover your old account?", preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction) in
            self.nextButton.hidden = false
        charlieAnalytics.track("Account Recovered")
          SwiftLoader.show(true)
            
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
                    
                    
                    cHelp.addUpdateResetAccount(dayLength: 0) { (response) in
                        
                        
                      
                    }
                  SwiftLoader.hide()
                    
                }
                //add user
                let user = User()
              
                user.password = "password"
              
                try! realm.write {
                    realm.add(user, update: true)
                }
                
                
                let uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString
                keyChainStore.set(uuid, key: "uuid")
                
                keyChainStore.set(access_token, key: "access_token")
                cService.saveAccessToken(access_token) { (response) in
                }
                
                keyStore.setString(access_token, forKey: "access_token")
               
                keyStore.synchronize()
                self.performSegueWithIdentifier("happyFlowToLogin", sender: self)
                
                
                
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction) in
            //do nothing and allow user to sign up again
        }))
        
        self.presentViewController(refreshAlert, animated: true, completion: nil)
    }

    
    
    
    
    
    @IBAction func sliderChangedValue(sender: UISlider) {
        let selectedValue = Int(sender.value)
        if selectedValue >= 0 && selectedValue < 40 {
            sliderAmount.textColor = listRed
            slider.setThumbImage(redThumb, forState: UIControlState.Normal)
        }
        else if selectedValue > 40 && selectedValue < 80 {
            sliderAmount.textColor = listBlue
            slider.setThumbImage(blueThumb, forState: UIControlState.Normal)
        }
        else {
            sliderAmount.textColor = listGreen
            slider.setThumbImage(greenThumb, forState: UIControlState.Normal)
        }
        sliderAmount.text = "\(selectedValue)%"
    }
    
    @IBAction func startButtonPress(sender: UIButton) {
        defaults.setObject(sliderAmount.text, forKey: "userSelectedHappyScore")
        defaults.setObject("0", forKey: "happyScoreViewed")
        //performSegueWithIdentifier("toMainfromTutorial", sender: self)
        
        self.createUser()
        defaults.setObject("no", forKey: "firstLoad")
        performSegueWithIdentifier("happyFlowToLogin", sender: self)
    }
    
    private func createUser() {
        let user = User()
        user.password = "password"
        user.happy_flow = Double(slider.value)
        try! realm.write {
            realm.add(user, update: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let loginVC = segue.destinationViewController as! LoginViewController
//        loginVC.user_happy_flow = Double(slider.value)
        let sliderValue =  slider.value
        
        Mixpanel.sharedInstance().track("Happy Flow Guessed", properties: ["happy_flow": sliderValue])
    }
    
}