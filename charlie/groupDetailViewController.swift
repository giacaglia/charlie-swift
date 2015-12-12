//
//  groupDetailViewController.swift
//  charlie
//
//  Created by James Caralis on 8/24/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//
import RealmSwift
import UIKit

class groupDetailViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var groupTableView: SBGestureTableViewGroup!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var transactionCount: UILabel!
    @IBOutlet weak var happyPercentage: UILabel!
    
    var transactionName:String = ""
    var transactionItems = realm.objects(Transaction)
    var happyItems = realm.objects(Transaction)
    var comingFromSad = false
    
    var happyAmount = 0.0
    var sadAmount = 0.0
    
    var startDate:NSDate = NSDate()
    var endDate:NSDate = NSDate()
    
    
    var currentTransactionSwipeID = ""
    var currentTransactionCell:SBGestureTableViewGroupCell!
    let checkImage = UIImage(named: "happy_on")
    let flagImage = UIImage(named: "sad_on")
    
    var removeCellBlockLeft: ((SBGestureTableViewGroup, SBGestureTableViewGroupCell) -> Void)!
    var removeCellBlockRight: ((SBGestureTableViewGroup, SBGestureTableViewGroupCell) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.barStyle = .Default
        groupTableView.tableFooterView = UIView();
        groupTableView.separatorStyle = .None
        self.name.text = transactionName

        let sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: false)]
        let predicate = NSPredicate(format: "date >= %@ and date <= %@ and name = %@", self.startDate, self.endDate, transactionName)
        transactionItems = realm.objects(Transaction).filter(predicate).sorted(sortProperties)
        
        
        happyItems = transactionItems.sorted("date", ascending: true)
        
        if transactionItems.count == 1 {
            self.transactionCount.text = "\(transactionItems.count) transaction"
        }
        else {
            self.transactionCount.text = "\(transactionItems.count) transactions"
        }
        let happyPercentage = calculateHappy()
        if (happyPercentage >= 50) {
            self.happyPercentage.textColor = listGreen
        }
        else {
            self.happyPercentage.textColor = listRed
        }
        self.happyPercentage.text = "\(happyPercentage)%"
        
        happyAmount = happyItems.sum("amount")
//        removeCellBlockLeft = {(tableView: SBGestureTableViewGroup, cell: SBGestureTableViewGroupCell) -> Void in
//            if self.stateOfTable == .WorthTable {
//                tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
//            }
//            else {
//                self.finishSwipe(tableView, cell: cell, direction: 1)
//            }
//        }
//        
//        removeCellBlockRight = {(tableView: SBGestureTableViewGroup, cell: SBGestureTableViewGroupCell) -> Void in
//            if self.stateOfTable == .NotWorthTable {
//                tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
//            }
//            else {
//                self.finishSwipe(tableView, cell: cell, direction: 2)
//            }
//        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackgroundNotification:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    func willEnterForeground(notification: NSNotification!) {
        if let resultController = storyboard!.instantiateViewControllerWithIdentifier("passcodeViewController") as? passcodeViewController {
            presentViewController(resultController, animated: true, completion: { () -> Void in
                cHelp.removeSpashImageView(self.view)
                cHelp.removeSpashImageView(self.presentingViewController!.view)
            })
        }
    }
    
    func didEnterBackgroundNotification(notification: NSNotification) {
        cHelp.splashImageView(self.view)
    }
    
    func finishSwipe(tableView: SBGestureTableViewGroup, cell: SBGestureTableViewGroupCell, direction: Int) {
        let indexPath = tableView.indexPathForCell(cell)
        currentTransactionCell = cell
        print("Direction \(direction)")
        
        currentTransactionSwipeID = transactionItems[indexPath!.row]._id
        realm.beginWrite()
        transactionItems[indexPath!.row].status = direction
        tableView.removeCell(cell, duration: 0.3, completion: nil)
        try! realm.commitWrite()
        
        happyAmount = happyItems.sum("amount")
      
        self.happyPercentage.text = "\(calculateHappy())%"
    }
    
    func setAttribText(message1:NSString, message2:NSString, button:UIButton, backGroundColor:UIColor, textColor:UIColor, textColor2:UIColor) {
        button.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        button.titleLabel?.textAlignment = NSTextAlignment.Center
        let buttonText: NSString = "\(message1)\n\(message2)"
        button.backgroundColor = backGroundColor
        
        //getting the range to separate the button title strings
        let newlineRange: NSRange = buttonText.rangeOfString("\n")
        
        //getting both substrings
        var substring1: NSString = ""
        var substring2: NSString = ""
        
        if newlineRange.location != NSNotFound {
            substring1 = buttonText.substringToIndex(newlineRange.location)
            substring2 = buttonText.substringFromIndex(newlineRange.location)
        }
        
        let attrs = [NSFontAttributeName : UIFont(name: "Avenir Next", size: 20.0)!]
        let attrString = NSMutableAttributedString(string: substring1 as String, attributes: attrs)
        let attrString1 = NSMutableAttributedString(string: substring2 as String, attributes: attrs)
        
        attrString.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSRange(location:0,length:substring1.length))
        attrString1.addAttribute(NSForegroundColorAttributeName, value: textColor2, range: NSRange(location:0,length:substring2.length))
        
        //appending both attributed strings
        attrString.appendAttributedString(attrString1)
        
        //assigning the resultant attributed strings to the button
        button.setAttributedTitle(attrString, forState: UIControlState.Normal)
    }
    
    func calculateHappy() -> Int {
        var happy = 0
        var sad = 0
        for trans in transactionItems {
            if trans.status == 1 {
                happy += 1
            }
            if trans.status == 2 {
                sad += 1
            }
        }
        if happy + sad == 0 {
            return 0
        }
        return Int((Double(happy) / Double((happy + sad)) * 100))
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "groupToDetail") {
            let viewController = segue.destinationViewController as! showTransactionViewController
            let indexPath = groupTableView.indexPathForSelectedRow
            viewController.transaction = transactionItems[indexPath!.row]
            viewController.transactionIndex = indexPath!.row
            viewController.sourceVC = "happy"
        }
    }
    
    //actions
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// TableView Methods
extension groupDetailViewController {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SBGestureTableViewGroupCell
//        cell.firstLeftAction = SBGestureTableViewGroupCellAction(icon: checkImage!, color: listGreen, fraction: 0.35, didTriggerBlock: removeCellBlockLeft)
//        cell.firstRightAction = SBGestureTableViewGroupCellAction(icon: flagImage!, color: listRed, fraction: 0.35, didTriggerBlock: removeCellBlockRight)
    
        let trans = transactionItems[indexPath.row]
        let dateString = cHelp.convertDateGroup(trans.date)
        let currencyString = cHelp.formatCurrency(trans.amount)
        cell.transactionDate.text = dateString
        cell.transactionAmount.text = currencyString
        if trans.status == 2 { cell.transactionAmount.textColor = listRed }
        else if trans.status == 1 { cell.transactionAmount.textColor = listGreen }
        else { cell.transactionAmount.textColor = mediumGray }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("groupToDetail", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
