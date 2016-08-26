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
    
    override func viewWillAppear(_ animated: Bool) {
        if pinValidated == true {
            return
        }
      
        // if the pin wasn't validated
        let ABPin = ABPadLockScreenViewController(delegate: self, complexPin: false)
        ABPin?.view.backgroundColor = listBlue
        self.view.backgroundColor = listBlue
        present(ABPin!, animated: true, completion: nil)
        if users.count > 0 {
            //save access_token on server
            if let access_token = keyChainStore.get("access_token") {
                cService.saveAccessToken(access_token) {
                    (response) in
                }
            }
        }
    }
    
    func padLockScreenViewController(_ padLockScreenViewController: ABPadLockScreenViewController!, validatePin pin: String!) -> Bool {
        let savedPin =  keyChainStore.get("pin")
        return pin == savedPin
    }
    
    func unlockWasSuccessful(for padLockScreenViewController: ABPadLockScreenViewController!) {
        pinValidated = true
        padLockScreenViewController.dismiss(animated: false, completion: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    func unlockWasUnsuccessful(_ falsePin: String!, afterAttemptNumber attemptNumber: Int, padLockScreenViewController: ABPadLockScreenViewController!) {
        
    }
    
    func unlockWasCancelled(for padLockScreenViewController: ABPadLockScreenViewController!) {
        
    }
    
    func attemptsExpired(for padLockScreenViewController: ABPadLockScreenViewController) {
    }
    
}
