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
    @IBOutlet weak var LeastWorthButton: UIButton!
    @IBOutlet weak var dividerWorthView: UIView!
    
    let grayColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
    var delegate:ChangeFilterProtocol? = nil
    var initialFilterType : SortFilterType? = nil
    var transactionType : TransactionType = .InboxTransaction
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.initialFilterType == .FilterByDescendingDate {
            self.mostRecentButton.titleLabel?.textColor = listBlue
        }
        else if self.initialFilterType == .FilterByDate {
            self.leastRecentButton.titleLabel?.textColor = listBlue
        }
        else if self.initialFilterType == .FilterByName {
            self.alphabeticalButton.titleLabel?.textColor = listBlue
        }
        else {
            self.amountButton.titleLabel?.textColor = listBlue
        }
        
        
        if (transactionType == .InboxTransaction) {
            self.howShouldISortLabel.text = "How should I sort your inbox?"
            self.mostWorthButton.hidden = true
            self.LeastWorthButton.hidden = true
            self.dividerWorthView.hidden = true
        }
        else {
            self.howShouldISortLabel.text = "How should I sort your archive?"
            self.mostWorthButton.hidden = false
            self.LeastWorthButton.hidden = false
            self.dividerWorthView.hidden = false
        }
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
      
    @IBAction func mostWorthPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(4)
        mostWorthButton.titleLabel?.textColor = listBlue
        self.closePressed(mostWorthButton)
        self.delegate?.changeFilter(.FilterByAmount)
    }
    
    @IBAction func leastWorthPressed(sender: AnyObject) {
        self.allButtonsGrayExcept(5)
        LeastWorthButton.titleLabel?.textColor = listBlue
        self.closePressed(LeastWorthButton)
        self.delegate?.changeFilter(.FilterByAmount)
    }
    
    private func allButtonsGrayExcept(buttonIndex: Int) {
        if buttonIndex != 0 {mostRecentButton.titleLabel?.textColor = grayColor}
        if buttonIndex != 1 {leastRecentButton.titleLabel?.textColor = grayColor}
        if buttonIndex != 2 {alphabeticalButton.titleLabel?.textColor = grayColor}
        if buttonIndex != 3 {amountButton.titleLabel?.textColor = grayColor}
        if buttonIndex != 4 {mostWorthButton.titleLabel?.textColor = grayColor}
        if buttonIndex != 5 {LeastWorthButton.titleLabel?.textColor = grayColor}
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
