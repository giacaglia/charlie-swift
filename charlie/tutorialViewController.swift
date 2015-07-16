//
//  tutorialViewController.swift
//  charlie
//
//  Created by James Caralis on 6/5/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit

class tutorialViewController: UIViewController {

   

    @IBOutlet weak var slider: UISlider!

    @IBOutlet weak var sliderAmount: UILabel!
    
       
    
    @IBAction func sliderChangedValue(sender: UISlider) {
        
        var selectedValue = Int(sender.value)
        
        sliderAmount.text = String(stringInterpolationSegment: selectedValue)
        
        
    }
    
    
    @IBAction func startButtonPress(sender: UIButton) {
        
        
          defaults.setObject(sliderAmount.text, forKey: "userSelectedHappyScore")
          defaults.setObject("0", forKey: "happyScoreViewed")
        
        
    }



}

