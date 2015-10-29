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
    @IBOutlet weak var transactionNameLabel: UILabel!
    
    var transactionID:String = ""
    var mainVC:mainViewController!
    var transactionToUpdate  = realm.objects(Transaction)
    var transactionCell:SBGestureTableViewCell!
    var cHelp = cHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionToUpdate  = realm.objects(Transaction).filter("_id = '\(transactionID)'")
        transactionNameLabel.text = transactionToUpdate[0].name
    }
    
    @IBAction func cancelButtonPress(sender: UIButton) {
        mainVC.transactionsTable.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func spendableButtonPress(sender: UIButton) {
        // mainVC.transactionsTable.removeCell(transactionCell, duration: 0.3, completion: nil)
        realm.beginWrite()
        transactionToUpdate[0].ctype = Int(sender.tag)
        try! realm.commitWrite()
        dismissViewControllerAnimated(true, completion: nil)
        for trans in transactionItems {
            if trans.ctype == 0 && trans.name == transactionToUpdate[0].name {
                print("repeat")
                try!  realm.write {
                    trans.ctype = Int(sender.tag)
                }
            }
        }
        transactionItems = realm.objects(Transaction).filter(inboxPredicate)
        mainVC.transactionsTable.reloadData()
    }
    
}