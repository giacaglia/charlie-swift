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
    }

    @IBAction func didPressClose(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
}