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
        boxView.layer.borderColor = UIColor.white.cgColor
        boxView.layer.borderWidth = 1.0
        
        guard let transaction = trans else {
            return
        }
        transLabel.text = transaction.name
        amountLabel.text = "-" + transaction.amount.format(".2")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE, MMM dd "
        let dateString = dateFormatter.string(from: transaction.date as Date)
        dateLabel.text = dateString.uppercased()
        
        let savingsTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CategoryViewController.didPressSavings))
        savingsView.isUserInteractionEnabled = true
        savingsView.addGestureRecognizer(savingsTapRecognizer)
        
        
        let billTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CategoryViewController.didPressBill))
        billsView.isUserInteractionEnabled = true
        billsView.addGestureRecognizer(billTapRecognizer)
        
        let spendingTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CategoryViewController.didPressSpending))
        spendingImgView.isUserInteractionEnabled = true
        spendingImgView.addGestureRecognizer(spendingTapRecognizer)
        
        let dontCountTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CategoryViewController.didPressDontCount))
        dontCountImgView.isUserInteractionEnabled = true
        dontCountImgView.addGestureRecognizer(dontCountTapRecognizer)
        
        if trans!.ctype == 3 {
            savingsView.image = UIImage(named: "blue_savings")
        }
        else if trans!.ctype == 1 {
            billsView.image = UIImage(named: "blue_bills")
        }
        else if trans!.ctype == 2 {
            spendingImgView.image = UIImage(named: "blue_spending")
        }
        else if trans!.ctype == 86 {
            dontCountImgView.image = UIImage(named: "blue_dont_count")
        }
    }
    
    
    func saveAllTransactions(_ ctype:Int)
   {
    
    
    // get all transactions for name
    
    let predicate = NSPredicate(format: "name = %@", trans!.name)
    
    try! realm.write {
        for transName in realm.objects(Transaction).filter(predicate) {
            transName.ctype = ctype
        }
    }
    
    
    }
    
    
    func didPressSavings() {
        saveAllTransactions(3)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func didPressBill() {
        saveAllTransactions(1)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func didPressSpending() {
        saveAllTransactions(2)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func didPressDontCount() {
        saveAllTransactions(86)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

    @IBAction func didPressClose(_ sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
}
