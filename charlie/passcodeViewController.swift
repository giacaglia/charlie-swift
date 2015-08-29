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
            ABPin.view.backgroundColor = listBlue
            self.view.backgroundColor = listBlue

            presentViewController(ABPin, animated: true, completion: nil)
            
            
            if users.count > 0
            {
                //save access_token on server
                if let access_token = keyChainStore.get("access_token")
                {
                    cService.saveAccessToken(access_token)
                        {
                            (response) in
                    }
                
                }
            
            }
            
            
            
        }
        

        
    
    }
    
    
    override func viewDidLoad() {
        
       
        
    }
    
    
    func padLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!, validatePin pin: String!) -> Bool {
        
         var savedPin =  keyChainStore.get("pin")
        
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
        
        padLockScreenViewController.dismissViewControllerAnimated(false, completion: nil)
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func unlockWasUnsuccessful(falsePin: String!, afterAttemptNumber attemptNumber: Int, padLockScreenViewController: ABPadLockScreenViewController!) {
        
    }
    
    func unlockWasCancelledForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
    
    }
    
    
    
    
    
    func attemptsExpiredForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController)
    {
        
    }
    
    

}