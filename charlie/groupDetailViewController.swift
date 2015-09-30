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
    
    @IBOutlet weak var sadButton: UIButton!
    @IBOutlet weak var happyButton: UIButton!
    @IBOutlet weak var groupTableView: SBGestureTableViewGroup!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var transactionCount: UILabel!
    @IBOutlet weak var happyPercentage: UILabel!
    
    var transactionName:String = ""
    var transactionItems = realm.objects(Transaction)
    var happyItems = realm.objects(Transaction)
    var sadItems = realm.objects(Transaction)
    var comingFromSad = false
    
    var happyAmount = 0.0
    var sadAmount = 0.0
    
    var currentTransactionSwipeID = ""
    var currentTransactionCell:SBGestureTableViewGroupCell!
    let checkImage = UIImage(named: "happy_on")
    let flagImage = UIImage(named: "sad_on")
    
    var removeCellBlockLeft: ((SBGestureTableViewGroup, SBGestureTableViewGroupCell) -> Void)!
    var removeCellBlockRight: ((SBGestureTableViewGroup, SBGestureTableViewGroupCell) -> Void)!
   
    enum TypeOfTable {
        case NotWorthTable, WorthTable
    }
    var stateOfTable : TypeOfTable! = .NotWorthTable
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackgroundNotification:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        groupTableView.tableFooterView = UIView();
        self.name.text = transactionName
        let groupDetailPredicate = NSPredicate(format: "status > 0 AND name = %@", transactionName)
        let sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: true)]
        transactionItems = realm.objects(Transaction).filter(groupDetailPredicate).sorted(sortProperties)
        
        happyItems = transactionItems.filter("status = 1").sorted("date", ascending: true)
        sadItems = transactionItems.filter("status = 2").sorted("date", ascending: true)
        
        if transactionItems.count == 1 {
            self.transactionCount.text = "\(transactionItems.count) transaction"
        }
        else {
            self.transactionCount.text = "\(transactionItems.count) transactions"
        }
        self.happyPercentage.text = "\(calculateHappy())%"
        
        sadAmount = sadItems.sum("amount")
        happyAmount = happyItems.sum("amount")
        
        removeCellBlockLeft = {(tableView: SBGestureTableViewGroup, cell: SBGestureTableViewGroupCell) -> Void in
            if self.stateOfTable == .WorthTable {
                tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
            }
            else {
                self.finishSwipe(tableView, cell: cell, direction: 1)
            }
        }
        
        removeCellBlockRight = {(tableView: SBGestureTableViewGroup, cell: SBGestureTableViewGroupCell) -> Void in
            if self.stateOfTable == .NotWorthTable {
                tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
            }
            else {
                self.finishSwipe(tableView, cell: cell, direction: 2)
            }
        }
        
        if comingFromSad {
            stateOfTable = .NotWorthTable
            
            setAttribText("$\(sadAmount)", message2: "NOT WORTH IT", button: sadButton, backGroundColor: listRed, textColor: UIColor.whiteColor(), textColor2: UIColor.whiteColor())
            setAttribText("$\(happyAmount)", message2: "WORTH IT", button: happyButton, backGroundColor: UIColor.whiteColor(), textColor: listGreen, textColor2: UIColor.lightGrayColor())
        }
        else {
            stateOfTable = .WorthTable
            
            setAttribText("$\(sadAmount)", message2: "NOT WORTH IT", button: sadButton,  backGroundColor: UIColor.whiteColor(), textColor: listRed, textColor2: UIColor.lightGrayColor())
            setAttribText("$\(happyAmount)", message2: "WORTH IT", button: happyButton, backGroundColor: listGreen, textColor: UIColor.whiteColor(), textColor2: UIColor.whiteColor())
        }
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
        
        if stateOfTable == .WorthTable {
            currentTransactionSwipeID = happyItems[indexPath!.row]._id
            realm.beginWrite()
            happyItems[indexPath!.row].status = direction
            tableView.removeCell(cell, duration: 0.3, completion: nil)
            try! realm.commitWrite()
            
            sadAmount = sadItems.sum("amount")
            happyAmount = happyItems.sum("amount")
            
            setAttribText("$\(sadAmount)", message2: "NOT WORTH IT" , button: sadButton,  backGroundColor: UIColor.whiteColor(), textColor: listRed, textColor2: UIColor.lightGrayColor())
            setAttribText("$\(happyAmount)", message2: "WORTH IT", button: happyButton, backGroundColor: listGreen, textColor: UIColor.whiteColor(), textColor2: UIColor.whiteColor())
        }
        else {
            currentTransactionSwipeID = sadItems[indexPath!.row]._id
            realm.beginWrite()
            sadItems[indexPath!.row].status = direction
            tableView.removeCell(cell, duration: 0.3, completion: nil)
            try! realm.commitWrite()
            
            sadAmount = sadItems.sum("amount")
            happyAmount = happyItems.sum("amount")
            
            setAttribText("$\(sadAmount)", message2: "NOT WORTH IT", button: sadButton, backGroundColor: listRed, textColor: UIColor.whiteColor(),textColor2: UIColor.whiteColor())
            setAttribText("$\(happyAmount)", message2: "WORTH IT", button: happyButton, backGroundColor: UIColor.whiteColor(), textColor: listGreen, textColor2: UIColor.lightGrayColor())
        }
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
        return Int((Double(happy) / Double((happy + sad)) * 100))
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "groupToDetail") {
            let viewController = segue.destinationViewController as! showTransactionViewController
            //viewController.mainVC = self
            let indexPath = groupTableView.indexPathForSelectedRow
            if stateOfTable == .WorthTable {
                viewController.transactionID = happyItems[indexPath!.row]._id
                viewController.sourceVC = "happy"
            }
            else {
                viewController.transactionID = sadItems[indexPath!.row]._id
                viewController.sourceVC = "sad"
            }
        }
    }
    
    @IBAction func notWorthButtonPress(sender: UIButton) {
        stateOfTable = .NotWorthTable
        
        setAttribText("$\(sadAmount)", message2: "NOT WORTH IT" , button: sadButton, backGroundColor: listRed, textColor: UIColor.whiteColor(),textColor2: UIColor.whiteColor())
        setAttribText("$\(happyAmount)", message2: "WORTH IT", button: happyButton, backGroundColor: UIColor.whiteColor(), textColor: listGreen, textColor2: UIColor.lightGrayColor())
        
        groupTableView.reloadData()
    }
    
    
    @IBAction func worthButtonPress(sender: UIButton) {
        stateOfTable = .WorthTable
        
        setAttribText("$\(sadAmount)", message2: "NOT WORTH IT", button: sadButton,  backGroundColor: UIColor.whiteColor(), textColor: listRed, textColor2: UIColor.lightGrayColor())
        setAttribText("$\(happyAmount)", message2: "WORTH IT", button: happyButton, backGroundColor: listGreen, textColor: UIColor.whiteColor(),textColor2: UIColor.whiteColor())
        
        groupTableView.reloadData()
    }
    
    //actions
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// TableView Methods
extension groupDetailViewController {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stateOfTable == .NotWorthTable {
            return sadItems.count
        }
        else {
            return happyItems.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SBGestureTableViewGroupCell
        cell.firstLeftAction = SBGestureTableViewGroupCellAction(icon: checkImage!, color: listGreen, fraction: 0.35, didTriggerBlock: removeCellBlockLeft)
        cell.firstRightAction = SBGestureTableViewGroupCellAction(icon: flagImage!, color: listRed, fraction: 0.35, didTriggerBlock: removeCellBlockRight)
        
        if stateOfTable == .NotWorthTable {
            let dateString = cHelp.convertDateGroup(sadItems[indexPath.row].date)
            let currencyString = cHelp.formatCurrency(sadItems[indexPath.row].amount)
            cell.transactionDate.text = dateString
            cell.transactionAmount.text =  currencyString
        }
        else {
            let dateString = cHelp.convertDateGroup(happyItems[indexPath.row].date)
            let currencyString = cHelp.formatCurrency(happyItems[indexPath.row].amount)
            cell.transactionDate.text = dateString
            cell.transactionAmount.text = currencyString
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("groupToDetail", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
