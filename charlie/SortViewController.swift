//
//  sortViewController.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 10/1/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//

import Foundation

class SortViewController : UIViewController {

    @IBOutlet weak var mostRecentButton: UIButton!
    @IBOutlet weak var amountButton: UIButton!
    @IBOutlet weak var alphabeticalButton: UIButton!
    @IBOutlet weak var leastRecentButton: UIButton!
    let grayColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
    var delegate:ChangeFilterProtocol? = nil
    var initialFilterType : SortFilterType? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.initialFilterType == .FilterByName { self.mostRecentButton.titleLabel?.textColor = listBlue }
        else if self.initialFilterType == .FilterByDescendingDate { self.leastRecentButton.titleLabel?.textColor = listBlue }
        else if self.initialFilterType == .FilterByDate {self.alphabeticalButton.titleLabel?.textColor = listBlue}
        else {self.amountButton.titleLabel?.textColor = listBlue}
    }
    
    @IBAction func mostRecentPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(0)
        mostRecentButton.titleLabel?.textColor = listBlue
        self.closePressed(self.mostRecentButton)
        self.delegate?.changeFilter(.FilterByDescendingDate)
    }
    
    @IBAction func leastRecentPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(1)
        leastRecentButton.titleLabel?.textColor = listBlue
        self.closePressed(self.leastRecentButton)
        self.delegate?.changeFilter(.FilterByDate)
    }
    
    @IBAction func alphabeticalPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(2)
        alphabeticalButton.titleLabel?.textColor = listBlue
        self.closePressed(self.alphabeticalButton)
        self.delegate?.changeFilter(.FilterByName)
    }

    @IBAction func amountPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(3)
        amountButton.titleLabel?.textColor = listBlue
        self.closePressed(self.amountButton)
        self.delegate?.changeFilter(.FilterByAmount)
    }
    
    @IBAction func allPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(1)
        leastRecentButton.titleLabel?.textColor = listBlue
        self.closePressed(self.leastRecentButton)
        self.delegate?.changeTransactionType(.FlaggedTransaction)
    }
    
    @IBAction func worthPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(1)
        leastRecentButton.titleLabel?.textColor = listBlue
        self.closePressed(self.leastRecentButton)
        self.delegate?.changeTransactionType(.ApprovedTransaction)
    }
    
    @IBAction func notWorthPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(1)
        leastRecentButton.titleLabel?.textColor = listBlue
        self.closePressed(self.leastRecentButton)
        self.delegate?.changeTransactionType(.FlaggedTransaction)
    }
    
    private func allButtonsGrayExcept(buttonIndex: Int) {
//        if buttonIndex != 0 {mostRecentButton.titleLabel?.textColor = grayColor}
//        if buttonIndex != 1 {leastRecentButton.titleLabel?.textColor = grayColor}
//        if buttonIndex != 2 {alphabeticalButton.titleLabel?.textColor = grayColor}
//        if buttonIndex != 3 {amountButton.titleLabel?.textColor = grayColor}
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)
//            self.delegate?.changeFilter(self.initialFilterType!)
        })
        { (success) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
}
