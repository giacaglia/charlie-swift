//
//  loginViewController.swift
//  charlie
//
//  Created by James Caralis on 6/6/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
import RealmSwift

let realm = Realm()




class loginViewController: UIViewController {
    
   
    
    override func viewDidAppear(animated: Bool) {
        let users = realm.objects(User)
        if users.count  == 0
        {
            // Create a Person object
            let user = User()
            user.email = "test@charlie.com"
            user.pin = "0000"
            user.password = "password"
            realm.write {
                realm.add(user, update: true)
            }
            
        }
        else
        {
            performSegueWithIdentifier("segueFromLoginToMain", sender: self)
        }

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
           }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
