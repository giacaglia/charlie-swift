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
    
    @IBOutlet weak var happyFlowDefinition: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderAmount: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    let blueThumb = UIImage(named: "slider_neutral")
    let redThumb = UIImage(named: "slider_sad")
    let greenThumb = UIImage(named: "slider_happy")
    
    override func viewDidAppear(animated: Bool) {
        //if no users and we have icloud access token we should restore user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderAmount.textColor = listBlue
        nextButton.backgroundColor = listBlue
        nextButton.layer.cornerRadius = 10
        
        happyFlowDefinition.layer.cornerRadius = 20
        happyFlowDefinition.layer.borderWidth = 1
        happyFlowDefinition.layer.borderColor = lightGray.CGColor
        slider.setThumbImage(blueThumb, forState: UIControlState.Normal)
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
        performSegueWithIdentifier("happyFlowToLogin", sender: self)
        
        //add way to send what was guessed
        charlieAnalytics.track("Happy Flow Guessed")
    }
    
}