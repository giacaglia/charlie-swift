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
var waitingToProcessPredicate = NSPredicate() // items set to -1 and could be processed if users chooses to load more
var groupedPredicate = NSPredicate()
var charlieGroupList = [charlieGroup]()
var charlieGroupListFiltered = [charlieGroup]()
var keyStore = NSUbiquitousKeyValueStore()
var keyChainStore = KeychainHelper()
var transactionItems = realm.objects(Transaction)
var allTransactionItems = realm.objects(Transaction).sorted("date", ascending: false)
var selectedCollectioncCellIndex  = 0

enum TransactionType {
    case ApprovedAndFlaggedTransaction, InboxTransaction
}

enum SortFilterType {
    case FilterByName, FilterByDate, FilterByDescendingDate, FilterByAmount, FilterByMostWorth, FilterByLeastWorth
}

enum ReportCardType : Int {
    case HappyFlowType, CashFlowType, LocationType
}

protocol ChangeFilterProtocol {
    func removeBlackView()
    func changeFilter( filterType: SortFilterType )
    func changeTransactionType( type : TransactionType)
}

protocol MainViewControllerDelegate {
    func hideCardsAndShowTransactions()
      func showCards()
}

class mainViewController: UIViewController, ChangeFilterProtocol, MainViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var transactionsTable: SBGestureTableView!
    @IBOutlet weak var accountAddView: UIView!
    @IBOutlet weak var addAccountButton: UIButton!
    
    var cHelp = cHelper()
    var currentTransactionSwipeID = ""
    var currentTransactionCell:SBGestureTableViewCell!
    
    var totalCashFlow:Double = 0
    var changeCashFlow:Double = 0
    var totalSpending:Double = 0
    var changeSpending:Double = 0
    var totalIncome:Double = 0
    var changeIncome:Double = 0
    
    var moreItems = realm.objects(Transaction)
    
    var currentMonthHappyPercentage: Double = 0
    var happyFlowChange: Double = 0
    
    var removeCellBlockLeft: ((SBGestureTableView, SBGestureTableViewCell) -> Void)!
    var removeCellBlockRight: ((SBGestureTableView, SBGestureTableViewCell) -> Void)!
    let accounts = realm.objects(Account)
    var timer = NSTimer()
    var timerCount:Int = 0
    var filterType : SortFilterType! = .FilterByName
    var inboxType : TransactionType! = .ApprovedAndFlaggedTransaction
    static let blackView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
    var areThereMoreItemsToLoad = false
    var numItemsToLoad = 20
    let inboxLabel = UILabel(frame: CGRectMake(0, 0, 40, 40))
    
    var monthDiff:Int = 0

    
    func willEnterForeground(notification: NSNotification!) {
        if let resultController = storyboard!.instantiateViewControllerWithIdentifier("passcodeViewController") as? passcodeViewController {
            presentViewController(resultController, animated: false, completion: { () -> Void in
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
       
       // transactionsTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //get month range for transactions
        let atCount =  allTransactionItems.count
        if atCount > 0 {
            let lastTrans = allTransactionItems[0].date as NSDate
            let firstTrans = allTransactionItems[atCount - 1].date  as NSDate
            monthDiff = lastTrans.monthsFrom(firstTrans)
        }
        
        //get data for report cards
        (totalCashFlow, changeCashFlow, totalSpending, changeSpending, totalIncome, changeIncome) = cHelp.getCashFlow(NSDate(), isCurrentMonth: true)
        (currentMonthHappyPercentage, happyFlowChange) =  cHelp.getHappyPercentageCompare(NSDate(), isCurrentMonth: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackgroundNotification:", name: UIApplicationDidEnterBackgroundNotification, object: nil)

        var image = UIImage(named: "menu")
        
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image!, style: UIBarButtonItemStyle.Plain, target: self, action: "showAccounts")

        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : lightBlue]
        self.title = "Worth It?"
       
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
      
        
        let attributes = [
            NSForegroundColorAttributeName: lightBlue,
            NSFontAttributeName: UIFont(name: "Montserrat-Bold", size: 24)!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        self.loadTransactionTable()
    }
    
    
    func formatCurrency(currency: Double) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let numberFromField = currency
        return formatter.stringFromNumber(numberFromField)!
    }

    
    
    func showAccounts() {
        self.performSegueWithIdentifier("showAccountsCards", sender: nil)
    }
   
    
    func loadTransactionTable() {
        transactionsTable.contentInset = UIEdgeInsetsZero
        self.automaticallyAdjustsScrollViewInsets = false
        
        // rewardView.hidden = true
        transactionsTable.hidden = false
        inboxType = .InboxTransaction
        
        var access_token = ""
        if keyStore.stringForKey("access_token") != nil {
            access_token = keyStore.stringForKey("access_token")!
            keyChainStore.set(access_token, key: "access_token")
        }
        
        if accounts.count == 0 {
            setPredicates(false, startMonth: NSDate())
            accountAddView.hidden = false
            addAccountButton.hidden = false
            transactionsTable.hidden = true
            //makeOnlyFirstNElementsVisible()
            transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
            charlieAnalytics.track("Find Bank Screen - Main")
        }
        else {
            setPredicates(true, startMonth: NSDate())
            transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
            areThereMoreItemsToLoad = moreTransactionforLoading()
            
            
            //            if transactionItems.count == 0
            //            {
            //                areThereMoreItemsToLoad = true
            //                // print ("OUT OF TRANSACTIONS")
            //                //makeOnlyFirstNElementsVisible()
            //
            //            }
            addAccountButton.hidden = true
            accountAddView.hidden = true
            //refresh accounts
            if allTransactionItems.count > 0 {
                let transCount = allTransactionItems.count
                let firstTransaction = allTransactionItems[transCount - 1].date as NSDate
                
                
                let lastTransaction = allTransactionItems[0].date as NSDate
                let calendar: NSCalendar = NSCalendar.currentCalendar()
                let flags = NSCalendarUnit.Day
                let components = calendar.components(flags, fromDate: lastTransaction, toDate: NSDate(), options: [])
                
                let transDateRangeComp = calendar.components(flags, fromDate: firstTransaction, toDate: lastTransaction, options: [])
                
                
                var dateToSychTo = components.day
                
                let transDateRange = transDateRangeComp.day
                
                if transDateRange <  31
                {
                    dateToSychTo = 0 // we may still have some old transactions so do a full sync
                }
                
                spinner.startAnimating()
                print("DAYS \(dateToSychTo)")
                cHelp.addUpdateResetAccount(1, dayLength: dateToSychTo) { (response) in
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
            if self.inboxType == .InboxTransaction {
                if defaults.stringForKey("firstSwipeRight") == nil {
                    let refreshAlert = UIAlertController(title: "Swipe Right", message: "To see your transactions that were worth it, select the tab on the bottom right.)", preferredStyle: UIAlertControllerStyle.Alert)
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
            if  self.inboxType == .InboxTransaction {
                if defaults.stringForKey("firstSwipeLeft") == nil {
                    let refreshAlert = UIAlertController(title: "Swipe Left", message: "To see your transactions that were not worth it, select the tab on the bottom right.", preferredStyle: UIAlertControllerStyle.Alert)
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
        
        transactionsTable.backgroundColor = UIColor.clearColor()
        transactionsTable.registerClass(AddMoreCell.self, forCellReuseIdentifier: AddMoreCell.cellIdentifier())
        transactionsTable.registerClass(ReportCardCell.self, forCellReuseIdentifier:ReportCardCell.cellIdentifier())
        transactionsTable.tableFooterView = UIView()
    }
    
    func showReward() {
//        rewardView.subviews.forEach({ $0.removeFromSuperview() })
//        let rewardVC = RewardViewController()
//        self.addChildViewController(rewardVC)
//        rewardVC.view.backgroundColor = lightBlue
//        rewardView.addSubview(rewardVC.view)
//        rewardVC.view.frame = CGRectMake(0, 0, rewardView.frame.size.width, rewardView.frame.size.height)
//        rewardView.hidden = false
    }
    
    func showCards() {
//        //dateRangeLabel.hidden = false
//        rewardView.subviews.forEach({ $0.removeFromSuperview() })
//        let cardsVC = CardsViewController()
//        self.addChildViewController(cardsVC)
//        cardsVC.mainVC = self
//        rewardView.addSubview(cardsVC.view)
//        cardsVC.view.frame = CGRectMake(0, 0, rewardView.frame.size.width, rewardView.frame.size.height)
//        rewardView.hidden = false
    }
    
    func moreTransactionforLoading() -> Bool {
         moreItems = realm.objects(Transaction).filter(waitingToProcessPredicate)
        if moreItems.count > 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func setPredicates(hasAccounts:Bool, startMonth: NSDate) {
        let startDate = startMonth.startOfMonth()!
        let endDate = startMonth.endOfMonth()!
        
        
        
        inboxPredicate = NSPredicate(format: "(date >= %@ and date <= %@) and status = 0", startDate, endDate)
        approvedPredicate = NSPredicate(format: "status = 1")
        actedUponPredicate = NSPredicate(format: "status = 1 OR status = 2")
        waitingToProcessPredicate = NSPredicate(format: "(date >= %@ and date <= %@) and status = -1", startDate, endDate)

    }
    
    func hideReward() {
     //   rewardView.hidden = true
        //dateRangeLabel.hidden = true
    }   
    
    func hideCardsAndShowTransactions() {
//        self.
//        hideReward()
//        transactionsTable.hidden = false
//        showPastTransactions()
        self.presentViewController(SwipedTransactionsViewController(), animated: true) { () -> Void in}
    }
    
    func updateTrans() -> Void {
        print("looking for records")
        cHelp.addUpdateResetAccount(1, dayLength: 0) { (response) in
            charlieAnalytics.track("Account Transations Initial Sync Completed")
            
            print(response)
            if response > 0 {
                self.timer.invalidate()
                self.setPredicates(true, startMonth: NSDate())
                self.makeOnlyFirstNElementsVisible()
                transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
                allTransactionItems = realm.objects(Transaction).sorted("date", ascending: false)
                self.transactionsTable.reloadData()
            //    self.setInboxTitle(true)
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
            viewController.transaction = transactionItems[indexPath!.row]
            viewController.transactionIndex = indexPath!.row
            viewController.sourceVC = "main"
        }
        else if (segue.identifier == "showTypePicker") {
            let viewController = segue.destinationViewController as! showTypePickerViewController
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
        mainViewController.blackView.backgroundColor =  UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        self.view .addSubview(mainViewController.blackView)
        let sortVC = SortViewController()
        sortVC.initialFilterType = self.filterType
        sortVC.transactionType = self.inboxType
        sortVC.delegate = self
        let height = self.view.frame.size.height*0.8
        sortVC.view.frame = CGRectMake(0, -height, self.view.frame.size.width, height)
        self.addChildViewController(sortVC)
        self.view.addSubview(sortVC.view)
        UIView.animateWithDuration(0.5) { () -> Void in
            sortVC.view.frame = CGRectMake(0, 0, sortVC.view.frame.width, height)
        }
    }
    
    func removeBlackView() {
        mainViewController.blackView.removeFromSuperview()
    }
    
    func changeFilter(filterType:SortFilterType){
        self.filterType = filterType
        charlieGroupListFiltered = groupBy(inboxType, sortFilter: self.filterType) as! [(charlieGroup)]
        transactionsTable.reloadData()
        mainViewController.blackView.removeFromSuperview()
    }
    
    func changeTransactionType(type: TransactionType) {
        inboxType = type
        charlieGroupListFiltered = groupBy(type, sortFilter: self.filterType) as! [(charlieGroup)]
        transactionsTable.reloadData()
        mainViewController.blackView.removeFromSuperview()
    }

    
    func makeOnlyFirstNElementsVisible() {
        areThereMoreItemsToLoad = false
        var loadCount = 0
        let moreItems = realm.objects(Transaction).filter(waitingToProcessPredicate)
        
        realm.beginWrite()

        for item in moreItems
         {
           if loadCount < numItemsToLoad {
                let trans = item
                trans.status = 0
                loadCount += 1
            }
        }
        
        try! realm.commitWrite()
        
        if loadCount > 0
        {
            areThereMoreItemsToLoad =  true
        }
        
    }
    
   
    
    func showPastTransactions() {
        transactionItems = realm.objects(Transaction).filter(flaggedPredicate).sorted("date", ascending: false)
        //titleLabel.text = "My Results"
        inboxType = .ApprovedAndFlaggedTransaction
        charlieGroupListFiltered = groupBy(inboxType, sortFilter: filterType) as! [(charlieGroup)]
        transactionsTable.reloadData()
    }
    
    func groupBy(type: TransactionType, sortFilter: SortFilterType) -> NSArray {
        charlieGroupList = []
        var current_name = ""
        let sortProperties : Array<SortDescriptor>!
     
        sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: true)]
        
        let actedUponItems = realm.objects(Transaction).filter(actedUponPredicate).sorted(sortProperties)
        var current_index = 0
        
        for trans in actedUponItems {
            print(trans.name)
            if trans.name == current_name {
                // Approved items
                if trans.status == 1 {
                    charlieGroupList[current_index].worthCount = charlieGroupList[current_index].worthCount + 1
                    charlieGroupList[current_index].worthValue = charlieGroupList[current_index].worthValue + trans.amount
                }
                // Flagged items
                else if trans.status == 2 {
                    charlieGroupList[current_index].notWorthCount = charlieGroupList[current_index].notWorthCount + 1
                    charlieGroupList[current_index].notWorthValue = charlieGroupList[current_index].notWorthValue + trans.amount
                }
                
               charlieGroupList[current_index].happyPercentage = Int((Double(charlieGroupList[current_index].worthCount) / Double((charlieGroupList[current_index].transactions)) * 100))
               
                charlieGroupList[current_index].totalAmount +=  trans.amount
                
            }
            else {
               
                
                print("create new group: \(trans.name)")
                let cGroup = charlieGroup(name: trans.name, lastDate: String(trans.date))
                if trans.status == 1 {
                    cGroup.worthCount += 1
                    cGroup.worthValue += trans.amount
                    charlieGroupList.append((cGroup))
                    current_index = charlieGroupList.count - 1
                }
                else if trans.status == 2 {
                    cGroup.notWorthCount += 1
                    cGroup.notWorthValue += trans.amount
                    charlieGroupList.append((cGroup))
                    current_index = charlieGroupList.count - 1
                }
                else {
                    // not added to the list
                }
                if cGroup.transactions == 0 {
                    cGroup.happyPercentage = 0
                }
                else {
                    cGroup.happyPercentage = Int((Double(cGroup.worthCount) / Double((cGroup.transactions)) * 100))
                    cGroup.totalAmount = cGroup.totalAmount + trans.amount
                }
                
            }
            current_name = trans.name
            
        }
 
        return charlieGroupList
    }
}

extension mainViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthDiff
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("filterCell", forIndexPath: indexPath) as! FilterCell
            let date = NSDate().dateByAddingMonths(-indexPath.row)
            cell.monthLabel.text = date!.monthString()
        
            if selectedCollectioncCellIndex == indexPath.row
            {
                //cell.backgroundColor = lightBlue
                cell.monthLabel.font = UIFont(name: "Montserrat-Bold", size: 18)!
                
            }
            else
            {
                cell.monthLabel.font = UIFont(name: "Montserrat-Light", size: 18)!
                //cell.backgroundColor = lightGray
            }
        
            return cell
        }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        selectedCollectioncCellIndex = indexPath.row
        
        
       
        
        let startMonth = NSDate().dateByAddingMonths(-selectedCollectioncCellIndex)!
        setPredicates(true, startMonth: startMonth)
        transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
       moreItems = realm.objects(Transaction).filter(waitingToProcessPredicate)
        if selectedCollectioncCellIndex == 0 
       {
        
        (totalCashFlow, changeCashFlow, totalSpending, changeSpending, totalIncome, changeIncome) = cHelp.getCashFlow(startMonth, isCurrentMonth: true)
        (currentMonthHappyPercentage, happyFlowChange) =  cHelp.getHappyPercentageCompare(startMonth, isCurrentMonth: false)
        
        }
        else
        {
        (totalCashFlow, changeCashFlow, totalSpending, changeSpending, totalIncome, changeIncome) = cHelp.getCashFlow(startMonth, isCurrentMonth: false)
        (currentMonthHappyPercentage, happyFlowChange) =  cHelp.getHappyPercentageCompare(startMonth, isCurrentMonth: false)
        }
        
        
        
        dispatch_async(dispatch_get_main_queue()) {
            //collectionView.reloadItemsAtIndexPaths([indexPath])
            collectionView.reloadData()
            self.transactionsTable.reloadData()
          
            
        }
        
        
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(100, 50)
    }
    
}

// Swipe part of the main view controller
extension mainViewController : UITableViewDataSource, UITableViewDelegate {
    func finishSwipe(tableView: SBGestureTableView, cell: SBGestureTableViewCell, direction: Int) {
        let indexPath = tableView.indexPathForCell(cell)
        self.updateTableAt(indexPath: indexPath!, direction: direction)
    }
    
    private func updateTableAt(indexPath indexPath: NSIndexPath, direction: Int) {
        currentTransactionSwipeID = transactionItems[indexPath.row]._id
        let cell = transactionsTable.cellForRowAtIndexPath(indexPath) as? SBGestureTableViewCell
        currentTransactionCell = cell
        
        realm.beginWrite()
        transactionItems[indexPath.row].status = direction
        transactionsTable.removeCell(cell!, duration: 0.3, completion: nil)
        try! realm.commitWrite()
      //  self.setInboxTitle(true)
        let rowCount = Int(transactionsTable.numberOfRowsInSection(0).value)
        
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
        if transactionItems.count > 0 {
            transactionsTable.hidden = false
            addAccountButton.hidden = true
            accountAddView.hidden = true
        }
        return transactionItems.count + 5//Int(areThereMoreItemsToLoad)
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var startDate:NSDate = NSDate()
        var endDate:NSDate = NSDate()
        //change
        if indexPath.row < transactionItems.count {
            performSegueWithIdentifier("segueFromMainToDetailView", sender: self)
        }
        else if indexPath.row == transactionItems.count {
            if indexPath.row == transactionItems.count {
                numItemsToLoad = 20
                
                //get current selected filter date
                let predicateDate = NSDate().dateByAddingMonths(-selectedCollectioncCellIndex)
                
                setPredicates(true, startMonth: predicateDate!)
                makeOnlyFirstNElementsVisible()
                transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
             //   self.setInboxTitle(true)
                transactionsTable.reloadData()
            }
        }
        else if indexPath.row == transactionItems.count + 1 {
            print("Show Happy")
            //self.presentViewController(SwipedTransactionsViewController(), animated: true) { () -> Void in}
            
            let RVC = RewardViewController()
            RVC.view.backgroundColor = lightBlue
            self.navigationController?.pushViewController(RVC, animated: true)
        }
       
        else if indexPath.row == transactionItems.count + 2 {
            print("Show Income")
            
            if selectedCollectioncCellIndex == 0
            {
                startDate = NSDate().startOfMonth()!
                endDate = NSDate()
            }
            else
            {
                startDate = NSDate().dateByAddingMonths(-selectedCollectioncCellIndex)!.startOfMonth()!
                endDate = startDate.endOfMonth()!
            }
            
            let ITC = incomeTransactionsViewController()
            ITC.startDate = startDate
            ITC.endDate = endDate
            
            self.navigationController?.pushViewController(ITC, animated: true)
            
            
        }
            
        else if indexPath.row == transactionItems.count + 3 {
            print("SHOW SPENDING")
            
            if selectedCollectioncCellIndex == 0
            {
            startDate = NSDate().startOfMonth()!
            endDate = NSDate()
            }
            else
            {
            startDate = NSDate().dateByAddingMonths(-selectedCollectioncCellIndex)!.startOfMonth()!
            endDate = startDate.endOfMonth()!
            }
        
            let SVC = SwipedTransactionsViewController()
            SVC.startDate = startDate
            SVC.endDate = endDate

            self.navigationController?.pushViewController(SVC, animated: true)
        }
        else
        {
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row >= transactionItems.count {
            let rewardIndex =  indexPath.row - transactionItems.count
            var  rewardNames = ["Show More Transactions To Complete ", "Happy Flow", "My Income", "My Spending", "My CashFlow"]
            var cellHappy:happyTableViewCell
            var cellReward:rewardTableViewCell
            
            if rewardIndex == 0
            {
                cellHappy = tableView.dequeueReusableCellWithIdentifier("cellHappy", forIndexPath: indexPath) as! happyTableViewCell
                
                if self.moreItems.count > 20
                {
                    cellHappy.rewardName.text = "Show 20 more of \(self.moreItems.count) transactions to complete for your\nHappy Flow"
                }

                else if self.moreItems.count > 0 && self.moreItems.count < 20
                {
                    cellHappy.rewardName.text = "Show \(self.moreItems.count) more transaction to complete for your\n Happy Flow"
                }
                else
                {
                    cellHappy.rewardName.text = "All transactions completed for your\nHappy Flow"
                }
                
               
                
                return cellHappy
            }
            else
            {
                cellReward = tableView.dequeueReusableCellWithIdentifier("cellReward", forIndexPath: indexPath) as! rewardTableViewCell
                cellReward.rewardName.text = rewardNames[rewardIndex]

                
                
                if rewardIndex == 1
                {
                    if (currentMonthHappyPercentage.isNaN || currentMonthHappyPercentage.isInfinite)
                    {
                        cellReward.currentAmount.text = "n/a"
                    }
                    else
                    {
                        cellReward.currentAmount.text = "\(Int(currentMonthHappyPercentage))%"
                    }
                    
                    
                    if (happyFlowChange.isNaN || happyFlowChange.isInfinite)
                    {
                     cellReward.prevAmount.text = "n/a"
                    }
                    else
                    {
                        cellReward.prevAmount.text = "\(Int(happyFlowChange))% from prev month"
                    }
                    
                    
                   
                    //set background
                    let imageView = UIImageView(frame: CGRectMake(10, 10, cellReward.frame.width - 20, cellReward.frame.height - 20))
                    var image:UIImage!
                    if happyFlowChange >= 0
                    {
                        
                        image = UIImage(named: "positiveIncome")
                        imageView.backgroundColor   = lightGreen
                        
                    }
                    else
                    {
                        image = UIImage(named: "negativeSpending")
                        imageView.backgroundColor   = lightRed
                        
                    }
                    
                    imageView.image = image
                    cellReward.backgroundView = UIView()
                    cellReward.backgroundView!.addSubview(imageView)
                    
                    
                    
                    
                    
                }
            
            
                if rewardIndex == 2
                {
                    cellReward.currentAmount.text = "\(formatCurrency(totalIncome))"
                    if (changeIncome.isNaN || changeIncome.isInfinite)
                    {
                        cellReward.prevAmount.text = "n/a"
                    }
                    else
                    {
                        cellReward.prevAmount.text = "\(Int(changeIncome))% from prev month"
                    }
                    
                    
                    //set background
                    let imageView = UIImageView(frame: CGRectMake(10, 10, cellReward.frame.width - 20, cellReward.frame.height - 20))
                    var image:UIImage!
                    if changeIncome >= 0
                    {
                        
                        image = UIImage(named: "positiveIncome")
                        imageView.backgroundColor   = lightGreen
                        
                    }
                    else
                    {
                        image = UIImage(named: "negativeSpending")
                        imageView.backgroundColor   = lightRed
                        
                    }
                    
                    imageView.image = image
                    cellReward.backgroundView = UIView()
                    cellReward.backgroundView!.addSubview(imageView)
                    
                    
                    
                    
                }
                
                if rewardIndex == 3
                {
                    cellReward.currentAmount.text = "\(formatCurrency(totalSpending))"
                    if (changeSpending.isNaN || changeSpending.isInfinite)
                    {
                        cellReward.prevAmount.text = "n/a"
                    }
                    else
                    {
                        cellReward.prevAmount.text = "\(Int(changeSpending))% from prev month"
                    }
                    
                    
                    //set background
                    let imageView = UIImageView(frame: CGRectMake(10, 10, cellReward.frame.width - 20, cellReward.frame.height - 20))
                    var image:UIImage!
                    if changeSpending <= 0
                    {
                        
                        image = UIImage(named: "positiveIncome")
                        imageView.backgroundColor   = lightGreen
                        
                    }
                    else
                    {
                        image = UIImage(named: "negativeSpending")
                        imageView.backgroundColor   = lightRed
                        
                    }
                    
                    imageView.image = image
                    cellReward.backgroundView = UIView()
                    cellReward.backgroundView!.addSubview(imageView)
                    
                    
                    
                }
                
                if rewardIndex == 4
                {
                    cellReward.currentAmount.text = "\(formatCurrency(totalCashFlow))"
                    if (changeCashFlow.isNaN || changeCashFlow.isInfinite)
                    {
                         cellReward.prevAmount.text = "n/a"
                    }
                    else
                    {
                        cellReward.prevAmount.text = "\(Int(changeCashFlow))% from prev month"
                    }
                    
                    //set background
                    let imageView = UIImageView(frame: CGRectMake(10, 10, cellReward.frame.width - 20, cellReward.frame.height - 20))
                    var image:UIImage!
                    if changeCashFlow >= 0
                    {
                        
                        image = UIImage(named: "positiveIncome")
                        imageView.backgroundColor   = lightGreen
                        
                    }
                    else
                    {
                    
                         image = UIImage(named: "negativeSpending")
                         imageView.backgroundColor   = lightRed
                    
                        
                       
                        
                    }
                   
                    
                    imageView.image = image
                
                    cellReward.backgroundView = UIView()
                    cellReward.backgroundView!.addSubview(imageView)
                    
                    
                    
                }
                cellReward.selectionStyle = UITableViewCellSelectionStyle.None
                return cellReward
           }
        }
    
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SBGestureTableViewCell
        let trans = transactionItems[indexPath.row]
        cell.nameCellLabel.text = trans.name

        cell.firstLeftAction = SBGestureTableViewCellAction(icon: UIImage(named: "happyFaceLeft")!, color: listGreen, fraction: 0.35, didTriggerBlock: removeCellBlockLeft)
        cell.firstRightAction = SBGestureTableViewCellAction(icon: UIImage(named: "sadFaceRight")!, color: listRed, fraction: 0.35, didTriggerBlock: removeCellBlockRight)
        
        cell.amountCellLabel.text = cHelp.formatCurrency(trans.amount)
        cell.amountCellLabel.textColor = listBlue
        cell.amountCellLabel.font = UIFont.systemFontOfSize(18.0)

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EE, MMM dd " //format style. Browse online to get a format that fits your needs.
        let dateString = dateFormatter.stringFromDate(trans.date)
        cell.dateCellLabel.text = dateString.uppercaseString
        cell.smallAmountCellLabel.hidden = true
        
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rewardIndex =  indexPath.row - transactionItems.count
        if rewardIndex > 0 {
            return 150
        }
        else {
            return 94
        }
    }
    
    
    func swipeCellAtIndex(transactionIndex: Int, toLeft: Bool) {
        let indexPath = NSIndexPath(forRow: transactionIndex, inSection: 0)
        if toLeft {
            self.updateTableAt(indexPath: indexPath, direction: 2)
        }
        else {
            let cell = self.transactionsTable.cellForRowAtIndexPath(indexPath)
            cell!.center = CGPointMake(cell!.center.x + 10, cell!.center.y)
            self.updateTableAt(indexPath: indexPath, direction: 1)
        }
    }
}


class HeaderCell : UIView {
    static func cellIdentifier() -> String {
        return "header-cell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 70)
    }
}

class AddMoreCell : UITableViewCell {
    class func cellIdentifier() -> String {
        return "addMoreCell"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 70)
        let centralLabel = UILabel(frame: CGRectMake(0, 0, 200, 30))
        centralLabel.textAlignment = .Center
        centralLabel.center = self.contentView.center
        centralLabel.text = "show more transactions"
        self.contentView.addSubview(centralLabel)
    }
    
    
}

extension mainViewController : UIViewControllerPreviewingDelegate {
    /// Called when the user has pressed a source view in a previewing view controller (Peek).
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        // Get indexPath for location (CGPoint) + cell (for sourceRect)
        guard let indexPath = transactionsTable.indexPathForRowAtPoint(location) else { return nil }
        
        guard let showTransactionViewController = storyboard?.instantiateViewControllerWithIdentifier("showTransactionViewController") as? showTransactionViewController else { return nil }
        showTransactionViewController.transaction = transactionItems[indexPath.row]
        showTransactionViewController.transactionIndex = indexPath.row
        showTransactionViewController.mainVC = self
        showTransactionViewController.sourceVC = "main"
        return showTransactionViewController
    }
    
    /// Called to let you prepare the presentation of a commit (Pop).
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        // Presents viewControllerToCommit in a primary context
        showViewController(viewControllerToCommit, sender: self)
    }
}
