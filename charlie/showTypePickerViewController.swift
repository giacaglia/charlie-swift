//
//  showTypePickerViewController.swift
//  charlie
//
//  Created by Jim Caralis on 6/24/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit

class showTypePickerViewController: UIViewController {
    
    
    
    var transactionID:String = ""
    var mainVC:mainViewController!
    var transactionToUpdate  = realm.objects(Transaction)
    
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var transactionNameLabel: UILabel!
    
   
    override func viewDidLoad() {
      super.viewDidLoad()
        
    transactionToUpdate  = realm.objects(Transaction).filter("_id = '\(transactionID)'")
    transactionNameLabel.text = transactionToUpdate[0].name
        
    }
    
    
    @IBAction func spendableButtonPress(sender: UIButton) {

       
        realm.beginWrite()
            transactionToUpdate[0].ctype = Int(sender.tag)
        realm.commitWrite()
        dismissViewControllerAnimated(true, completion: nil)
        mainVC.blurEffectView.hidden = true
        
        
        //check to see if others with same name exist
        
       var sameTransactions = realm.objects(Transaction).filter("name = '\(transactionToUpdate[0].name)'")
        
       if sameTransactions.count > 0
        {
        
          for trans in sameTransactions
            {
                realm.beginWrite()
                    trans.ctype = Int(sender.tag)
                realm.commitWrite()
            }
            
            //requery to update mainview table with changes and re-load 
            transactionItems = realm.objects(Transaction).filter("status = 0").sorted("amount", ascending: false)
            mainVC.transactionsTable.reloadData()
       
        }
        
        
       println(sameTransactions.count)
        
        
        
    }

}