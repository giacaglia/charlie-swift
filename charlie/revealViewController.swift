//
//  revealViewController.swift
//  charlie
//
//  Created by Jim Caralis on 7/21/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit



class revealViewController: UIViewController {

    
    var revealPercentage:String = ""
    
    
    
    @IBOutlet weak var revealTitle: UILabel!

    @IBOutlet weak var revealDetailView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        revealDetailView.layer.cornerRadius = 20
        revealTitle.text = "You guessed \(revealPercentage)"
        
        
        
        
        
        
    }


    @IBAction func dismissButtonPressed(sender: UIButton) {
        
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
}
