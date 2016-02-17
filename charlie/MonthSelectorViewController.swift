//
//  MonthSelectorViewController.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 2/16/16.
//  Copyright © 2016 James Caralis. All rights reserved.
//

import Foundation

class MonthSelectorViewController : UIViewController {
    @IBOutlet weak var januaryButton: UIButton!
    @IBOutlet weak var februaryButton: UIButton!
    @IBOutlet weak var marchButton: UIButton!
    @IBOutlet weak var aprilButton: UIButton!
    @IBOutlet weak var mayButton: UIButton!
    @IBOutlet weak var juneButton: UIButton!
    @IBOutlet weak var julyButton: UIButton!
    @IBOutlet weak var augustButton: UIButton!
    @IBOutlet weak var septemberButton: UIButton!
    @IBOutlet weak var octoberButton: UIButton!
    @IBOutlet weak var novemberButton: UIButton!
    @IBOutlet weak var decemberButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didPressJanuary(sender: AnyObject) {
    }
    
    @IBAction func didPressFebruary(sender: AnyObject) {
    }
    
    @IBAction func didPressMarch(sender: AnyObject) {
    }
    
    @IBAction func didPressApril(sender: AnyObject) {
    }
    
    @IBAction func didPressMay(sender: AnyObject) {
    }
    
    @IBAction func didPressJune(sender: AnyObject) {
    }
    
    @IBAction func didPressJuly(sender: AnyObject) {
    }
    
    @IBAction func didPressAugust(sender: AnyObject) {
    }
    
    @IBAction func didPressSeptember(sender: AnyObject) {
    }
    
    @IBAction func didPressNovember(sender: AnyObject) {
    }
  
    @IBAction func didPressDecember(sender: AnyObject) {
    }
    
    @IBAction func didPressClose(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
}