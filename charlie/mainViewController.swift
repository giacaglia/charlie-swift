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



let date = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -21, toDate: NSDate(), options: nil)!
let status = 0


var inboxPredicate = NSPredicate()
var approvedPredicate = NSPredicate()
var flaggedPredicate = NSPredicate()



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
    var months: [String]!
    
    
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
    
    //this is a test
    
   
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
    
   
    
    
//    override func viewDidAppear(animated: Bool) {
//        self.view.viewWithTag(86)?.removeFromSuperview()
//
//    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        
        if accounts.count > 0 && allTransactionItems.count > 0
        {
            println("normal all is loaded")
            
        }
      
        //if accounts have been added but we don't have transactions that means plaid hasn't retreived transactions yet so check plaid until they have them every x seconds
        else if accounts.count > 0 && allTransactionItems.count == 0
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
        else if accounts.count == 0
        {
            println("First Time in or has never added an account")
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
            println("REFRESH ACCOUNTS")
            let access_token =  keyChainStore.get("access_token")
            
            if allTransactionItems.count > 0
            {
                let  lastTransaction = allTransactionItems[0].date as NSDate
            }

            
            
            spinner.startAnimating()
           
         
            //All stuff here
            
           cHelp.addUpdateResetAccount(1, dayLength: 7)
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
                       
                        
                        self.currentTransactionSwipeID = transactionItems[indexPath!.row]._id
                        self.currentTransactionCell = cell
                        
                        realm.beginWrite()
                        transactionItems[indexPath!.row].status = 1
                        tableView.removeCell(cell, duration: 0.3, completion: nil)
                        realm.commitWrite()
                        
                        let transactionSum = self.sumTransactionsCount()
                        let transactionSumCurrecnyFormat = self.cHelp.formatCurrency(transactionSum)
                        let finalFormat = self.stripCents(transactionSumCurrecnyFormat)
                        self.moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
                        
                        var rowCount = Int(tableView.numberOfRowsInSection(0).value)
                        
                         charlieAnalytics.track("Worth It Swipe")
                        
                        
                        if rowCount == 1 && self.inboxListButton.tag == 1
                        {
                            println("show reward window")
                            self.showReward()
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
                        self.currentTransactionSwipeID = transactionItems[indexPath!.row]._id
                        self.currentTransactionCell = cell
                       
                            realm.beginWrite()
                                transactionItems[indexPath!.row].status = 1
                                tableView.removeCell(cell, duration: 0.3, completion: nil)
                            realm.commitWrite()
            
                        let transactionSum = self.sumTransactionsCount()
                            let transactionSumCurrecnyFormat = self.cHelp.formatCurrency(transactionSum)
                            let finalFormat = self.stripCents(transactionSumCurrecnyFormat)
                            self.moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
                        
                        var rowCount = Int(tableView.numberOfRowsInSection(0).value)
                        
                        
                        if rowCount == 1 && self.inboxListButton.tag == 1
                        {
                            println("show reward window")
                            self.showReward()
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
                    
                    realm.beginWrite()
                    transactionItems[indexPath!.row].status = 2
                    realm.commitWrite()
                    
                    
                    
                    
                    tableView.removeCell(cell, duration: 0.3, completion: nil)
                    let transactionSum = self.sumTransactionsCount()
                    let transactionSumCurrecnyFormat = self.cHelp.formatCurrency(transactionSum)
                    let finalFormat = self.stripCents(transactionSumCurrecnyFormat)
                    self.moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
                    
                    charlieAnalytics.track("Not Worth It Swipe")
                    
                    var rowCount = Int(tableView.numberOfRowsInSection(0).value)
                    
                    
                    if rowCount == 1 && self.inboxListButton.tag == 1
                    {
                        println("show reward window")
                        self.showReward()
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
                
                realm.beginWrite()
                transactionItems[indexPath!.row].status = 2
                realm.commitWrite()
                tableView.removeCell(cell, duration: 0.3, completion: nil)
                let transactionSum = self.sumTransactionsCount()
                let transactionSumCurrecnyFormat = self.cHelp.formatCurrency(transactionSum)
                let finalFormat = self.stripCents(transactionSumCurrecnyFormat)
                self.moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
                
                
                var rowCount = Int(tableView.numberOfRowsInSection(0).value)
                
                
                if rowCount == 1 && self.inboxListButton.tag == 1
                {
                    println("show reward window")
                    self.showReward()
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
    
   
 func setChart(dataPoints: [String], values: [Double]) {
        chartView!.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
          
            dataEntries.append(dataEntry)
        }
        
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
        
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



    func firstDayOfWeek(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        var dateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitWeekOfMonth, fromDate: date)
        dateComponents.weekday = 1
        return calendar.dateFromComponents(dateComponents)!
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
    
    
    
    func showReward()
    {
        
        
        charlieAnalytics.track("Show Reward")
        
        happyRewardPercentage.textColor = listGreen
        months = [String()]
        
        var unitsSold = [Double()]
        let userSelectedHappyScore =  defaults.stringForKey("userSelectedHappyScore")
        
        var happyScoreViewed =  defaults.stringForKey("happyScoreViewed")
        
        
       let  lastTransaction = allTransactionItems[0].date as NSDate
        
        
        if happyScoreViewed == "0"
        {
            performSegueWithIdentifier("showReveal", sender: self)
            defaults.setValue("1", forKey: "happyScoreViewed")
            defaults.synchronize()

        }
        
        
        //println(getHappyPercentage(NSDate(), weeksFrom: 1))
        
        
        //get happyPercentages for last x weeks
        var i = 4
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
                happyDateRange.text = "Week of \(beginDateFormatted)"
            }
           
           
        }
            i -= 1
            week += 1
            
        }
        
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
    
    
    
    
    
    func setPredicates(hasAccounts:Bool)
    {
        
        if hasAccounts
        {
            
            if accounts[0].institution_type == "fake_institution"
            {
                inboxPredicate = NSPredicate(format: "status = 0")
                approvedPredicate = NSPredicate(format: "status = 1")
                flaggedPredicate = NSPredicate(format: "status = 2")
            }
            else
            {
                
                
                inboxPredicate = NSPredicate(format: "status = 0 AND date > %@", date)
                approvedPredicate = NSPredicate(format: "status = 1 AND date > %@", date)
                flaggedPredicate = NSPredicate(format: "status = 2 AND date > %@", date)
                
            }
            
        }
        else
        {
            
            inboxPredicate = NSPredicate(format: "status = 0 AND date > %@", date)
            approvedPredicate = NSPredicate(format: "status = 1 AND date > %@", date)
            flaggedPredicate = NSPredicate(format: "status = 2 AND date > %@", date)
            
            
            
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
        
        
        
        println(indexPath.row)
        println(transactionItems[indexPath.row].ctype)
        println(transactionItems[indexPath.row].name)
        

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
        
     
      if accounts.count > 0
        {
            let access_token =  keyChainStore.get("access_token")
            spinner.startAnimating()
            cHelp.addUpdateResetAccount(1, dayLength: 7)
                {
                    (response) in
                    
                    
                    self.transactionsTable.reloadData()
                    self.spinner.stopAnimating()
                }
            

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
    

    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        
        if accounts.count > 0
        {
            let access_token =  keyChainStore.get("access_token")
            cHelp.addUpdateResetAccount(99, dayLength: 7) {
                (response) in
                self.transactionsTable.reloadData()
            }

        }
  
    }

  }



