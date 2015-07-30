//
//  passcodeViewController.swift
//  charlie
//
//  Created by Jim Caralis on 7/29/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit


class passcodeViewController: UIViewController, ABPadLockScreenViewControllerDelegate {

    var pinValidated = false

   
    
    
    override func viewWillAppear(animated: Bool) {
        
        if pinValidated == false
        {
            var ABPin = ABPadLockScreenViewController(delegate: self, complexPin: false)
            var  ABCustomView = ABPadLockScreenView()
            presentViewController(ABPin, animated: true, completion: nil)
        }
        

        
    
    }
    
    
    override func viewDidLoad() {
        
    }
    
    
    func padLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!, validatePin pin: String!) -> Bool {
        
         var savedPin = defaults.stringForKey("pin")
        
        if pin == savedPin
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func unlockWasSuccessfulForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        pinValidated = true
        println("succsesful")
        
//        defaults.setObject("no", forKey: "firstLoad")
//        defaults.synchronize()

        
        padLockScreenViewController.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
 
    }
    
    func unlockWasUnsuccessful(falsePin: String!, afterAttemptNumber attemptNumber: Int, padLockScreenViewController: ABPadLockScreenViewController!) {
        println("unsuccsesful")
    }
    
    func unlockWasCancelledForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        println("cancelled")
    }
    
    
    
    
    
    func attemptsExpiredForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController)
    {
        println("expired")
        
        
        
    }
    
    

}