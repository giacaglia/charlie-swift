//
//  tutorialViewController.swift
//  charlie
//
//  Created by James Caralis on 6/5/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
import RealmSwift


class tutorialViewController: UIViewController {

    var keyStore = NSUbiquitousKeyValueStore()

    let users = realm.objects(User)
    var cHelp = cHelper()
    
    

    @IBOutlet weak var slider: UISlider!
   
    @IBOutlet weak var sliderAmount: UILabel!
    

    @IBOutlet weak var nextButton: UIButton!

    let blueThumb = UIImage(named: "happy_off_blue")
    let redThumb = UIImage(named: "happy_off_red")
    let greenThumb = UIImage(named: "neutral_off_green")
    
    override func viewDidAppear(animated: Bool) {
        //if no users and we have icloud access token we should restore user
       
        
       
            
        

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        sliderAmount.textColor = listBlue
        nextButton.backgroundColor = listBlue
        nextButton.layer.cornerRadius = 10
        
        slider.setThumbImage(blueThumb, forState: UIControlState.Normal)
            
            
    }
    
    
    
    
    
    
    @IBAction func sliderChangedValue(sender: UISlider) {
        
        var selectedValue = Int(sender.value)
        
        if selectedValue >= 0 && selectedValue < 5
        {
            sliderAmount.textColor = listRed
            slider.setThumbImage(redThumb, forState: UIControlState.Normal)

        }
        else if selectedValue > 4 && selectedValue < 8
        {
            sliderAmount.textColor = listBlue
             slider.setThumbImage(blueThumb, forState: UIControlState.Normal)
        }
        else
        {
            sliderAmount.textColor = listGreen
            slider.setThumbImage(greenThumb, forState: UIControlState.Normal)
        }
        
        
        sliderAmount.text = String(stringInterpolationSegment: selectedValue)
        
        
    }
    
    
    @IBAction func startButtonPress(sender: UIButton) {
        
        
        defaults.setObject(sliderAmount.text, forKey: "userSelectedHappyScore")
        defaults.setObject("0", forKey: "happyScoreViewed")
        performSegueWithIdentifier("toMainfromTutorial", sender: self)

        
        
    }



}

