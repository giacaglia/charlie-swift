//
//  showTypePickerViewController.swift
//  charlie
//
//  Created by Jim Caralis on 6/24/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit

class showTypePickerViewController: UIViewController {
    
    
    
    @IBOutlet weak var pickerView: UIView!
    
      var transactionID:String = ""
      var mainVC:mainViewController!
    
    
    override func viewDidLoad() {
      super.viewDidLoad()
        
      pickerView.layer.cornerRadius = 20
        
    }
    
    
    @IBAction func spendableButtonPress(sender: UIButton) {
 
    
    let transactionToUpdate  = realm.objects(Transaction).filter("_id = '\(transactionID)'")
        
    realm.beginWrite()
        transactionToUpdate[0].ctype = Int(sender.tag)
    realm.commitWrite()
        
        
    dismissViewControllerAnimated(true, completion: nil)
    mainVC.DynamicView.hidden = true
    
    }
   
    


}