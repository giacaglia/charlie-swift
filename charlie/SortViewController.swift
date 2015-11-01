//
//  sortViewController.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 10/1/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//

import Foundation

class SortViewController : UIViewController {

    @IBOutlet weak var howShouldISortLabel: UILabel!
    @IBOutlet weak var mostRecentButton: UIButton!
    @IBOutlet weak var amountButton: UIButton!
    @IBOutlet weak var alphabeticalButton: UIButton!
    @IBOutlet weak var leastRecentButton: UIButton!
    @IBOutlet weak var mostWorthButton: UIButton!
    @IBOutlet weak var leastWorthButton: UIButton!
    @IBOutlet weak var dividerWorthView: UIView!
    
    let grayColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
    var delegate:ChangeFilterProtocol? = nil
    var initialFilterType : SortFilterType? = nil
    var transactionType : TransactionType = .InboxTransaction
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if initialFilterType == .FilterByDescendingDate {
            mostRecentButton.setTitleColor(listBlue, forState: .Normal)
        }
        else if initialFilterType == .FilterByDate {
            leastRecentButton.setTitleColor(listBlue, forState: .Normal)
        }
        else if initialFilterType == .FilterByName {
            alphabeticalButton.setTitleColor(listBlue, forState: .Normal)
        }
        else if initialFilterType == .FilterByAmount {
            amountButton.setTitleColor(listBlue, forState: .Normal)
        }
        else if initialFilterType == .FilterByMostWorth {
            mostWorthButton.setTitleColor(listBlue, forState: .Normal)
        }
        else if initialFilterType == .FilterByLeastWorth {
            leastWorthButton.setTitleColor(listBlue, forState: .Normal)
        }
        
        if (transactionType == .InboxTransaction) {
            self.howShouldISortLabel.text = "How should I sort your inbox?"
            self.mostWorthButton.hidden = true
            self.leastWorthButton.hidden = true
            self.dividerWorthView.hidden = true
        }
        else {
            self.howShouldISortLabel.text = "How should I sort your archive?"
            self.mostWorthButton.hidden = false
            self.leastWorthButton.hidden = false
            self.dividerWorthView.hidden = false
        }
    }
    
    @IBAction func mostRecentPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(0)
        mostRecentButton.setTitleColor(listBlue, forState: .Normal)
        self.closePressed(self.mostRecentButton)
        self.delegate?.changeFilter(.FilterByDescendingDate)
    }
    
    @IBAction func leastRecentPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(1)
        leastRecentButton.setTitleColor(listBlue, forState: .Normal)
        self.closePressed(self.leastRecentButton)
        self.delegate?.changeFilter(.FilterByDate)
    }
    
    @IBAction func alphabeticalPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(2)
        alphabeticalButton.setTitleColor(listBlue, forState: .Normal)
        self.closePressed(self.alphabeticalButton)
        self.delegate?.changeFilter(.FilterByName)
    }

    @IBAction func amountPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(3)
        amountButton.setTitleColor(listBlue, forState: .Normal)
        self.closePressed(self.amountButton)
        self.delegate?.changeFilter(.FilterByAmount)
    }
      
    @IBAction func mostWorthPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(4)
        mostWorthButton.setTitleColor(listBlue, forState: .Normal)
        self.closePressed(mostWorthButton)
        self.delegate?.changeFilter(.FilterByMostWorth)
    }
    
    @IBAction func leastWorthPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(5)
        leastRecentButton.setTitleColor(listBlue, forState: .Normal)
        self.closePressed(leastWorthButton)
        self.delegate?.changeFilter(.FilterByLeastWorth)
    }
    
    private func allButtonsGrayExcept(buttonIndex: Int) {
        if buttonIndex != 0 {mostRecentButton.setTitleColor(grayColor, forState: .Normal)}
        if buttonIndex != 1 {leastRecentButton.setTitleColor(grayColor, forState: .Normal)}
        if buttonIndex != 2 {alphabeticalButton.setTitleColor(grayColor, forState: .Normal)}
        if buttonIndex != 3 {amountButton.setTitleColor(grayColor, forState: .Normal)}
        if buttonIndex != 4 {mostWorthButton.setTitleColor(grayColor, forState: .Normal)}
        if buttonIndex != 5 {leastWorthButton.setTitleColor(grayColor, forState: .Normal)}
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)
            self.delegate?.removeBlackView()
        })
        { (success) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
}
