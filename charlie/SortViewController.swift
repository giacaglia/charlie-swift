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
    var transactionType : TransactionType = .inboxTransaction
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialFilterType == .filterByDescendingDate {
            mostRecentButton.setTitleColor(listBlue, for: UIControlState())
        }
//        else if initialFilterType == .FilterByDate {
//            leastRecentButton.setTitleColor(listBlue, forState: .Normal)
//        }
        else if initialFilterType == .filterByName {
            alphabeticalButton.setTitleColor(listBlue, for: UIControlState())
        }
        else if initialFilterType == .filterByAmount {
            amountButton.setTitleColor(listBlue, for: UIControlState())
        }
//        else if initialFilterType == .FilterByMostWorth {
//            mostWorthButton.setTitleColor(listBlue, forState: .Normal)
//        }
        else if initialFilterType == .filterByLeastWorth {
            leastWorthButton.setTitleColor(listBlue, for: UIControlState())
        }
        
        if (transactionType == .inboxTransaction) {
            self.howShouldISortLabel.text = "How should I sort your inbox?"
            self.mostWorthButton.isHidden = true
            self.leastWorthButton.isHidden = true
            self.dividerWorthView.isHidden = true
        }
        else {
            self.howShouldISortLabel.text = "How should I sort your archive?"
            self.mostWorthButton.isHidden = false
            self.leastWorthButton.isHidden = false
            self.dividerWorthView.isHidden = false
        }
    }
    
    @IBAction func mostRecentPressed(_ sender: AnyObject) {
        self.allButtonsGrayExcept(0)
        mostRecentButton.setTitleColor(listBlue, for: UIControlState())
        self.closePressed(self.mostRecentButton)
        self.delegate?.changeFilter(.filterByDescendingDate)
    }
    
    @IBAction func leastRecentPressed(_ sender: AnyObject) {
        self.allButtonsGrayExcept(1)
        leastRecentButton.setTitleColor(listBlue, for: UIControlState())
        self.closePressed(self.leastRecentButton)
        self.delegate?.changeFilter(.filterByDate)
    }
    
    @IBAction func alphabeticalPressed(_ sender: AnyObject) {
        self.allButtonsGrayExcept(2)
        alphabeticalButton.setTitleColor(listBlue, for: UIControlState())
        self.closePressed(self.alphabeticalButton)
        self.delegate?.changeFilter(.filterByName)
    }

    @IBAction func amountPressed(_ sender: AnyObject) {
        self.allButtonsGrayExcept(3)
        amountButton.setTitleColor(listBlue, for: UIControlState())
        self.closePressed(self.amountButton)
        self.delegate?.changeFilter(.filterByAmount)
    }
      
    @IBAction func mostWorthPressed(_ sender: AnyObject) {
        self.allButtonsGrayExcept(4)
        mostWorthButton.setTitleColor(listBlue, for: UIControlState())
        self.closePressed(mostWorthButton)
        self.delegate?.changeFilter(.filterByMostWorth)
    }
    
    @IBAction func leastWorthPressed(_ sender: AnyObject) {
        self.allButtonsGrayExcept(5)
        leastRecentButton.setTitleColor(listBlue, for: UIControlState())
        self.closePressed(leastWorthButton)
        self.delegate?.changeFilter(.filterByLeastWorth)
    }
    
    fileprivate func allButtonsGrayExcept(_ buttonIndex: Int) {
        if buttonIndex != 0 {mostRecentButton.setTitleColor(grayColor, for: UIControlState())}
//        if buttonIndex != 1 {leastRecentButton.setTitleColor(grayColor, forState: .Normal)}
        if buttonIndex != 2 {alphabeticalButton.setTitleColor(grayColor, for: UIControlState())}
        if buttonIndex != 3 {amountButton.setTitleColor(grayColor, for: UIControlState())}
        if buttonIndex != 4 {mostWorthButton.setTitleColor(grayColor, for: UIControlState())}
    //    if buttonIndex != 5 {leastWorthButton.setTitleColor(grayColor, forState: .Normal)}
    }
    
    @IBAction func closePressed(_ sender: AnyObject) {
        self.willMove(toParentViewController: nil)
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.view.frame = CGRect(x: 0, y: -self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.delegate?.removeBlackView()
        })
        { (success) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
}
