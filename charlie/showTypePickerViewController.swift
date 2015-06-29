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
    var transactionCell:SBGestureTableViewCell!
    
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var transactionNameLabel: UILabel!
    
    
   
    override func viewDidLoad() {
      super.viewDidLoad()
        
    transactionToUpdate  = realm.objects(Transaction).filter("_id = '\(transactionID)'")
    transactionNameLabel.text = transactionToUpdate[0].name
        
    }
    
    @IBAction func cancelButtonPress(sender: UIButton) {
        
         mainVC.transactionsTable.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
        mainVC.blurEffectView.hidden = true

        
    }
    
    @IBAction func spendableButtonPress(sender: UIButton) {

       
       // mainVC.transactionsTable.removeCell(transactionCell, duration: 0.3, completion: nil)
        
        realm.beginWrite()
            transactionToUpdate[0].ctype = Int(sender.tag)
            transactionToUpdate[0].status = 1
        realm.commitWrite()
        
        let transactionSum = mainVC.sumTransactionsCount()
        let transactionSumCurrecnyFormat = mainVC.formatCurrency(transactionSum)
        let finalFormat = mainVC.stripCents(transactionSumCurrecnyFormat)
        mainVC.moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)

        
        
        dismissViewControllerAnimated(true, completion: nil)
        mainVC.blurEffectView.hidden = true
        
        
        //check to see if others with same name exist
        
        
        let predicate = NSPredicate(format: "name = %@", transactionToUpdate[0].name )
        
       var sameTransactions = realm.objects(Transaction).filter(predicate)
        
       if sameTransactions.count > 0
        {
        
          for trans in sameTransactions
            {
                realm.beginWrite()
                    trans.ctype = Int(sender.tag)
                if sameTransactions.count > 1
                {

                    trans.status = 1
                }
                realm.commitWrite()
            }
            
            transactionItems = realm.objects(Transaction).filter(inboxPredicate)
            mainVC.transactionsTable.reloadData()
       
        }
        
        
       println(sameTransactions.count)
        
        
        
    }

}