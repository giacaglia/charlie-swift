//
//  CategoryViewController.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 1/23/16.
//  Copyright © 2016 James Caralis. All rights reserved.
//

import Foundation


class CategoryViewController : UIViewController {
    var trans : Transaction?
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var transLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var savingsView: UIImageView!
    @IBOutlet weak var billsView: UIImageView!
    @IBOutlet weak var spendingImgView: UIImageView!
    @IBOutlet weak var dontCountImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boxView.layer.borderColor = UIColor.whiteColor().CGColor
        boxView.layer.borderWidth = 1.0
        
        guard let transaction = trans else {
            return
        }
        transLabel.text = transaction.name
        amountLabel.text = "-" + transaction.amount.format(".2")
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EE, MMM dd "
        let dateString = dateFormatter.stringFromDate(transaction.date)
        dateLabel.text = dateString.uppercaseString
        
        let savingsTapRecognizer = UITapGestureRecognizer(target: self, action: "didPressSavings")
        savingsView.userInteractionEnabled = true
        savingsView.addGestureRecognizer(savingsTapRecognizer)
        
        
        let billTapRecognizer = UITapGestureRecognizer(target: self, action: "didPressBill")
        billsView.userInteractionEnabled = true
        billsView.addGestureRecognizer(billTapRecognizer)
        
        let spendingTapRecognizer = UITapGestureRecognizer(target: self, action: "didPressSpending")
        spendingImgView.userInteractionEnabled = true
        spendingImgView.addGestureRecognizer(spendingTapRecognizer)
        
        let dontCountTapRecognizer = UITapGestureRecognizer(target: self, action: "didPressDontCount")
        dontCountImgView.userInteractionEnabled = true
        dontCountImgView.addGestureRecognizer(dontCountTapRecognizer)
        
        if trans!.user_category == "Savings" {
            savingsView.image = UIImage(named: "blue_savings")
        }
        else if trans!.user_category == "Bills" {
            billsView.image = UIImage(named: "blue_bills")
        }
        else if trans!.user_category == "Spending" {
            spendingImgView.image = UIImage(named: "blue_spending")
        }
        else if trans!.user_category == "Don't Count" {
            dontCountImgView.image = UIImage(named: "blue_dont_count")
        }
    }
    
    
    func didPressSavings() {
        realm.beginWrite()
        trans?.user_category = "Savings"
        try! realm.commitWrite()
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func didPressBills() {
        realm.beginWrite()
        trans?.user_category = "Bills"
        try! realm.commitWrite()
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func didPressSpending() {
        realm.beginWrite()
        trans?.user_category = "Spending"
        try! realm.commitWrite()
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func didPressDontCount() {
        realm.beginWrite()
        trans?.user_category = "Don't Count"
        try! realm.commitWrite()
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

    @IBAction func didPressClose(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
}