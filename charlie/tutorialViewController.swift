//
//  tutorialViewController.swift
//  charlie
//
//  Created by James Caralis on 6/5/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit



class tutorialViewController: UIViewController {

    var keyStore = NSUbiquitousKeyValueStore()

    @IBOutlet weak var slider: UISlider!

    @IBOutlet weak var sliderAmount: UILabel!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if keyStore.stringForKey("access_token") != nil
        {
         
            //recover user
            println("Need to recover user")
            
            
        }
        else
        {
            println("no user so show onbouarding")
            
        }
            
            
            
    }
    
    
    
    
    
    
    @IBAction func sliderChangedValue(sender: UISlider) {
        
        var selectedValue = Int(sender.value)
        
        sliderAmount.text = String(stringInterpolationSegment: selectedValue)
        
        
    }
    
    
    @IBAction func startButtonPress(sender: UIButton) {
        
        
          defaults.setObject(sliderAmount.text, forKey: "userSelectedHappyScore")
          defaults.setObject("0", forKey: "happyScoreViewed")
        
        
    }



}

