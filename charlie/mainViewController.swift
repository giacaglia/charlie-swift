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
    case FlaggedTransaction, ApprovedTransaction
}

enum SortFilterType {
    case FilterByName, FilterByDate, FilterByAmount
}

class mainViewController: UIViewController {
    
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var transactionsTable: SBGestureTableView!
    @IBOutlet weak var happyDateRange: UILabel!
    @IBOutlet weak var chartView: LineChartView?
    @IBOutlet weak var listNavBar: UIView!
    @IBOutlet weak var approvedListButton: UIButton!
    @IBOutlet weak var inboxListButton: UIButton!
    @IBOutlet weak var flagListButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var accountAddView: UIView!
    @IBOutlet weak var rewardView: UIView!
    @IBOutlet weak var happyImage: UIImageView!
    @IBOutlet weak var happyRewardPercentage: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topSeperator: UIView!
    @IBOutlet weak var moneyCountLabel: UILabel!
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
        inboxListButton.tag =  1
        
        var access_token = ""
        if keyStore.stringForKey("access_token") != nil {
            access_token = keyStore.stringForKey("access_token")!
            keyChainStore.set(access_token, key: "access_token")
        }
        
        if accounts.count  == 0 {
            //&& access_token == "" //show add user
            setPredicates(false)
            accountAddView.hidden = false
            addAccountButton.hidden = false
            transactionsTable.hidden = true
            transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
            charlieAnalytics.track("Find Bank Screen - Main")
        }
        else {
            setPredicates(true)
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
                    if transactionItems.count == 0 && self.inboxListButton.tag ==  1 && allTransactionItems.count > 0 {
                        self.showReward()
                    }
                }
            }
        }
        
        inboxListButton.tag = 1 //set inbox to default
        
        removeCellBlockLeft = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            if self.inboxListButton.tag == 1 || self.flagListButton.tag == 1 {
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
            if self.inboxListButton.tag == 1 || self.approvedListButton.tag == 1 {
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
        
        moneyCountLabel.layer.borderColor = UIColor.clearColor().CGColor
        moneyCountLabel.layer.borderWidth = 1.0
        moneyCountLabel.layer.cornerRadius = moneyCountLabel.frame.size.width/2.0
        moneyCountLabel.clipsToBounds = true
        moneyCountLabel.text = String(transactionItems.count)
    }
    
    func showReward() {
        let type: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
        let setting = UIUserNotificationSettings(forTypes: type, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(setting)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        let transactionItemsActedUpon = realm.objects(Transaction).filter(actedUponPredicate).sorted("date", ascending: false)
        
        charlieAnalytics.track("Show Reward")
        happyRewardPercentage.textColor = listGreen
        let happyScoreViewed =  defaults.stringForKey("happyScoreViewed")
        let lastTransaction = transactionItemsActedUpon[0].date as NSDate
        let transactionCount = transactionItemsActedUpon.count - 1
        let firstTransaction = transactionItemsActedUpon[transactionCount].date as NSDate
        
        var months = [String()]
        var unitsSold = [Double()]
        
        let transactionsDateDifference = NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: firstTransaction, toDate: lastTransaction, options: []).month
        
        if happyScoreViewed == "0"  {
            //user hasn't compared what they thought their score was to what it is
            performSegueWithIdentifier("showReveal", sender: self)
            defaults.setValue("1", forKey: "happyScoreViewed")
            defaults.synchronize()
        }
        
        if transactionsDateDifference >= 1 {
            var i = 2
            while i > -1 {
                let (happyPer, beginDate, _) = getHappyPercentageMonthly(lastTransaction, monthsFrom: i)
                let dateFormatter = NSDateFormatter()
                //the "M/d/yy, H:mm" is put together from the Symbol Table
                dateFormatter.dateFormat = "M/d"
                let beginDateFormatted = dateFormatter.stringFromDate(beginDate)
                let dayTimePeriodFormatter = NSDateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMM"
                let dateString = dayTimePeriodFormatter.stringFromDate(beginDate)
                
                if happyPer >= 0 {
                    unitsSold.append(Double(happyPer * 100))
                    months.append(dateString)
                    if i == 0 {
                        let happyPercentage = Int(happyPer * 100)
                        happyRewardPercentage.text = "\(happyPercentage)%"
                        happyDateRange.text = "Starting on \(beginDateFormatted)"
                    }
                }
                i -= 1
                setChart(months, values: unitsSold)
                rewardView.hidden = false
                transactionsTable.hidden = true
                accountAddView.hidden = true
                happyImage.image = UIImage(named: "result_happy")
            }
        }
        else {
            var i = 12
            var week = 1
            while i > -1 {
                let (happyPer, beginDate, endDate) = getHappyPercentage(lastTransaction, weeksFrom: i)
                let dateFormatter = NSDateFormatter()
                //the "M/d/yy, H:mm" is put together from the Symbol Table
                dateFormatter.dateFormat = "M/d"
                let beginDateFormatted = dateFormatter.stringFromDate(beginDate)
                let endDateFormatted = dateFormatter.stringFromDate(endDate)
                
                if happyPer >= 0 {
                    unitsSold.append(Double(happyPer * 100))
                    months.append("\(endDateFormatted )")
                    if i == 0 {
                        let happyPercentage = Int(happyPer * 100)
                        happyRewardPercentage.text = "\(happyPercentage)%"
                        happyDateRange.text = "Week starting on \(beginDateFormatted)"
                    }
                }
                i -= 1
                week += 1
                
                setChart(months, values: unitsSold)
                rewardView.hidden = false
                transactionsTable.hidden = true
                accountAddView.hidden = true
                happyImage.image = UIImage(named: "result_happy")
            }
        }
    }
    
    
    func setChart(dataPoints: [String], values: [Double]) {
        chartView!.noDataText = "You need to provide data for the chart."
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Weeks")
        lineChartDataSet.drawFilledEnabled = true
        lineChartDataSet.fillColor = UIColor.lightGrayColor()
        lineChartDataSet.drawValuesEnabled = true
        lineChartDataSet.drawCirclesEnabled = true
        lineChartDataSet.drawCubicEnabled = true
        
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        chartView!.gridBackgroundColor = UIColor.whiteColor()
        chartView!.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        chartView!.rightAxis.drawGridLinesEnabled = false
        chartView!.leftAxis.drawGridLinesEnabled = false
        chartView!.xAxis.drawGridLinesEnabled = false
        chartView!.xAxis.axisLineColor = UIColor.lightGrayColor()
        chartView!.xAxis.labelTextColor = UIColor.darkGrayColor()
        chartView!.leftAxis.labelTextColor = UIColor.darkGrayColor()
        chartView!.leftAxis.labelCount = 4
        chartView!.pinchZoomEnabled = true
        chartView!.leftAxis.axisLineWidth = 10
        chartView!.leftAxis.valueFormatter = NSNumberFormatter()
        chartView!.leftAxis.valueFormatter!.minimumFractionDigits = 0
        chartView!.leftAxis.labelFont = UIFont (name: "Helvetica Neue", size: 16)!
        chartView!.leftAxis.axisLineColor = UIColor.whiteColor()
        chartView!.rightAxis.enabled = false
        chartView!.xAxis.labelPosition = .Bottom
        chartView!.xAxis.axisLineColor = UIColor.lightGrayColor()
        chartView!.xAxis.enabled = true
        chartView!.legend.enabled = false
        chartView!.descriptionText = ""
        chartView!.data = lineChartData
        chartView!.maxVisibleValueCount = 3
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
        transactionsTable.hidden = false
    }
    
    func updateTrans() -> Void {
        print("looking for records")
        cHelp.addUpdateResetAccount(1, dayLength: 0) { (response) in
            charlieAnalytics.track("Account Transations Initial Sync Completed")
            
            print(response)
            if response > 0 {
                self.timer.invalidate()
                self.setPredicates(true)
                transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
                allTransactionItems = realm.objects(Transaction).sorted("date", ascending: false)
                self.transactionsTable.reloadData()
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
            
            if flagListButton.tag == 1 {
                viewController.comingFromSad = true
            }
            else if approvedListButton.tag == 1 {
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
        if filterType == .FilterByName {
            filterType = .FilterByDate
        }
        else if filterType == .FilterByDate {
            filterType = .FilterByAmount
        }
        else {
            filterType = .FilterByName
        }
        charlieGroupListFiltered = groupBy(.FlaggedTransaction, sortFilter: filterType) as! [(charlieGroup)]
        transactionsTable.reloadData()
    }
    
    
    @IBAction func approvedListButtonress(sender: UIButton) {
        charlieAnalytics.track("Worth It Button")
        transactionsTable.backgroundColor = UIColor.clearColor();
        self.view.backgroundColor = lightGreen
        hideReward()
        
        transactionItems = realm.objects(Transaction).filter(approvedPredicate).sorted("name", ascending: true)
        listNavBar.backgroundColor = listGreen
        
        inboxListButton.tag = 0
        inboxListButton.setImage(inboxUnSelectedHappyButtonImage, forState: .Normal)
        
        flagListButton.tag = 0
        flagListButton.setImage(flagUnSelectedHappyButtonImage, forState: .Normal)
        
        approvedListButton.tag = 1
        approvedListButton.setImage(approvedSelectedButtonImage, forState: .Normal)
        dividerView.backgroundColor = listGreen
        
        topSeperator.backgroundColor = listGreen
        moneyCountSubSubHeadLabel.text = "Worth"
        moneyCountSubSubHeadLabel.textColor = listGreen
        moneyCountLabel.hidden = true
        
        charlieGroupListFiltered = groupBy(.ApprovedTransaction, sortFilter: filterType) as! [(charlieGroup)]
        transactionsTable.reloadData()
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
            if accounts.count  == 0 && allTransactionItems.count == 0 {
                addAccountButton.hidden = false
                accountAddView.hidden = false
                transactionsTable.hidden = true
                charlieAnalytics.track("Find Bank Screen - Main")
            }
        }
        
        listNavBar.backgroundColor = listBlue
        
        inboxListButton.tag = 1
        inboxListButton.setImage(inboxSelectedButtonImage, forState: .Normal)
        dividerView.backgroundColor = listBlue
        
        moneyCountLabel.text = String(transactionItems.count)
        
        moneyCountSubSubHeadLabel.text = "Worth it?"
        moneyCountSubSubHeadLabel.textColor = listBlue
        moneyCountLabel.hidden = false

        
        topSeperator.backgroundColor = listBlue
        flagListButton.tag = 0
        flagListButton.setImage(flagUnSelectedInboxButtonImage, forState: .Normal)
        
        approvedListButton.tag = 0
        approvedListButton.setImage(approvedUnSelectedInboxButtonImage, forState: .Normal)
        transactionsTable.reloadData()
    }
    
    
    @IBAction func flagListButtonPress(sender: UIButton) {
        charlieAnalytics.track("Not Worth It Button")
        self.view.backgroundColor = lightRed
        transactionsTable.backgroundColor = UIColor.clearColor();
        hideReward()
        
        transactionItems = realm.objects(Transaction).filter(flaggedPredicate).sorted("date", ascending: false)
        
        listNavBar.backgroundColor = listRed
        
        inboxListButton.tag = 0
        inboxListButton.setImage(inboxUnSelectedSadButtonImage, forState: .Normal)
        
        flagListButton.tag = 1
        flagListButton.setImage(flagSelectedButtonImage, forState: .Normal)
        dividerView.backgroundColor = listRed
        moneyCountSubSubHeadLabel.text = "Not Worth it!"
        moneyCountSubSubHeadLabel.textColor = listRed
        moneyCountLabel.hidden = true
        
        topSeperator.backgroundColor = listRed

        approvedListButton.tag = 0
        approvedListButton.setImage(approvedUnSelectedSadButtonImage, forState: .Normal)
        
        charlieGroupListFiltered = groupBy(.FlaggedTransaction, sortFilter: filterType) as! [(charlieGroup)]
        transactionsTable.reloadData()
    }
    
    
    func groupBy(type: TransactionType, sortFilter: SortFilterType) -> NSArray {
        charlieGroupList = []
        var current_name = ""
        let sortProperties : Array<SortDescriptor>!
        if sortFilter == .FilterByName {
            sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: true)]
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
                print("add to existing \(trans.name) at index \(current_index)")
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
        else {
            return charlieGroupList.filter({$0.notWorthValue > 0})
        }
    }
}

//Happy calculations
extension mainViewController {
    func getHappyPercentageMonthly(date: NSDate, monthsFrom: Int) -> (happyPerc: Double, beginDate: NSDate, endDate: NSDate) {
        var newDate = NSDate()
        var startDate = NSDate()
        var endDate = NSDate()
        
        if monthsFrom > 0 {
            newDate = dateByAddingMonths(monthsFrom * -1, date: date)!
            
            startDate = startOfMonth(newDate)!
            endDate = endOfMonth(newDate)!
        }
        else {
            startDate = startOfMonth(date)!
            endDate = endOfMonth(date)!
        }
        
        let chartHappyWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 1 ", startDate, endDate)
        let chartSadWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 2 ", startDate, endDate)
        let chartHappyWeek1Items = realm.objects(Transaction).filter(chartHappyWeek1)
        let chartSadWeek1Items = realm.objects(Transaction).filter(chartSadWeek1)
        //let happySum = chartItems.sum("amount") as Int
        
        let chartHappyWeek1Percentage = Double(chartHappyWeek1Items.count)  / Double((chartHappyWeek1Items.count + chartSadWeek1Items.count)) as Double
        
        print("First = \(startDate) and last \(endDate)")
        print("Happy % \(chartHappyWeek1Percentage)")
        return (chartHappyWeek1Percentage, startDate, endDate)
    }
    
    func getHappyPercentage(date: NSDate, weeksFrom: Int) -> (happyPerc: Double, beginDate: NSDate, endDate: NSDate) {
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -(weeksFrom * 7), toDate: date, options: [])!
        
        let components: NSDateComponents = NSDateComponents()
        components.setValue(6, forComponent: NSCalendarUnit.Day)
        
        let first: NSDate = firstDayOfWeek(startDate)
        let expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: first, options: NSCalendarOptions(rawValue: 0))
        
        //println("DATES: \(first), \(expirationDate)")
        let chartHappyWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 1 ", first, expirationDate!)
        let chartSadWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 2 ", first, expirationDate!)
        let chartHappyWeek1Items = realm.objects(Transaction).filter(chartHappyWeek1)
        let chartSadWeek1Items = realm.objects(Transaction).filter(chartSadWeek1)
        //let happySum = chartItems.sum("amount") as Int
        
        let chartHappyWeek1Percentage = Double(chartHappyWeek1Items.count)  / Double((chartHappyWeek1Items.count + chartSadWeek1Items.count)) as Double
        
        print("First = \(first) and last \(expirationDate)")
        print("Happy % \(chartHappyWeek1Percentage)")
        return (chartHappyWeek1Percentage, first, expirationDate!)
    }
}

// Transaction helpers
extension mainViewController {
    func stripCents(currency: String) -> String {
        let stringLength = currency.characters.count // Since swift1.2 `countElements` became `count`
        let substringIndex = stringLength - 3
        return currency.substringToIndex(currency.startIndex.advancedBy(substringIndex))
    }
    
}

// NSDate helpers
extension mainViewController {
    func firstDayOfWeek(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([.Year, .Month, .WeekOfMonth], fromDate: date)
        dateComponents.weekday = 1
        return calendar.dateFromComponents(dateComponents)!
    }
    
    func startOfMonth(date: NSDate) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let currentDateComponents = calendar.components([.Year, .Month, .WeekOfMonth], fromDate: date)
        let startOfMonth = calendar.dateFromComponents(currentDateComponents)
        return startOfMonth
    }
    
    func dateByAddingMonths(monthsToAdd: Int, date: NSDate) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let months = NSDateComponents()
        months.month = monthsToAdd
        return calendar.dateByAddingComponents(months, toDate: date, options: [])
    }
    
    func endOfMonth(date: NSDate) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        if let plusOneMonthDate = dateByAddingMonths(1, date: date) {
            let plusOneMonthDateComponents = calendar.components([.Year, .Month], fromDate: plusOneMonthDate)
            
            let endOfMonth = calendar.dateFromComponents(plusOneMonthDateComponents)?.dateByAddingTimeInterval(-86402)
            
            return endOfMonth
        }
        return nil
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
        moneyCountLabel.text = String(transactionItems.count)

        let rowCount = Int(tableView.numberOfRowsInSection(0).value)
        
        if direction == 1 {
            charlieAnalytics.track("Worth It Swipe")
            if rowCount == 1 && self.inboxListButton.tag == 1 {
                print("show reward window")
                self.showReward()
            }
        }
        else {
            charlieAnalytics.track("Not Worth It Swipe")
            
            if rowCount == 1 && self.inboxListButton.tag == 1 {
                print("show reward window")
                self.showReward()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if flagListButton.tag == 1 || approvedListButton.tag == 1 {
            return charlieGroupListFiltered.count
        }
        else {
            if transactionItems.count > 0 {
                transactionsTable.hidden = false
                addAccountButton.hidden = true
                accountAddView.hidden = true
            }
            return transactionItems.count
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if flagListButton.tag == 1 || approvedListButton.tag == 1 {
            performSegueWithIdentifier("groupDetail", sender: indexPath)
        }
        else {
            performSegueWithIdentifier("segueFromMainToDetailView", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SBGestureTableViewCell
        
        if flagListButton.tag == 1 {
            cell.nameCellLabel.text = charlieGroupListFiltered[indexPath.row].name
            cell.amountCellLabel.text = cHelp.formatCurrency(charlieGroupListFiltered[indexPath.row].notWorthValue)
            let totalTransactions = charlieGroupListFiltered[indexPath.row].worthCount + charlieGroupListFiltered[indexPath.row].notWorthCount
            cell.dateCellLabel.text = "\(charlieGroupListFiltered[indexPath.row].notWorthCount)/\(totalTransactions) transactions"
            
            cell.firstLeftAction = nil
            cell.firstRightAction = nil
        }
        else if approvedListButton.tag == 1 {
            cell.nameCellLabel.text = charlieGroupListFiltered[indexPath.row].name
            cell.amountCellLabel.text = cHelp.formatCurrency(charlieGroupListFiltered[indexPath.row].worthValue)
            let totalTransactions = charlieGroupListFiltered[indexPath.row].worthCount + charlieGroupListFiltered[indexPath.row].notWorthCount
            cell.dateCellLabel.text = "\(charlieGroupListFiltered[indexPath.row].worthCount)/\(totalTransactions) transactions"
            cell.firstLeftAction = nil
            cell.firstRightAction = nil
        }
        else {
            cell.firstLeftAction = SBGestureTableViewCellAction(icon: checkImage!, color: listGreen, fraction: 0.35, didTriggerBlock: removeCellBlockLeft)
            cell.firstRightAction = SBGestureTableViewCellAction(icon: flagImage!, color: listRed, fraction: 0.35, didTriggerBlock: removeCellBlockRight)
            cell.nameCellLabel.text = transactionItems[indexPath.row].name
            cell.amountCellLabel.text = cHelp.formatCurrency(transactionItems[indexPath.row].amount)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EE, MMMM dd " //format style. Browse online to get a format that fits your needs.
            let dateString = dateFormatter.stringFromDate(transactionItems[indexPath.row].date)
            cell.dateCellLabel.text = dateString
        }
        
        if inboxListButton.tag == 1
        {cell.amountCellLabel.textColor = listBlue}
        else if flagListButton.tag == 1 {cell.amountCellLabel.textColor = listRed}
        else if approvedListButton.tag == 1 {cell.amountCellLabel.textColor = listGreen}
        return cell
    }
}
