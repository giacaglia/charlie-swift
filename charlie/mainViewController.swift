//
//  mainViewController.swift
//  charlie
//
//  Created by James Caralis on 6/7/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
import BladeKit
import RealmSwift
import WebKit
import Charts

//number of days we show transaction data for
let showTransactionDays = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -35, toDate: NSDate(), options: [])!
let status = 0
var inboxPredicate = NSPredicate() //items yet to be processed
var approvedPredicate = NSPredicate() // items marked as worth it
var flaggedPredicate = NSPredicate() // items makes as not worth it
var actedUponPredicate = NSPredicate() // items marked as either worth it or not worth it
var groupedPredicate = NSPredicate()
var charlieGroupList = [charlieGroup]()
var charlieGroupListFiltered = [charlieGroup]()
var keyStore = NSUbiquitousKeyValueStore()
var keyChainStore = KeychainHelper()
var transactionItems = realm.objects(Transaction)
var allTransactionItems = realm.objects(Transaction).sorted("date", ascending: false)

enum TransactionType {
    case FlaggedTransaction, ApprovedTransaction, ApprovedAndFlaggedTransaction,InboxTransaction
}

enum SortFilterType {
    case FilterByName, FilterByDate, FilterByDescendingDate, FilterByAmount
}

protocol ChangeFilterProtocol {
    func changeFilter( filterType: SortFilterType )
    func changeTransactionType( type : TransactionType)
}

class mainViewController: UIViewController, ChangeFilterProtocol {
    
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var transactionsTable: SBGestureTableView!
    @IBOutlet weak var listNavBar: UIView!
    @IBOutlet weak var inboxListButton: UIButton!
    @IBOutlet weak var flagListButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var accountAddView: UIView!
    @IBOutlet weak var rewardView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topSeperator: UIView!
    @IBOutlet weak var moneyCountSubSubHeadLabel: UILabel!
    @IBOutlet weak var addAccountButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var cardButton: UIButton!
    
    var cHelp = cHelper()
    var currentTransactionSwipeID = ""
    var currentTransactionCell:SBGestureTableViewCell!
    let checkImage = UIImage(named: "happy_on")
    let flagImage = UIImage(named: "sad_on")
    
    let inboxUnSelectedSadButtonImage = UIImage(named: "neutral_off_red")
    let inboxUnSelectedHappyButtonImage = UIImage(named: "neutral_off_green")
    
    let inboxSelectedButtonImage = UIImage(named: "neutral_on")
    let flagUnSelectedHappyButtonImage = UIImage(named: "sad_off_green")
    let flagUnSelectedInboxButtonImage = UIImage(named: "sad_off_blue")
    let flagSelectedButtonImage = UIImage(named: "sad_on")
    let approvedUnSelectedInboxButtonImage = UIImage(named: "happy_off_blue")
    let approvedUnSelectedSadButtonImage = UIImage(named: "happy_off_red")
    let approvedSelectedButtonImage = UIImage(named: "happy_on")
    let menuButtonBlueImage = UIImage(named: "btn-menu-blue.png")
    let menuButtonGreenImage = UIImage(named: "btn-menu-green.png")
    let menuButtonRedImage = UIImage(named: "btn-menu-red.png")
    
    let cardButtonBlueImage = UIImage(named: "btn-card-blue.png")
    let cardButtonGreenImage = UIImage(named: "btn-card-green.png")
    let cardButtonRedImage = UIImage(named: "btn-card-red.png")
    
    var removeCellBlockLeft: ((SBGestureTableView, SBGestureTableViewCell) -> Void)!
    var removeCellBlockRight: ((SBGestureTableView, SBGestureTableViewCell) -> Void)!
    let users = realm.objects(User)
    let accounts = realm.objects(Account)
    var timer = NSTimer()
    var timerCount:Int = 0
    var DynamicView = UIView(frame: UIScreen.mainScreen().bounds)
    var pinApproved = false
    var filterType : SortFilterType! = .FilterByName
    var inboxType : TransactionType! = .FlaggedTransaction
    var blackView : UIView?
    var areThereMoreItemsToLoad = false
    var numItemsToLoad = 20
    
    func willEnterForeground(notification: NSNotification!) {
        if let resultController = storyboard!.instantiateViewControllerWithIdentifier("passcodeViewController") as? passcodeViewController {
            presentViewController(resultController, animated: false, completion: { () -> Void in
                self.pinApproved = true
                self.cHelp.removeSpashImageView(self.view)
            })
        }
    }
    
    
    func didEnterBackgroundNotification(notification: NSNotification) {
        cHelp.splashImageView(self.view)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        //if accounts have been added but we don't have transactions that means plaid hasn't retreived transactions yet so check plaid until they have them every x seconds
        if accounts.count > 0 && allTransactionItems.count == 0 {
            if timerCount == 0 {
                //first time after adding account so show tutorial
                print("account but no transactions")
                timer = NSTimer.scheduledTimerWithTimeInterval(10, target:self, selector: Selector("updateTrans"), userInfo: nil, repeats: true)
                performSegueWithIdentifier("showTutorial", sender: self)
                timerCount = 1
                spinner.startAnimating()
                toastView.hidden = false
                accountAddView.hidden = true
                //show toast
            }
            else {
                print("Still waiting")
                //they finished tutorial and account has still not loaded - something until data is loaded
            }
        }
        transactionsTable.registerClass(AddMoreCell.self, forCellReuseIdentifier: "addMoreCell")
        transactionsTable.tableFooterView = UIView()
        transactionsTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackgroundNotification:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        transactionsTable.contentInset = UIEdgeInsetsZero
        self.automaticallyAdjustsScrollViewInsets = false
        
        rewardView.hidden = true
        transactionsTable.hidden = false
        inboxType = .InboxTransaction
        
        var access_token = ""
        if keyStore.stringForKey("access_token") != nil {
            access_token = keyStore.stringForKey("access_token")!
            keyChainStore.set(access_token, key: "access_token")
        }
        
        if accounts.count == 0 {
            //&& access_token == "" //show add user
            setPredicates(false)
            accountAddView.hidden = false
            addAccountButton.hidden = false
            transactionsTable.hidden = true
            makeOnlyFirstNElementsVisible()
            transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
            charlieAnalytics.track("Find Bank Screen - Main")
        }
        else {
            setPredicates(true)
            makeOnlyFirstNElementsVisible()
            transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
            addAccountButton.hidden = true
            accountAddView.hidden = true
            //refresh accounts
            if allTransactionItems.count > 0 {
                let lastTransaction = allTransactionItems[0].date as NSDate
                let calendar: NSCalendar = NSCalendar.currentCalendar()
                let flags = NSCalendarUnit.Day
                let components = calendar.components(flags, fromDate: lastTransaction, toDate: NSDate(), options: [])
                
                let dateToSychTo = components.day
                
                spinner.startAnimating()
                print("DAYS \(dateToSychTo)")
                cHelp.addUpdateResetAccount(1, dayLength: dateToSychTo) { (response) in
                    self.view.backgroundColor = lightBlue
                    self.transactionsTable.backgroundColor = UIColor.clearColor()
                    self.transactionsTable.reloadData()
                    self.spinner.stopAnimating()
                    if transactionItems.count == 0 && self.inboxType == .InboxTransaction && allTransactionItems.count > 0 {
                        self.showReward()
                    }
                }
            }
        }
        
        self.inboxType = .InboxTransaction //set inbox to default
        
        removeCellBlockLeft = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            if self.inboxType == .InboxTransaction || self.inboxType == .FlaggedTransaction {
                if defaults.stringForKey("firstSwipeRight") == nil {
                    let refreshAlert = UIAlertController(title: "Swipe Right", message: "This transaction will be placed on the worth it tab (the smiley face on the bottom right)", preferredStyle: UIAlertControllerStyle.Alert)
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
                        self.finishSwipe(tableView, cell: cell, direction: 1)
                        defaults.setObject("yes", forKey: "firstSwipeRight")
                        defaults.synchronize()
                    }))
                    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) in
                        tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
                    }))
                    self.presentViewController(refreshAlert, animated: true, completion: nil)
                }
                else {
                    self.finishSwipe(tableView, cell: cell, direction: 1)
                }
            }
            else {
                //swiping not acted on
                tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
            }
        }
        
        removeCellBlockRight = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            if  self.inboxType == .InboxTransaction || self.inboxType == .ApprovedTransaction{
                if defaults.stringForKey("firstSwipeLeft") == nil {
                    let refreshAlert = UIAlertController(title: "Swipe Left", message: "This transaction will be placed on the not worth it tab (the sad face on the bottom left)", preferredStyle: UIAlertControllerStyle.Alert)
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
                        self.finishSwipe(tableView, cell: cell, direction: 2)
                        defaults.setObject("yes", forKey: "firstSwipeLeft")
                        defaults.synchronize()
                    }))
                    
                    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) in
                        tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
                    }))
                    self.presentViewController(refreshAlert, animated: true, completion: nil)
                }
                else {
                    self.finishSwipe(tableView, cell: cell, direction: 2)
                }
            }
            else {
                tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
            }
        }
        
        inboxListButton.layer.borderColor = UIColor.clearColor().CGColor
        inboxListButton.layer.borderWidth = 1.0
        inboxListButton.layer.cornerRadius = inboxListButton.frame.size.width/2.0
        inboxListButton.clipsToBounds = true
        if transactionItems.count > 0 {
            inboxListButton.setTitle(String(transactionItems.count), forState: .Normal)
        }
        else {
            inboxListButton.setTitle("", forState: .Normal)
        }
    }
    
 
    func showReward() {
        let rewardVC = RewardViewController()
        self.addChildViewController(rewardVC)
        rewardVC.view.backgroundColor = lightBlue
        rewardView.addSubview(rewardVC.view)
        rewardVC.view.frame = CGRectMake(0, 0, rewardView.frame.size.width, rewardView.frame.size.height)
        rewardView.hidden = false
    }
    
    
    func setPredicates(hasAccounts:Bool) {
        if hasAccounts {
            if accounts[0].institution_type == "fake_institution" {
                inboxPredicate = NSPredicate(format: "status = 0")
                approvedPredicate = NSPredicate(format: "status = 1")
                flaggedPredicate = NSPredicate(format: "status = 2")
                actedUponPredicate = NSPredicate(format: "status > 0", showTransactionDays)
            }
            else {
                inboxPredicate = NSPredicate(format: "status = 0 AND date > %@", showTransactionDays)
                approvedPredicate = NSPredicate(format: "status = 1 AND date > %@", showTransactionDays)
                flaggedPredicate = NSPredicate(format: "status = 2 AND date > %@", showTransactionDays)
                actedUponPredicate = NSPredicate(format: "status > 0 AND date > %@", showTransactionDays)
            }
        }
        else {
            inboxPredicate = NSPredicate(format: "status = 0 AND date > %@", showTransactionDays)
            approvedPredicate = NSPredicate(format: "status = 1 AND date > %@", showTransactionDays)
            flaggedPredicate = NSPredicate(format: "status = 2 AND date > %@", showTransactionDays)
            actedUponPredicate = NSPredicate(format: "status > 0 AND date > %@", showTransactionDays)
        }
    }
    
    func hideReward() {
        rewardView.hidden = true
    }
    
    
    func updateTrans() -> Void {
        print("looking for records")
        cHelp.addUpdateResetAccount(1, dayLength: 0) { (response) in
            charlieAnalytics.track("Account Transations Initial Sync Completed")
            
            print(response)
            if response > 0 {
                self.timer.invalidate()
                self.setPredicates(true)
                self.makeOnlyFirstNElementsVisible()
                transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
                allTransactionItems = realm.objects(Transaction).sorted("date", ascending: false)
                self.transactionsTable.reloadData()
                if transactionItems.count > 0 { self.inboxListButton.setTitle(String(transactionItems.count), forState: .Normal) }
                else { self.inboxListButton.setTitle("", forState: .Normal) }
                self.spinner.stopAnimating()
                self.toastView.hidden = true
                
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "segueFromMainToDetailView") {
            let viewController = segue.destinationViewController as! showTransactionViewController
            viewController.mainVC = self
            let indexPath = self.transactionsTable.indexPathForSelectedRow
            viewController.transactionID = transactionItems[indexPath!.row]._id
            viewController.sourceVC = "main"
        }
        else if (segue.identifier == "showTypePicker") {
            let viewController = segue.destinationViewController as! showTypePickerViewController
            //let indexPath = self.transactionsTable.indexPathForSelectedRow()
            viewController.transactionID = currentTransactionSwipeID
            viewController.transactionCell = currentTransactionCell
            viewController.mainVC = self
        }
        else if (segue.identifier == "showReveal") {
            let userSelectedHappyScore =  defaults.stringForKey("userSelectedHappyScore")!
            let viewController = segue.destinationViewController as! revealViewController
            viewController.revealPercentage = "\(userSelectedHappyScore)"
        }
        else if (segue.identifier == "groupDetail") {
            let indexPath = self.transactionsTable.indexPathForSelectedRow
            let viewController = segue.destinationViewController as! groupDetailViewController
            
            if inboxType == .FlaggedTransaction {
                viewController.comingFromSad = true
            }
            else if inboxType == .ApprovedTransaction {
                viewController.comingFromSad = false
            }
            
            viewController.transactionName =  charlieGroupListFiltered[indexPath!.row].name
        }
    }
    
    @IBAction func showTutorial(sender: UIButton) {
        //remove icloud
        keyStore.setString("", forKey: "access_token")
        keyStore.setString("", forKey: "email")
        keyStore.setString("", forKey: "password")
        keyStore.synchronize()
    }
    
    @IBAction func refreshAccounts(sender: UIButton) {
        blackView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        blackView!.backgroundColor =  UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        self.view .addSubview(blackView!)
        let sortVC = SortViewController()
        sortVC.initialFilterType = self.filterType
        sortVC.delegate = self
        let height = self.view.frame.size.height*0.8
        sortVC.view.frame = CGRectMake(0, -height, self.view.frame.size.width, height)
        self.addChildViewController(sortVC)
        self.view.addSubview(sortVC.view)
        UIView.animateWithDuration(0.5) { () -> Void in
            sortVC.view.frame = CGRectMake(0, 0, sortVC.view.frame.width, height)
        }
    }
    
     func changeFilter(filterType:SortFilterType){
        self.filterType = filterType
        charlieGroupListFiltered = groupBy(inboxType, sortFilter: self.filterType) as! [(charlieGroup)]
        transactionsTable.reloadData()
        blackView?.removeFromSuperview()
    }
    
    func changeTransactionType(type: TransactionType) {
        charlieGroupListFiltered = groupBy(type, sortFilter: self.filterType) as! [(charlieGroup)]
        transactionsTable.reloadData()
        blackView?.removeFromSuperview()
    }
    
    // TODO: Clear approved
    @IBAction func approvedListButtonress(sender: UIButton) {
        charlieAnalytics.track("Worth It Button")
        transactionsTable.backgroundColor = UIColor.clearColor();
        self.view.backgroundColor = lightGreen
        hideReward()
        
        transactionItems = realm.objects(Transaction).filter(approvedPredicate).sorted("name", ascending: true)
        
        self.inboxType = .ApprovedTransaction
        dividerView.backgroundColor = listGreen
        
        topSeperator.backgroundColor = listGreen
        moneyCountSubSubHeadLabel.text = "Worth"
        moneyCountSubSubHeadLabel.textColor = listGreen
        
        inboxType = .ApprovedTransaction
        charlieGroupListFiltered = groupBy(inboxType, sortFilter: filterType) as! [(charlieGroup)]
        transactionsTable.reloadData()
    }
    
    func makeOnlyFirstNElementsVisible() {
        areThereMoreItemsToLoad = false
        realm.beginWrite()
        for i in 0..<allTransactionItems.count {
            if i > numItemsToLoad + 2  && i < allTransactionItems.count {
                let trans = allTransactionItems[i]
                trans.status = -1
                areThereMoreItemsToLoad = true
            }
            else if i < allTransactionItems.count {
                let trans = allTransactionItems[i]
                if (trans.status == -1) {
                    trans.status = 0
                }
            }
        }
        try! realm.commitWrite()
    }
    
    @IBAction func inboxListButtonPress(sender: UIButton) {
        charlieAnalytics.track("Inbox Button")
        self.view.backgroundColor = lightBlue
        transactionsTable.backgroundColor = UIColor.clearColor()
        transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
        
        if transactionItems.count == 0 && allTransactionItems.count > 0 {
            showReward()
        }
        else {
            if accounts.count  == 1 && allTransactionItems.count == 1 {
                addAccountButton.hidden = false
                accountAddView.hidden = false
                transactionsTable.hidden = true
                charlieAnalytics.track("Find Bank Screen - Main")
            }
        }
        
        
        inboxType = .InboxTransaction
        dividerView.backgroundColor = listBlue
        if transactionItems.count > 0 {
            inboxListButton.setTitle(String(transactionItems.count), forState: .Normal)
        }
        else {
            inboxListButton.setTitle("", forState: .Normal)
        }
        
        moneyCountSubSubHeadLabel.text = "Worth it?"
        moneyCountSubSubHeadLabel.textColor = listBlue

        topSeperator.backgroundColor = listBlue

        inboxType == .InboxTransaction
        transactionsTable.reloadData()
    }
    
    
    @IBAction func flagListButtonPress(sender: UIButton) {
        charlieAnalytics.track("Not Worth It Button")
        self.view.backgroundColor = lightRed
        transactionsTable.backgroundColor = UIColor.clearColor();
        hideReward()
        
        transactionItems = realm.objects(Transaction).filter(flaggedPredicate).sorted("date", ascending: false)
        
        inboxType = .FlaggedTransaction
        dividerView.backgroundColor = listRed
        moneyCountSubSubHeadLabel.text = "Not Worth it!"
        moneyCountSubSubHeadLabel.textColor = listRed
        
        topSeperator.backgroundColor = listRed
        
        inboxType = .FlaggedTransaction
        charlieGroupListFiltered = groupBy(inboxType, sortFilter: filterType) as! [(charlieGroup)]
        transactionsTable.reloadData()
    }
    
    
    func groupBy(type: TransactionType, sortFilter: SortFilterType) -> NSArray {
        charlieGroupList = []
        var current_name = ""
        let sortProperties : Array<SortDescriptor>!
        if sortFilter == .FilterByName {
            sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: true)]
        }
        else if sortFilter == .FilterByDescendingDate {
            sortProperties = [SortDescriptor(property: "date", ascending: false)]
        }
        else if sortFilter == .FilterByDate {
            sortProperties = [SortDescriptor(property: "date", ascending: true)]
        }
        else {
            sortProperties = [SortDescriptor(property: "amount", ascending: false)]
        }
        
        let actedUponItems = realm.objects(Transaction).filter(actedUponPredicate).sorted(sortProperties)
        var current_index = 0
        for trans in actedUponItems {
            if trans.name == current_name {
                if trans.status == 1 {
                    charlieGroupList[current_index].worthCount = charlieGroupList[current_index].worthCount + 1
                    charlieGroupList[current_index].worthValue = charlieGroupList[current_index].worthValue + trans.amount
                }
                else if trans.status == 2 {
                    charlieGroupList[current_index].notWorthCount =   charlieGroupList[current_index].notWorthCount + 1
                    charlieGroupList[current_index].notWorthValue = charlieGroupList[current_index].notWorthValue + trans.amount
                }
            }
            else {
                print("create new \(trans.name)")
                let cGroup = charlieGroup(name: trans.name)
                if trans.status == 1 {
                    cGroup.worthCount = 1
                    cGroup.worthValue = trans.amount
                }
                else if trans.status == 2 {
                    cGroup.notWorthCount = 1
                    cGroup.notWorthValue = trans.amount
                }
                charlieGroupList.append((cGroup))
                current_index = charlieGroupList.count - 1
            }
            current_name = trans.name
        }
        
        if type == .FlaggedTransaction {
            return charlieGroupList.filter({$0.notWorthValue > 0})
        }
        else if type == .ApprovedTransaction {
            return charlieGroupList.filter({$0.worthValue > 0})
        }
        else if type == .ApprovedAndFlaggedTransaction {
            return charlieGroupList.filter( { (trans) in trans.worthValue > 0 || trans.notWorthValue > 0 } )
        }
        else {
            return charlieGroupList.filter({$0.worthValue > 0})
        }
    }
}

// Swipe part of the main view controller
extension mainViewController : UITableViewDataSource {
    func finishSwipe(tableView: SBGestureTableView, cell: SBGestureTableViewCell, direction: Int) {
        let indexPath = tableView.indexPathForCell(cell)
        currentTransactionSwipeID = transactionItems[indexPath!.row]._id
        currentTransactionCell = cell
        
        realm.beginWrite()
        transactionItems[indexPath!.row].status = direction
        tableView.removeCell(cell, duration: 0.3, completion: nil)
        try! realm.commitWrite()
        if transactionItems.count > 0 {
            inboxListButton.setTitle(String(transactionItems.count), forState: .Normal)
        }
        else {
            inboxListButton.setTitle("", forState: .Normal)
        }

        let rowCount = Int(tableView.numberOfRowsInSection(0).value)
        
        if direction == 1 {
            charlieAnalytics.track("Worth It Swipe")
            if rowCount == 1 + Int(areThereMoreItemsToLoad) && self.inboxType == .InboxTransaction {
                print("show reward window")
                self.showReward()
            }
        }
        else {
            charlieAnalytics.track("Not Worth It Swipe")
            if rowCount == 1 + Int(areThereMoreItemsToLoad) && self.inboxType == .InboxTransaction {
                print("show reward window")
                self.showReward()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inboxType == .FlaggedTransaction || inboxType == .ApprovedTransaction {
            return charlieGroupListFiltered.count
        }
        else {
            if transactionItems.count > 0 {
                transactionsTable.hidden = false
                addAccountButton.hidden = true
                accountAddView.hidden = true
            }
            return transactionItems.count + Int(areThereMoreItemsToLoad)
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if inboxType == .FlaggedTransaction || inboxType == .ApprovedTransaction {
            performSegueWithIdentifier("groupDetail", sender: indexPath)
        }
        else {
            if indexPath.row < transactionItems.count {
                performSegueWithIdentifier("segueFromMainToDetailView", sender: self)
            }
            else {
                numItemsToLoad += 10
                makeOnlyFirstNElementsVisible()
                transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
                inboxListButton.setTitle(String(transactionItems.count), forState: .Normal)
                transactionsTable.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if inboxType == .InboxTransaction && indexPath.row == transactionItems.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("addMoreCell", forIndexPath: indexPath)  as! AddMoreCell
            return cell
        }

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SBGestureTableViewCell
        
        if inboxType == .FlaggedTransaction {
            cell.nameCellLabel.text = charlieGroupListFiltered[indexPath.row].name
            cell.amountCellLabel.text = cHelp.formatCurrency(charlieGroupListFiltered[indexPath.row].notWorthValue)
            cell.amountCellLabel.textColor = listRed
            if charlieGroupListFiltered[indexPath.row].notWorthCount == 1 {
                 cell.dateCellLabel.text = "1 transaction"
            }
            else {
                cell.dateCellLabel.text = "\(charlieGroupListFiltered[indexPath.row].notWorthCount) transactions"
            }
            
            cell.firstLeftAction = nil
            cell.firstRightAction = nil
        }
        else if inboxType == .ApprovedTransaction {
            cell.nameCellLabel.text = charlieGroupListFiltered[indexPath.row].name
            cell.amountCellLabel.text = cHelp.formatCurrency(charlieGroupListFiltered[indexPath.row].worthValue)
            cell.amountCellLabel.textColor = listGreen
            if charlieGroupListFiltered[indexPath.row].worthCount == 1 {
                cell.dateCellLabel.text = "1 transaction"
            }
            else {
                cell.dateCellLabel.text = "\(charlieGroupListFiltered[indexPath.row].worthValue) transactions"
            }
            cell.firstLeftAction = nil
            cell.firstRightAction = nil
        }
        else {
            cell.firstLeftAction = SBGestureTableViewCellAction(icon: checkImage!, color: listGreen, fraction: 0.35, didTriggerBlock: removeCellBlockLeft)
            cell.firstRightAction = SBGestureTableViewCellAction(icon: flagImage!, color: listRed, fraction: 0.35, didTriggerBlock: removeCellBlockRight)
            cell.nameCellLabel.text = transactionItems[indexPath.row].name
            cell.amountCellLabel.text = cHelp.formatCurrency(transactionItems[indexPath.row].amount)
            cell.amountCellLabel.textColor = listBlue
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EE, MMMM dd " //format style. Browse online to get a format that fits your needs.
            let dateString = dateFormatter.stringFromDate(transactionItems[indexPath.row].date)
            cell.dateCellLabel.text = dateString
        }
        
        return cell
    }
}


class AddMoreCell : UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 70)
        let centralSetup = UILabel(frame: CGRectMake(0, 0, 100, 30))
        centralSetup.textAlignment = .Center
        centralSetup.center = self.contentView.center
        centralSetup.text = "Add More"
        self.contentView.addSubview(centralSetup)
    }
}

extension mainViewController : UIViewControllerPreviewingDelegate {
    
    /// Called when the user has pressed a source view in a previewing view controller (Peek).
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        // Get indexPath for location (CGPoint) + cell (for sourceRect)
        guard let indexPath = transactionsTable.indexPathForRowAtPoint(location) else { return nil }
        
        guard let showTransactionViewController = storyboard?.instantiateViewControllerWithIdentifier("showTransactionViewController") as? showTransactionViewController else { return nil }
        
        showTransactionViewController.transactionID = transactionItems[indexPath.row]._id
        showTransactionViewController.sourceVC = "main"

        
        return showTransactionViewController
    }
    
    /// Called to let you prepare the presentation of a commit (Pop).
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        // Presents viewControllerToCommit in a primary context
        showViewController(viewControllerToCommit, sender: self)
    }
}