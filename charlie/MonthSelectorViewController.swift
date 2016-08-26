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
    
    @IBAction func didPressJanuary(_ sender: AnyObject) {
    }
    
    @IBAction func didPressFebruary(_ sender: AnyObject) {
    }
    
    @IBAction func didPressMarch(_ sender: AnyObject) {
    }
    
    @IBAction func didPressApril(_ sender: AnyObject) {
    }
    
    @IBAction func didPressMay(_ sender: AnyObject) {
    }
    
    @IBAction func didPressJune(_ sender: AnyObject) {
    }
    
    @IBAction func didPressJuly(_ sender: AnyObject) {
    }
    
    @IBAction func didPressAugust(_ sender: AnyObject) {
    }
    
    @IBAction func didPressSeptember(_ sender: AnyObject) {
    }
    
    @IBAction func didPressNovember(_ sender: AnyObject) {
    }
  
    @IBAction func didPressDecember(_ sender: AnyObject) {
    }
    
    @IBAction func didPressClose(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: { () -> Void in
        })
    }
}
