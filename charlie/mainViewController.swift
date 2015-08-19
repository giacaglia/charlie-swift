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
let showTransactionDays = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -21, toDate: NSDate(), options: nil)!
let status = 0


var inboxPredicate = NSPredicate() //items yet to be processed
var approvedPredicate = NSPredicate() // items marked as worth it
var flaggedPredicate = NSPredicate() // items makes as not worth it
var actedUponPredicate = NSPredicate() // items marked as either worth it or not worth it




var keyStore = NSUbiquitousKeyValueStore()
var keyChainStore = KeychainHelper()


var transactionItems = realm.objects(Transaction)
var allTransactionItems = realm.objects(Transaction).sorted("date", ascending: false)



class mainViewController: UIViewController, UITableViewDataSource {
    
    
       
    @IBOutlet weak var userSelectedHappyScoreLabel: UILabel!
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
    @IBOutlet weak var moneyActionAmountLabel: UILabel!
    @IBOutlet weak var moneyActionDetailLabel: UILabel!
    @IBOutlet weak var moneyCountLabel: UILabel!
    @IBOutlet weak var moneyCountSubHeadLabel: UILabel!
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
    
    
    var DynamicView=UIView(frame: UIScreen.mainScreen().bounds)
    
    var pinApproved = false

   
    
    func willEnterForeground(notification: NSNotification!) {
      
        
        if let resultController = storyboard!.instantiateViewControllerWithIdentifier("passcodeViewController") as? passcodeViewController {
            presentViewController(resultController, animated: false, completion: { () -> Void in
            self.pinApproved = true
            self.cHelp.removeSpashImageView(self.view)     
        })
        }
    }
    
    
    func didEnterBackgroundNotification(notification: NSNotification)
    {
        cHelp.splashImageView(self.view)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        
        //if accounts have been added but we don't have transactions that means plaid hasn't retreived transactions yet so check plaid until they have them every x seconds
        if accounts.count > 0 && allTransactionItems.count == 0
        {
            if timerCount == 0 //first time after adding account so show tutorial
            {
                println("account but no transactions")
                timer = NSTimer.scheduledTimerWithTimeInterval(10, target:self, selector: Selector("updateTrans"), userInfo: nil, repeats: true)
                performSegueWithIdentifier("showTutorial", sender: self)
                timerCount = 1
                spinner.startAnimating()
                toastView.hidden = false
                accountAddView.hidden = true
                //show toast
            }
            else
            {
                println("Still waiting")
                //they finished tutorial and account has still not loaded - something until data is loaded
            }
        }
        
        
        transactionsTable.reloadData()
    }
  
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
  
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackgroundNotification:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        
        rewardView.hidden = true
        transactionsTable.hidden = false
        inboxListButton.tag =  1
        

        var access_token = ""
        if keyStore.stringForKey("access_token") != nil
        {
            access_token = keyStore.stringForKey("access_token")!
            keyChainStore.set(access_token, key: "access_token")
     
        }
    
        if accounts.count  == 0  //&& access_token == "" //show add user
        {
            setPredicates(false)
            accountAddView.hidden = false
            addAccountButton.hidden = false
            transactionsTable.hidden = true
             transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
        }
        else
        {
            
            setPredicates(true)
            
            
            transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
            addAccountButton.hidden = true
            accountAddView.hidden = true
            
             //refresh accounts
            
            if allTransactionItems.count > 0
            {
                let  lastTransaction = allTransactionItems[0].date as NSDate
                var calendar: NSCalendar = NSCalendar.currentCalendar()
                let flags = NSCalendarUnit.DayCalendarUnit
                let components = calendar.components(flags, fromDate: lastTransaction, toDate: NSDate(), options: nil)
                
                let dateToSychTo = components.day
                
                spinner.startAnimating()
                println("DAYS \(dateToSychTo)")
                cHelp.addUpdateResetAccount(1, dayLength: dateToSychTo)
                    {
                        (response) in
                        
                        self.transactionsTable.reloadData()
                        self.spinner.stopAnimating()
                        if transactionItems.count == 0 && self.inboxListButton.tag ==  1 && allTransactionItems.count > 0
                        {
                            self.showReward()
                        }
                       self.spinner.stopAnimating()
                }
            }
        }
        
        inboxListButton.tag = 1 //set inbox to default
        
        removeCellBlockLeft = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
        let indexPath = tableView.indexPathForCell(cell)
        let name = transactionItems[indexPath!.row].name
           
            
            if self.inboxListButton.tag == 1 || self.flagListButton.tag == 1
            {

                if defaults.stringForKey("firstSwipeRight") == nil
                {
                    var refreshAlert = UIAlertController(title: "Swipe Right", message: "This transaction will be placed on the worth it tab (the smiley face on the bottom right)", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                       
                        
                    
                        let ctype = transactionItems[indexPath!.row].ctype
                        self.finishSwipe(tableView, cell: cell, direction: 1)
                        if ctype == 0
                        {
                          //  self.performSegueWithIdentifier("showTypePicker", sender: self)
                        }
                        
                        
                        
                        defaults.setObject("yes", forKey: "firstSwipeRight")
                         defaults.synchronize()
                        
                        
                        
                    }))
                    
                    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                        tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)

                    }))
                    
                    self.presentViewController(refreshAlert, animated: true, completion: nil)
                 
                    
                }
                else
                    {
                        let ctype = transactionItems[indexPath!.row].ctype
                        self.finishSwipe(tableView, cell: cell, direction: 1)
                        if ctype == 0
                        {
                           // self.performSegueWithIdentifier("showTypePicker", sender: self)
                        }
                    }
        
            }
            else //swiping not acted on
            {
                tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
            }
        }
        
        
        
        
        removeCellBlockRight = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            let indexPath = tableView.indexPathForCell(cell)
            if self.inboxListButton.tag == 1 || self.approvedListButton.tag == 1
            {
                
                if defaults.stringForKey("firstSwipeLeft") == nil
                {
       
                    var refreshAlert = UIAlertController(title: "Swipe Left", message: "This transaction will be placed on the not worth it tab (the sad face on the bottom left)", preferredStyle: UIAlertControllerStyle.Alert)
                    

                
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    
                    let ctype = transactionItems[indexPath!.row].ctype
                    self.finishSwipe(tableView, cell: cell, direction: 2)
                    if ctype == 0
                    {
                       // self.performSegueWithIdentifier("showTypePicker", sender: self)
                    }

                    
                    defaults.setObject("yes", forKey: "firstSwipeLeft")
                     defaults.synchronize()

                
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                    tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)

                }))
                
                self.presentViewController(refreshAlert, animated: true, completion: nil)
                    
                    
                }
                else
                {
                   
                    let ctype = transactionItems[indexPath!.row].ctype
                    self.finishSwipe(tableView, cell: cell, direction: 2)
                    if ctype == 0
                    {
                      //  self.performSegueWithIdentifier("showTypePicker", sender: self)
                    }
                    

                    
                    
                }
                
                
                
                
            }
           
            
            else
            {
            
                tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
               
            }
        }
        
        
    
        topView.backgroundColor = UIColor.whiteColor()
        let transactionSum = sumTransactionsCount()
        let transactionSumCurrecnyFormat = cHelp.formatCurrency(transactionSum)
        let finalFormat = stripCents(transactionSumCurrecnyFormat)
        moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
        
    }
    
   
    
    
    
    func finishSwipe(tableView: SBGestureTableView, cell: SBGestureTableViewCell, direction: Int)
{
    
    let indexPath = tableView.indexPathForCell(cell)
    currentTransactionSwipeID = transactionItems[indexPath!.row]._id
    currentTransactionCell = cell
    
    realm.beginWrite()
    transactionItems[indexPath!.row].status = direction
    tableView.removeCell(cell, duration: 0.3, completion: nil)
    realm.commitWrite()
    
    let transactionSum = self.sumTransactionsCount()
    let transactionSumCurrecnyFormat = self.cHelp.formatCurrency(transactionSum)
    let finalFormat = self.stripCents(transactionSumCurrecnyFormat)
    self.moneyActionAmountLabel.text  = String(stringInterpolationSegment: finalFormat)
    
    var rowCount = Int(tableView.numberOfRowsInSection(0).value)
    
    if direction == 1
    {
        
        charlieAnalytics.track("Worth It Swipe")
    
    
        if rowCount == 1 && self.inboxListButton.tag == 1
        {
            println("show reward window")
            self.showReward()
        }
    }
    else
    {
         charlieAnalytics.track("Not Worth It Swipe")

        
        if rowCount == 1 && self.inboxListButton.tag == 1
        {
            println("show reward window")
            self.showReward()
        }
        
        
    }
    
}
    
    
    

    func firstDayOfWeek(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        var dateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitWeekOfMonth, fromDate: date)
        dateComponents.weekday = 1
        return calendar.dateFromComponents(dateComponents)!
    }
    
    func startOfMonth(date: NSDate) -> NSDate? {
        
        let calendar = NSCalendar.currentCalendar()
        let currentDateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitWeekOfMonth, fromDate: date)
        let startOfMonth = calendar.dateFromComponents(currentDateComponents)
        
        return startOfMonth
    }

   
    
    func dateByAddingMonths(monthsToAdd: Int, date: NSDate) -> NSDate? {
        
        let calendar = NSCalendar.currentCalendar()
        let months = NSDateComponents()
        months.month = monthsToAdd
        
        return calendar.dateByAddingComponents(months, toDate: date, options: nil)
        
    }
    
    
    
    func endOfMonth(date: NSDate) -> NSDate? {
        
        let calendar = NSCalendar.currentCalendar()
        if let plusOneMonthDate = dateByAddingMonths(1, date: date) {
            let plusOneMonthDateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth, fromDate: plusOneMonthDate)
            
            let endOfMonth = calendar.dateFromComponents(plusOneMonthDateComponents)?.dateByAddingTimeInterval(-86402)
            
            return endOfMonth
        }
        
        return nil
    }
    
   
    
    
    
    
    
    func showReward()
    {
        
        
      var transactionItemsActedUpon = realm.objects(Transaction).filter(actedUponPredicate).sorted("date", ascending: false)
        
        charlieAnalytics.track("Show Reward")
        happyRewardPercentage.textColor = listGreen
        let userSelectedHappyScore =  defaults.stringForKey("userSelectedHappyScore")
        var happyScoreViewed =  defaults.stringForKey("happyScoreViewed")
        let  lastTransaction = transactionItemsActedUpon[0].date as NSDate
        let transactionCount = transactionItemsActedUpon.count - 1
        let firstTransaction = transactionItemsActedUpon[transactionCount].date as NSDate

        
        var months = [String()]
        var unitsSold = [Double()]
     
        
       var transactionsDateDifference = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMonth, fromDate: firstTransaction, toDate: lastTransaction, options: nil).month
       
       
        
        
        if happyScoreViewed == "0" //user hasn't compared what they thought their score was to what it is
        {
            performSegueWithIdentifier("showReveal", sender: self)
            defaults.setValue("1", forKey: "happyScoreViewed")
            defaults.synchronize()
            
        }
        
        
        
        
        if transactionsDateDifference > 1
        {
        
            var i = 2
            
            while i > -1
            {
            
            
            
                let (happyPer, beginDate, endDate) = getHappyPercentageMonthly(lastTransaction, monthsFrom: i)
                
                let dateFormatter = NSDateFormatter()
                //the "M/d/yy, H:mm" is put together from the Symbol Table
                dateFormatter.dateFormat = "M/d"
                let beginDateFormatted = dateFormatter.stringFromDate(beginDate)
                let endDateFormatted = dateFormatter.stringFromDate(endDate)
                
                
                
               
                let dayTimePeriodFormatter = NSDateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMM"
                
                let dateString = dayTimePeriodFormatter.stringFromDate(beginDate)
                
                
                if happyPer >= 0
                {
                    unitsSold.append(Double(happyPer * 100))
                    months.append(dateString)
                    
                    if i == 0
                    {
                        let happyPercentage = Int(happyPer * 100)
                        
                        happyRewardPercentage.text = "\(happyPercentage)%"
                        happyDateRange.text = "Week starting on \(beginDateFormatted)"
                    }
                    
                    
                }
                
                 i -= 1
                
                
                setChart(months, values: unitsSold)
                rewardView.hidden = false
                transactionsTable.hidden = true
                accountAddView.hidden = true
                moneyCountLabel.hidden = true
                happyImage.image = UIImage(named: "result_happy")
                
                var incomeSum:Double = 0.0
                var spendableSum:Double = 0.0
                var billsSum:Double = 0.0
            
            }
            
            
        
        }
        else
        {
            
    
            var i = 12
            var week = 1
            while i > -1
            {
                let (happyPer, beginDate, endDate) = getHappyPercentage(lastTransaction, weeksFrom: i)
                
                let dateFormatter = NSDateFormatter()
                //the "M/d/yy, H:mm" is put together from the Symbol Table
                dateFormatter.dateFormat = "M/d"
                let beginDateFormatted = dateFormatter.stringFromDate(beginDate)
                let endDateFormatted = dateFormatter.stringFromDate(endDate)
                
                if happyPer >= 0
                {
                    unitsSold.append(Double(happyPer * 100))
                    months.append("\(endDateFormatted )")
                
                    if i == 0
                    {
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
                moneyCountLabel.hidden = true
                happyImage.image = UIImage(named: "result_happy")
                
                var incomeSum:Double = 0.0
                var spendableSum:Double = 0.0
                var billsSum:Double = 0.0

                
            }
            
            
            
        }
    
        
       
    
    
    
}



    func getHappyPercentageMonthly(date: NSDate, monthsFrom: Int) -> (Double, NSDate, NSDate)
    {
        
        var newDate = NSDate()
        var startDate = NSDate()
        var endDate = NSDate()
        
        if monthsFrom > 0
        {
            newDate = dateByAddingMonths(monthsFrom * -1, date: date)!
            
            startDate = startOfMonth(newDate)!
            endDate = endOfMonth(newDate)!
            
        }
        else
        {
            startDate = startOfMonth(date)!
            endDate = endOfMonth(date)!
            
        }
        
//        let components: NSDateComponents = NSDateComponents()
//        components.setValue(6, forComponent: NSCalendarUnit.DayCalendarUnit)
//        
//        let first: NSDate = firstDayOfWeek(startDate)
//        let expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: first, options: NSCalendarOptions(rawValue: 0))
        
       
        let chartHappyWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 1 ", startDate, endDate)
        let chartSadWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 2 ", startDate, endDate)
        let chartHappyWeek1Items = realm.objects(Transaction).filter(chartHappyWeek1)
        let chartSadWeek1Items = realm.objects(Transaction).filter(chartSadWeek1)
        //let happySum = chartItems.sum("amount") as Int
        
        let chartHappyWeek1Percentage = Double(chartHappyWeek1Items.count)  / Double((chartHappyWeek1Items.count + chartSadWeek1Items.count)) as Double
        
        println("First = \(startDate) and last \(endDate)")
        println("Happy % \(chartHappyWeek1Percentage)")
        return (chartHappyWeek1Percentage, startDate, endDate)
        
        
        
    }
    
    
    
    func getHappyPercentage(date: NSDate, weeksFrom: Int) -> (Double, NSDate, NSDate)
    {
        
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -(weeksFrom * 7), toDate: date, options: nil)!
        
        let components: NSDateComponents = NSDateComponents()
        components.setValue(6, forComponent: NSCalendarUnit.DayCalendarUnit)
        
        let first: NSDate = firstDayOfWeek(startDate)
        let expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: first, options: NSCalendarOptions(rawValue: 0))
        
        //println("DATES: \(first), \(expirationDate)")
        let chartHappyWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 1 ", first, expirationDate!)
        let chartSadWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 2 ", first, expirationDate!)
        let chartHappyWeek1Items = realm.objects(Transaction).filter(chartHappyWeek1)
        let chartSadWeek1Items = realm.objects(Transaction).filter(chartSadWeek1)
        //let happySum = chartItems.sum("amount") as Int
        
        let chartHappyWeek1Percentage = Double(chartHappyWeek1Items.count)  / Double((chartHappyWeek1Items.count + chartSadWeek1Items.count)) as Double
        
        println("First = \(first) and last \(expirationDate)")
        println("Happy % \(chartHappyWeek1Percentage)")
        return (chartHappyWeek1Percentage, first, expirationDate!)
        
        
        
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
        
        
        
        //chartView!.leftAxis.enabled = false
        
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

    
    
    
    func setPredicates(hasAccounts:Bool)
    {
        
        if hasAccounts
        {
            
            if accounts[0].institution_type == "fake_institution"
            {
                inboxPredicate = NSPredicate(format: "status = 0")
                approvedPredicate = NSPredicate(format: "status = 1")
                flaggedPredicate = NSPredicate(format: "status = 2")
                actedUponPredicate = NSPredicate(format: "status > 0", showTransactionDays)
            }
            else
            {
            
                
                
                inboxPredicate = NSPredicate(format: "status = 0 AND date > %@", showTransactionDays)
                approvedPredicate = NSPredicate(format: "status = 1 AND date > %@", showTransactionDays)
                flaggedPredicate = NSPredicate(format: "status = 2 AND date > %@", showTransactionDays)
                actedUponPredicate = NSPredicate(format: "status > 0 AND date > %@", showTransactionDays)
                
            }
            
        }
        else
        {
            
            inboxPredicate = NSPredicate(format: "status = 0 AND date > %@", showTransactionDays)
            approvedPredicate = NSPredicate(format: "status = 1 AND date > %@", showTransactionDays)
            flaggedPredicate = NSPredicate(format: "status = 2 AND date > %@", showTransactionDays)
             actedUponPredicate = NSPredicate(format: "status > 0 AND date > %@", showTransactionDays)
            
            
        }
        
        
        
        
    }
    
    
    
    func hideReward()
    {
        rewardView.hidden = true
        transactionsTable.hidden = false
        
    }
    
    
    func updateTrans() -> Void
    {
        println("looking for records")
        
        
        cHelp.addUpdateResetAccount(1, dayLength: 0)
            {
                
                (response) in
                
                println(response)
               
                if response > 0
                {
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
    
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transactionItems.count > 0
        {
            transactionsTable.hidden = false
            addAccountButton.hidden = true
            accountAddView.hidden = true
            let transactionSum = sumTransactionsCount()
            let transactionSumCurrecnyFormat = cHelp.formatCurrency(transactionSum)
            let finalFormat = stripCents(transactionSumCurrecnyFormat)
            moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
            
            
        }
        return transactionItems.count
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        

        performSegueWithIdentifier("segueFromMainToDetailView", sender: self)
        
    }
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        
        let size = CGSizeMake(30, 30)
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SBGestureTableViewCell
        cell.firstLeftAction = SBGestureTableViewCellAction(icon: checkImage!, color: listGreen, fraction: 0.35, didTriggerBlock: removeCellBlockLeft)
        cell.firstRightAction = SBGestureTableViewCellAction(icon: flagImage!, color: listRed, fraction: 0.35, didTriggerBlock: removeCellBlockRight)
        cell.nameCellLabel.text = transactionItems[indexPath.row].name
        cell.amountCellLabel.text = cHelp.formatCurrency(transactionItems[indexPath.row].amount)
      
        
        

        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EE, MMMM dd " //format style. Browse online to get a format that fits your needs.
        var dateString = dateFormatter.stringFromDate(transactionItems[indexPath.row].date)
        cell.dateCellLabel.text = dateString
        //cell.selectionStyle = .None
       
        
        
        
            
        
        
        if inboxListButton.tag == 1
        {cell.amountCellLabel.textColor = listBlue}
        else if flagListButton.tag == 1 {cell.amountCellLabel.textColor = listRed}
        else if approvedListButton.tag == 1 {cell.amountCellLabel.textColor = listGreen}
        
        
        
        
        return cell
    }
    
    func stripCents(currency: String) -> String
    {
        let stringLength = count(currency) // Since swift1.2 `countElements` became `count`
        let substringIndex = stringLength - 3
        return currency.substringToIndex(advance(currency.startIndex, substringIndex))
        
    }
  
    func sumTransactionsCount() -> Double
    {
        var transactionSum:Double = 0
        for transaction in transactionItems {
            
            
            if transaction.amount < 0
            { transactionSum += transaction.amount * -1 }
            else
            { transactionSum += transaction.amount  }
       
        }
        

        
        return transactionSum
        
        
  
    }
    
        
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        

        if (segue.identifier == "segueFromMainToDetailView") {
            let viewController = segue.destinationViewController as! showTransactionViewController
            viewController.mainVC = self
            let indexPath = self.transactionsTable.indexPathForSelectedRow()
            viewController.transactionIndex = indexPath!.row
            
            
        }
        else if (segue.identifier == "showTypePicker") {
            
            
          
         
            let viewController = segue.destinationViewController as! showTypePickerViewController
            //let indexPath = self.transactionsTable.indexPathForSelectedRow()
            viewController.transactionID = currentTransactionSwipeID
            viewController.transactionCell = currentTransactionCell
            viewController.mainVC = self

            
        }
        else if (segue.identifier == "showReveal")
        {
           var userSelectedHappyScore =  defaults.stringForKey("userSelectedHappyScore")!
            
            let viewController = segue.destinationViewController as! revealViewController
            viewController.revealPercentage = "\(userSelectedHappyScore)"
        }
 
    }
    
    
    
   
   

    @IBAction func showTutorial(sender: UIButton) {
        
         // performSegueWithIdentifier("showTutorial", sender: self)
        
        //remove icloud 
        
//
        keyStore.setString("", forKey: "access_token")
        keyStore.setString("", forKey: "email")
        keyStore.setString("", forKey: "password")
        keyStore.synchronize()
        
    }
   

    
    
   

    
    
    @IBAction func refreshAccounts(sender: UIButton) {
        
   
        if Reachability.isConnectedToNetwork() {
            // Go ahead and fetch your data from the internet
            // ...
            
            if allTransactionItems.count > 0
            {
                let  lastTransaction = allTransactionItems[0].date as NSDate
                var calendar: NSCalendar = NSCalendar.currentCalendar()
                let flags = NSCalendarUnit.DayCalendarUnit
                let components = calendar.components(flags, fromDate: lastTransaction, toDate: NSDate(), options: nil)
                
                let dateToSychTo = components.day
                
                spinner.startAnimating()
                println("DAYS \(dateToSychTo)")
                cHelp.addUpdateResetAccount(1, dayLength: dateToSychTo)
                    {
                        (response) in
                        
                        self.transactionsTable.reloadData()
                        self.spinner.stopAnimating()
                        if transactionItems.count == 0 && self.inboxListButton.tag ==  1 && allTransactionItems.count > 0
                        {
                            self.showReward()
                        }

              
                
                }
                
            }
            
        } else {
            println("Internet connection not available")
            
            var alert = UIAlertView(title: "No Internet connection", message: "Please ensure you are connected to the Internet", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }

    }
    
    
    @IBAction func approvedListButtonress(sender: UIButton) {
        
        
        charlieAnalytics.track("Worth It Button")
        
        hideReward()
        
        transactionItems = realm.objects(Transaction).filter(approvedPredicate).sorted("date", ascending: false)
        transactionsTable.reloadData()

         listNavBar.backgroundColor = listGreen
        
        inboxListButton.tag = 0
        inboxListButton.setImage(inboxUnSelectedHappyButtonImage, forState: .Normal)
        
        flagListButton.tag = 0
        flagListButton.setImage(flagUnSelectedHappyButtonImage, forState: .Normal)
        
        
        approvedListButton.tag = 1
        approvedListButton.setImage(approvedSelectedButtonImage, forState: .Normal)
        dividerView.backgroundColor = listGreen
        topView.backgroundColor = UIColor.whiteColor()
    
        moneyCountSubHeadLabel.text = "Worth it!"
        
        let transactionSum = sumTransactionsCount()
        let transactionSumCurrecnyFormat = cHelp.formatCurrency(transactionSum)
        let finalFormat = stripCents(transactionSumCurrecnyFormat)
       
        
        topSeperator.backgroundColor = listGreen
        
        moneyActionAmountLabel.textColor = listGreen
        moneyActionDetailLabel.textColor = listGreen
        
        moneyCountLabel.hidden = true
        moneyCountSubHeadLabel.hidden = true
        moneyCountSubSubHeadLabel.hidden = true
       
        
        moneyActionAmountLabel.hidden = false
        moneyActionDetailLabel.hidden = false
        
        moneyActionAmountLabel.text = String(stringInterpolationSegment: finalFormat)
        moneyActionDetailLabel.text = "money well spent"

        

        //menuButton.setImage(menuButtonGreenImage, forState: .Normal)
        //cardButton.setImage(cardButtonGreenImage, forState: .Normal)

    
        
    }
   
    
    
    @IBAction func inboxListButtonPress(sender: UIButton) {
        
        
        
        charlieAnalytics.track("Inbox Button")
        
        transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
       
        
        if transactionItems.count == 0 && allTransactionItems.count > 0
        {
            showReward()
        }
        else{
            if accounts.count  == 0 && allTransactionItems.count == 0
            {
                addAccountButton.hidden = false
                accountAddView.hidden = false
                transactionsTable.hidden = true
            }
            
        }
           
            transactionsTable.reloadData()
          
            
            listNavBar.backgroundColor = listBlue
            
            moneyCountLabel.hidden = false
            moneyCountSubHeadLabel.hidden = false
            moneyCountSubSubHeadLabel.hidden = false
           
            
            moneyActionAmountLabel.hidden = true
            moneyActionDetailLabel.hidden = true

            
            inboxListButton.tag = 1
            inboxListButton.setImage(inboxSelectedButtonImage, forState: .Normal)
            topView.backgroundColor = UIColor.whiteColor()
            dividerView.backgroundColor = listBlue
            moneyCountSubHeadLabel.text = "Was it"
            
            let transactionSum = sumTransactionsCount()
            let transactionSumCurrecnyFormat = cHelp.formatCurrency(transactionSum)
            let finalFormat = stripCents(transactionSumCurrecnyFormat)
            moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
            

            topSeperator.backgroundColor = listBlue
            
            flagListButton.tag = 0
            flagListButton.setImage(flagUnSelectedInboxButtonImage, forState: .Normal)
            
            
            approvedListButton.tag = 0
            approvedListButton.setImage(approvedUnSelectedInboxButtonImage, forState: .Normal)
            
           // menuButton.setImage(menuButtonBlueImage, forState: .Normal)
           // cardButton.setImage(cardButtonBlueImage, forState: .Normal)
        
    
        

        
    }
    
    
    @IBAction func flagListButtonPress(sender: UIButton) {

        
        charlieAnalytics.track("Not Worth It Button")
        
        hideReward()
        
        transactionItems = realm.objects(Transaction).filter(flaggedPredicate).sorted("date", ascending: false)
        transactionsTable.reloadData()
        
         listNavBar.backgroundColor = listRed
    
        
        inboxListButton.tag = 0
        inboxListButton.setImage(inboxUnSelectedSadButtonImage, forState: .Normal)
        
        flagListButton.tag = 1
        flagListButton.setImage(flagSelectedButtonImage, forState: .Normal)
        topView.backgroundColor = UIColor.whiteColor()
        dividerView.backgroundColor = listRed
        moneyCountSubHeadLabel.text = "Not Worth it!"
        
        let transactionSum = sumTransactionsCount()
        let transactionSumCurrecnyFormat = cHelp.formatCurrency(transactionSum)
        let finalFormat = stripCents(transactionSumCurrecnyFormat)
        moneyCountLabel.hidden = true
        moneyCountSubHeadLabel.hidden = true
        moneyCountSubSubHeadLabel.hidden = true
       
        
        moneyActionAmountLabel.hidden = false
        moneyActionDetailLabel.hidden = false

        topSeperator.backgroundColor = listRed
        
        moneyActionAmountLabel.text = String(stringInterpolationSegment: finalFormat)
        moneyActionDetailLabel.text = "could've spent better"
        
        moneyActionAmountLabel.textColor = listRed
        moneyActionDetailLabel.textColor = listRed
        
        approvedListButton.tag = 0
        approvedListButton.setImage(approvedUnSelectedSadButtonImage, forState: .Normal)
        
       // menuButton.setImage(menuButtonRedImage, forState: .Normal)
       // cardButton.setImage(cardButtonRedImage, forState: .Normal)

        
    }
    

    

  }



