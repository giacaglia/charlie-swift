//
//  mainViewController.swift
//  charlie
//
//  Created by James Caralis on 6/7/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
//import BladeKit
import RealmSwift
import WebKit
import Charts

//number of days we show transaction data for
let showTransactionDays = NSCalendar.current.date(byAdding: .firstWeekday, value: -35, to: Date(), options: [])!
let status = 0
var inboxPredicate = NSPredicate() //items yet to be processed
var approvedPredicate = NSPredicate() // items marked as worth it
var flaggedPredicate = NSPredicate() // items makes as not worth it
var actedUponPredicate = NSPredicate() // items marked as either worth it or not worth it
var happyPredicate = NSPredicate()
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
    case approvedAndFlaggedTransaction, inboxTransaction
}

enum SortFilterType {
    case filterByName, filterByDate, filterByDescendingDate, filterByAmount, filterByMostWorth, filterByLeastWorth
}

enum ReportCardType : Int {
    case happyFlowType, cashFlowType, locationType
}

protocol ChangeFilterProtocol {
    func removeBlackView()
    func changeFilter( _ filterType: SortFilterType )
    func changeTransactionType( _ type : TransactionType)
}

protocol MainViewControllerDelegate {
    func hideCardsAndShowTransactions()
    func showCards()
}

class mainViewController: UIViewController, MainViewControllerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toastView: UIView!
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
    var timer = Timer()
    var timerCount:Int = 0
    var filterType : SortFilterType! = .filterByName
    var inboxType : TransactionType! = .approvedAndFlaggedTransaction
    static let blackView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    var areThereMoreItemsToLoad = false
    var numItemsToLoad = 20
    let inboxLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))

    var monthDiff:Int = 0

    func willEnterForeground(_ notification: Foundation.Notification!) {
        self.loadTransactionTable()
        self.collectionView.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
      
        //if accounts have been added but we don't have transactions that means plaid hasn't retreived transactions yet so check plaid until they have them every x seconds
        if accounts.count > 0 && allTransactionItems.count == 0 {
            if timerCount == 0 {
                //first time after adding account so show tutorial
                print("account but no transactions")
                timer = Timer.scheduledTimer(timeInterval: 10, target:self, selector: #selector(mainViewController.updateTrans), userInfo: nil, repeats: true)
                performSegue(withIdentifier: "showTutorial", sender: self)
                timerCount = 1
                SwiftLoader.show(true)
                toastView.isHidden = false
                accountAddView.isHidden = true
                collectionView.isHidden = false
            }
            else {
                print("Still waiting")
                //they finished tutorial and account has still not loaded - show something until data is loaded
            }
        }
       transactionsTable.reloadData()
    }
    
    
    func calculateReports() -> Void {
        //bad programming setting a local global... need to fix
        (totalCashFlow, changeCashFlow, totalSpending, changeSpending, totalIncome, changeIncome) = cHelp.getCashFlow(Date(), isCurrentMonth: true)
        (currentMonthHappyPercentage, happyFlowChange) =  cHelp.getHappyPercentageCompare(Date(), isCurrentMonth: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(mainViewController.willEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        self.setupNavigationBar()
        
        //get month range for transactions
        monthDiff = self.getMonthCountOfData()
        
        //get data for report cards
        self.calculateReports()
       
        self.addAccountButton.layer.cornerRadius = 25
        self.addAccountButton.layer.borderColor = UIColor.clear.cgColor
        self.addAccountButton.layer.borderWidth = 1.0
        
        self.loadTransactionTable()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.reloadData()
    }
    
    func setupNavigationBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 212/255.0, green: 212/255.0, blue: 212/255.0, alpha:
            1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : lightBlue]
        self.title = "Worth It?"
        var image = UIImage(named: "menu")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image!, style: .plain, target: self, action: #selector(mainViewController.showAccounts))
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let attributes = [
            NSForegroundColorAttributeName: lightBlue,
            NSFontAttributeName: UIFont(name: "Montserrat-Bold", size: 24)!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
    }
    
    
    func getMonthCountOfData() -> Int {
        let atCount =  allTransactionItems.count
        var monthReturn:Int = 0
        
        if atCount > 0 {
            let lastTrans = allTransactionItems[0].date as Date
            let firstTrans = allTransactionItems[atCount - 1].date  as Date
            
            let months = lastTrans.monthsFrom(firstTrans)
//            if months > 2 //if we have a bunch of months
//            {
//                monthReturn = lastTrans.monthsFrom(firstTrans)  - 1
//            }
//            else {
//                monthReturn = 1
//            }
                monthReturn = months
        
        }
        return monthReturn
    }
    
    func formatCurrency(_ currency: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        let numberFromField = currency
        return formatter.string(from: NSNumber(numberFromField))!
    }

    
    func showAccounts() {
        self.performSegue(withIdentifier: "showAccountsCards", sender: nil)
    }
   
    
    func loadTransactionTable() {
        transactionsTable.contentInset = UIEdgeInsetsZero
        self.automaticallyAdjustsScrollViewInsets = false
        
        // rewardView.hidden = true
        transactionsTable.isHidden = false
        inboxType = .inboxTransaction
        
        var access_token = ""
        if keyStore.string(forKey: "access_token") != nil {
            access_token = keyStore.string(forKey: "access_token")!
            keyChainStore.set(access_token, key: "access_token")
        }
        
        if accounts.count == 0 {
            setPredicates(false, startMonth: Date())
            accountAddView.isHidden = false
            addAccountButton.isHidden = false
            transactionsTable.isHidden = true
            collectionView.isHidden = true
            //makeOnlyFirstNElementsVisible()
            transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
            charlieAnalytics.track("Find Bank Screen - Main")
        }
        else {
            setPredicates(true, startMonth: Date())
            transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
            areThereMoreItemsToLoad = moreTransactionforLoading()
            addAccountButton.isHidden = true
            accountAddView.isHidden = true
            collectionView.isHidden = false
            //refresh accounts
            if allTransactionItems.count > 0 {
                let transCount = allTransactionItems.count
                let firstTransaction = allTransactionItems[transCount - 1].date as Date
                
                let lastTransaction = allTransactionItems[0].date as Date
                let calendar: NSCalendar = NSCalendar.current
                let flags = Calendar.firstWeekday
                let components = (calendar as NSCalendar).components(flags, from: lastTransaction, to: Date(), options: [])
                
                let transDateRangeComp = (calendar as NSCalendar).components(flags, from: firstTransaction, to: lastTransaction, options: [])
                
                
                var dateToSychTo = components.day
                
                let transDateRange = transDateRangeComp.day
                
                if transDateRange <  31
                {
                    dateToSychTo = 0 // we may still have some old transactions so do a full sync
                }
                
                SwiftLoader.show(true)
                print("DAYS \(dateToSychTo)")
                cHelp.addUpdateResetAccount(dayLength: dateToSychTo) { (response) in
                    self.transactionsTable.reloadData()
                    SwiftLoader.hide()
                }
            }
        }
        
        self.inboxType = .inboxTransaction //set inbox to default
        
        removeCellBlockLeft = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            if self.inboxType == .inboxTransaction {
                if defaults.string(forKey: "firstSwipeRight") == nil {
                    let refreshAlert = UIAlertController(title: "My Spending", message: "Tap on My Spending (bottom of the list) to view all your transactions for the current month.", preferredStyle: UIAlertControllerStyle.alert)
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
                        self.finishSwipe(tableView, cell: cell, direction: 1)
                        defaults.set("yes", forKey: "firstSwipeRight")
                        defaults.synchronize()
                    }))
                    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) in
                        tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
                    }))
                    self.present(refreshAlert, animated: true, completion: nil)
                }
                else {
                    self.finishSwipe(tableView, cell: cell, direction: 1)
                }
            }
            else {
                tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
            }
           
        }
        
        removeCellBlockRight = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            if  self.inboxType == .inboxTransaction {
                if defaults.string(forKey: "firstSwipeLeft") == nil {
                    let refreshAlert = UIAlertController(title: "Happy Flow", message: "Great job -  keep swiping your transactions to stay on top of purchases that were not worth it.", preferredStyle: UIAlertControllerStyle.alert)
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
                        self.finishSwipe(tableView, cell: cell, direction: 2)
                        defaults.set("yes", forKey: "firstSwipeLeft")
                        defaults.synchronize()
                    }))
                    
                    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) in
                        tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
                    }))
                    self.present(refreshAlert, animated: true, completion: nil)
                }
                else {
                    self.finishSwipe(tableView, cell: cell, direction: 2)
                }
            }
            else {
                tableView.replaceCell(cell, duration: 1.3, bounce: 1.0, completion: nil)
            }
          
        }
        
        transactionsTable.backgroundColor = UIColor.clear
        transactionsTable.register(AddMoreCell.self, forCellReuseIdentifier: AddMoreCell.cellIdentifier())
        transactionsTable.register(ReportCardCell.self, forCellReuseIdentifier:ReportCardCell.cellIdentifier())
        transactionsTable.tableFooterView = UIView()
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
    
    func setPredicates(_ hasAccounts:Bool, startMonth: Date) {
        let startDate = startMonth.startOfMonth()!
        let endDate = startMonth.endOfMonth()!
        
        inboxPredicate = NSPredicate(format: "(date >= %@ and date <= %@) and status = 0", startDate, endDate)
        happyPredicate = NSPredicate(format: "(date >= %@ and date <= %@) and status = 1 or status = 2", startDate, endDate)
        
        approvedPredicate = NSPredicate(format: "status = 1")
        actedUponPredicate = NSPredicate(format: "status = 1 OR status = 2")
        waitingToProcessPredicate = NSPredicate(format: "(date >= %@ and date <= %@) and status = -1", startDate, endDate)
    }
    
    func hideCardsAndShowTransactions() {
        self.present(SwipedTransactionsViewController(), animated: true) { () -> Void in}
    }
    
    func updateTrans() -> Void {
        print("looking for records")
        cHelp.addUpdateResetAccount(dayLength: 0) { (response) in
            charlieAnalytics.track("Account Transations Initial Sync Completed")
            
            print(response)
            if response > 0 {
                self.timer.invalidate()
                self.setPredicates(true, startMonth: Date())
                self.makeOnlyFirstNElementsVisible()
                transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
                allTransactionItems = realm.objects(Transaction).sorted("date", ascending: false)
               
                self.monthDiff = self.getMonthCountOfData()
                self.areThereMoreItemsToLoad = self.moreTransactionforLoading()
                
                self.calculateReports()
                
                DispatchQueue.main.async {
                    self.transactionsTable.reloadData()
                    self.collectionView.reloadData()
                }
                
                SwiftLoader.hide()
                self.toastView.isHidden = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "segueFromMainToDetailView") {
            let viewController = segue.destination as! showTransactionViewController
            viewController.mainVC = self
            let indexPath = self.transactionsTable.indexPathForSelectedRow
            viewController.transaction = transactionItems[(indexPath! as NSIndexPath).row]
            viewController.transactionIndex = (indexPath! as NSIndexPath).row
            viewController.sourceVC = "main"
        }
        else if (segue.identifier == "showTypePicker") {
            let viewController = segue.destination as! showTypePickerViewController
            viewController.transactionID = currentTransactionSwipeID
            viewController.transactionCell = currentTransactionCell
            viewController.mainVC = self
        }
        else if (segue.identifier == "showReveal") {
            let userSelectedHappyScore =  defaults.string(forKey: "userSelectedHappyScore")!
            let viewController = segue.destination as! revealViewController
            viewController.revealPercentage = "\(userSelectedHappyScore)"
        }
        else if (segue.identifier == "groupDetail") {
            let indexPath = self.transactionsTable.indexPathForSelectedRow
            let viewController = segue.destination as! GroupDetailViewController
            viewController.transactionName =  charlieGroupListFiltered[(indexPath! as NSIndexPath).row].name
        }
    }
    
    @IBAction func showTutorial(_ sender: UIButton) {
        //remove icloud
        keyStore.set("", forKey: "access_token")
        keyStore.set("", forKey: "email")
        keyStore.set("", forKey: "password")
        keyStore.synchronize()
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
        
        if loadCount > 0 {
            areThereMoreItemsToLoad =  true
        }
    }
    
   
    
    func showPastTransactions() {
        transactionItems = realm.objects(Transaction).filter(flaggedPredicate).sorted("date", ascending: false)
        //titleLabel.text = "My Results"
        inboxType = .approvedAndFlaggedTransaction
        charlieGroupListFiltered = groupBy(inboxType, sortFilter: filterType) as! [(charlieGroup)]
        transactionsTable.reloadData()
    }
    
    func groupBy(_ type: TransactionType, sortFilter: SortFilterType) -> NSArray {
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
                let cGroup = charlieGroup(name: trans.name, lastDate: trans.date)
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return monthDiff
        //TODO: REplace this back to monthDiff
        return 11
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! FilterCell
        let date = Date().dateByAddingMonths(-(indexPath as NSIndexPath).row)
        cell.monthLabel.text = date!.monthString()
        
        if selectedCollectioncCellIndex == (indexPath as NSIndexPath).row {
            cell.monthLabel.font = UIFont(name: "Montserrat-Bold", size: 18)!
        }
        else {
            cell.monthLabel.font = UIFont(name: "Montserrat-Light", size: 18)!
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCollectioncCellIndex = (indexPath as NSIndexPath).row
        let startMonth = Date().dateByAddingMonths(-selectedCollectioncCellIndex)!
        setPredicates(true, startMonth: startMonth)
        transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
        moreItems = realm.objects(Transaction).filter(waitingToProcessPredicate)
        if selectedCollectioncCellIndex == 0  {
            (totalCashFlow, changeCashFlow, totalSpending, changeSpending, totalIncome, changeIncome) = cHelp.getCashFlow(startMonth, isCurrentMonth: true)
            (currentMonthHappyPercentage, happyFlowChange) =  cHelp.getHappyPercentageCompare(startMonth, isCurrentMonth: true)
        }
        else {
            (totalCashFlow, changeCashFlow, totalSpending, changeSpending, totalIncome, changeIncome) = cHelp.getCashFlow(startMonth, isCurrentMonth: false)
            (currentMonthHappyPercentage, happyFlowChange) =  cHelp.getHappyPercentageCompare(startMonth, isCurrentMonth: false)
        }
        DispatchQueue.main.async {
            collectionView.reloadData()
            self.transactionsTable.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 50)
    }
    
}



// Swipe part of the main view controller
extension mainViewController : UITableViewDataSource, UITableViewDelegate {
    func finishSwipe(_ tableView: SBGestureTableView, cell: SBGestureTableViewCell, direction: Int) {
        let indexPath = tableView.indexPath(for: cell)
        let trans = transactionItems[(indexPath! as NSIndexPath).row]
        
        if trans.ctype == 0
        {
            let navigationVC = self.navigationController
            let categoryVC = CategoryViewController()
            categoryVC.trans = trans
            navigationVC!.addChildViewController(categoryVC)
            self.view.alpha = 0.0
            categoryVC.view.frame = self.view.frame
            UIView.animate(withDuration: 0.3) { () -> Void in
                self.navigationController!.view.addSubview(categoryVC.view)
                self.view.alpha = 1.0
            }
        }
        
        self.saveSwipeToServer(indexPath: indexPath!, direction: direction)
        self.updateTableAt(indexPath: indexPath!, direction: direction)
    }
    
    
    fileprivate func saveSwipeToServer(indexPath: IndexPath, direction: Int) {
        print("Saved Swipe: \(direction)")
        cService.saveSwipe(direction, transactionIndex: (indexPath as NSIndexPath).row)
            { (callback) in
            print("callback complete1")
        }
    }
    
    
    fileprivate func updateTableAt(indexPath: IndexPath, direction: Int) {
        currentTransactionSwipeID = transactionItems[(indexPath as NSIndexPath).row]._id
        let cell = transactionsTable.cellForRow(at: indexPath) as! SBGestureTableViewCell
        currentTransactionCell = cell
        
        realm.beginWrite()
        transactionItems[(indexPath as NSIndexPath).row].status = direction
        
        let startMonth = Date().dateByAddingMonths(-selectedCollectioncCellIndex)!
        transactionsTable.removeCell(cell, duration: 0.3) { () -> Void in
           var currentMonth = false
            
            if selectedCollectioncCellIndex  == 0
            {
                currentMonth = true
            }
            
            
            (self.currentMonthHappyPercentage, self.happyFlowChange) =  self.cHelp.getHappyPercentageCompare(startMonth, isCurrentMonth: currentMonth)
            self.transactionsTable.reloadRows(at: [IndexPath(row: transactionItems.count + 1, section: 0)], with: .none)
        }
        try! realm.commitWrite()
        
        if direction == 1 {
            charlieAnalytics.track("Worth It Swipe")
        }
        else {
            charlieAnalytics.track("Not Worth It Swipe")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transactionItems.count > 0 {
            transactionsTable.isHidden = false
            addAccountButton.isHidden = true
            accountAddView.isHidden = true
            collectionView.isHidden = false
        }
        return transactionItems.count + 5//Int(areThereMoreItemsToLoad)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var startDate:Date = Date()
        var endDate:Date = Date()
        //change
        if (indexPath as NSIndexPath).row < transactionItems.count {
            performSegue(withIdentifier: "segueFromMainToDetailView", sender: self)
        }
        else if (indexPath as NSIndexPath).row == transactionItems.count {
            if (indexPath as NSIndexPath).row == transactionItems.count {
                numItemsToLoad = 20
                
                //get current selected filter date
                let predicateDate = Date().dateByAddingMonths(-selectedCollectioncCellIndex)
                
                setPredicates(true, startMonth: predicateDate!)
                makeOnlyFirstNElementsVisible()
                transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
             //   self.setInboxTitle(true)
                transactionsTable.reloadData()
            }
        }
        else if (indexPath as NSIndexPath).row == transactionItems.count + 1 {
            return
        }
       
        else if (indexPath as NSIndexPath).row == transactionItems.count + 2 {
            print("Show Income")
            if selectedCollectioncCellIndex == 0 {
                startDate = Date().startOfMonth()!
                endDate = Date()
            }
            else
            {
                startDate = Date().dateByAddingMonths(-selectedCollectioncCellIndex)!.startOfMonth()!
                endDate = startDate.endOfMonth()!
            }
            
            let ITC = incomeTransactionsViewController()
            ITC.startDate = startDate
            ITC.endDate = endDate
            self.navigationController?.pushViewController(ITC, animated: true)
        }
        else if (indexPath as NSIndexPath).row == transactionItems.count + 3 {
            print("SHOW SPENDING")
            if selectedCollectioncCellIndex == 0 {
                startDate = Date().startOfMonth()!
                endDate = Date()
            }
            else {
                startDate = Date().dateByAddingMonths(-selectedCollectioncCellIndex)!.startOfMonth()!
                endDate = startDate.endOfMonth()!
            }
        
            let SVC = SwipedTransactionsViewController()
            SVC.startDate = startDate
            SVC.endDate = endDate

            self.navigationController?.pushViewController(SVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row >= transactionItems.count {
            let rewardIndex =  (indexPath as NSIndexPath).row - transactionItems.count
            var  rewardNames = ["Show More Transactions To Complete ", "Happy Flow", "My Income", "My Expenses", "My CashFlow"]
            var cellHappy:happyTableViewCell
            var cellReward:rewardTableViewCell
            
            if rewardIndex == 0
            {
                cellHappy = tableView.dequeueReusableCell(withIdentifier: "cellHappy", for: indexPath) as! happyTableViewCell
                if self.moreItems.count > 0 {
                    cellHappy.rewardName.text = "\(self.moreItems.count) left to swipe. Tap to load them and complete your happy flow!"
                }
                else {
                    cellHappy.rewardName.text = "All current transactions completed for your Happy Flow"
                }

                return cellHappy
            }
            else {
                cellReward = tableView.dequeueReusableCell(withIdentifier: "cellReward", for: indexPath) as! rewardTableViewCell
                cellReward.rewardName.text = rewardNames[rewardIndex].uppercased()
                cellReward.lineImageView.isHidden = false

                if rewardIndex == 1 {
                    if (currentMonthHappyPercentage.isNaN || currentMonthHappyPercentage.isInfinite) {
            
                        cellReward.rewardName.text = ""
                        cellReward.prevAmount.text = ""
                        cellReward.currentAmount.text = ""
                        cellReward.lineImageView.isHidden = true
                        cellReward.whiteArrow.isHidden = true
                        let aroundImageView = UIView(frame: CGRect(x: 10, y: 10, width: cellReward.frame.width - 20, height: cellReward.frame.height - 20))
                        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: aroundImageView.frame.width, height: aroundImageView.frame.height - 10))
                        imageView.contentMode = .scaleAspectFit
                        imageView.image = UIImage(named: "not_sure_happy_flow")
                        aroundImageView.addSubview(imageView)
                        cellReward.backgroundView = UIView()
                        cellReward.backgroundView!.addSubview(aroundImageView)
                        return cellReward
                    }
                    else {
                        cellReward.currentAmount.text = "\(Int(currentMonthHappyPercentage))%"
                    }
                    
                    if (happyFlowChange.isNaN || happyFlowChange.isInfinite) {
                        cellReward.prevAmount.text = ""
                    }
                    else {
                        cellReward.prevAmount.text = "\(Int(happyFlowChange))% from prev month"
                    }
                    
                    cellReward.whiteArrow.isHidden = true
                    let aroundImageView = UIView(frame: CGRect(x: 10, y: 10, width: cellReward.frame.width - 20, height: cellReward.frame.height - 20))
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: aroundImageView.frame.width, height: aroundImageView.frame.height - 10))             
                    
                    if happyFlowChange < 0 {
                        imageView.image = UIImage(named: "negative_2")
                        aroundImageView.backgroundColor = lightRed
                    }
                    else {
                        imageView.image = UIImage(named: "positiveIncome")
                        aroundImageView.backgroundColor = lightGreen
                       
                    }
                    cellReward.backgroundView = UIView()
                    aroundImageView.addSubview(imageView)
                    cellReward.backgroundView!.addSubview(aroundImageView)
                }
                if rewardIndex == 2 {
                    cellReward.currentAmount.attributedText = NSAttributedString.twoFontsAttributedString("$ ", font1: UIFont.systemFont(ofSize: 22.0), color1: UIColor(white: 1.0, alpha: 0.6), string2: totalIncome.commaFormatted(), font2: UIFont(name: "Montserrat-Bold", size: 42)!, color2: UIColor(white: 1.0, alpha: 1.0))
                    if (changeIncome.isNaN || changeIncome.isInfinite) {
                        cellReward.prevAmount.text = ""
                    }
                    else {
                        if changeIncome > 0 {
                            cellReward.prevAmount.text = "+" + changeIncome.commaFormatted() + " from prev month"
                        }
                        else {
                            cellReward.prevAmount.text = changeIncome.commaFormatted() + " from prev month"
                        }
                    }
                    
                    cellReward.whiteArrow.isHidden = false
                    let aroundImageView = UIView(frame: CGRect(x: 10, y: 10, width: cellReward.frame.width - 20, height: cellReward.frame.height - 20))
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: aroundImageView.frame.width, height: aroundImageView.frame.height - 10))
                    if changeIncome >= 0 {
                        imageView.image = UIImage(named: "positiveIncome")
                        aroundImageView.backgroundColor = lightGreen
                    }
                    else {
                        imageView.image = UIImage(named: "negativeSpending")
                        aroundImageView.backgroundColor = lightRed
                    }
                    cellReward.backgroundView = UIView()
                    aroundImageView.addSubview(imageView)
                    cellReward.backgroundView!.addSubview(aroundImageView)
                }
                
                if rewardIndex == 3 {
                    cellReward.currentAmount.attributedText = NSAttributedString.twoFontsAttributedString("$ ", font1: UIFont.systemFont(ofSize: 22.0), color1: UIColor(white: 1.0, alpha: 0.6), string2: totalSpending.commaFormatted(), font2: UIFont(name: "Montserrat-Bold", size: 42)!, color2: UIColor(white: 1.0, alpha: 1.0))
                    if (changeSpending.isNaN || changeSpending.isInfinite) {
                        cellReward.prevAmount.text = ""
                    }
                    else {
                        if changeSpending > 0 {
                             cellReward.prevAmount.text = "+" + changeSpending.commaFormatted() + " from prev month"
                        }
                        else {
                            cellReward.prevAmount.text = changeSpending.commaFormatted() + " from prev month"
                        }
                    }

                    cellReward.whiteArrow.isHidden = false
                    let aroundImageView = UIView(frame: CGRect(x: 10, y: 10, width: cellReward.frame.width - 20, height: cellReward.frame.height - 20))
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: aroundImageView.frame.width, height: aroundImageView.frame.height - 10))
                    if changeSpending < 0 {
                        imageView.image = UIImage(named: "positiveIncome")
                        aroundImageView.backgroundColor = lightGreen
                    }
                    else {
                        imageView.image = UIImage(named: "negativeSpending")
                        aroundImageView.backgroundColor = lightRed
                    }
                    cellReward.backgroundView = UIView()
                    aroundImageView.addSubview(imageView)
                    cellReward.backgroundView!.addSubview(aroundImageView)
                }
                if rewardIndex == 4 {
                    if (totalCashFlow < 0) {
                        cellReward.currentAmount.attributedText = NSAttributedString.twoFontsAttributedString("$", font1: UIFont.systemFont(ofSize: 22.0), color1: UIColor(white: 1.0, alpha: 0.6), string2: totalCashFlow.commaFormatted(), font2: UIFont(name: "Montserrat-Bold", size: 42)!, color2: UIColor(white: 1.0, alpha: 1.0))
                    }
                    else {
                        cellReward.currentAmount.attributedText = NSAttributedString.twoFontsAttributedString("+ ", font1: UIFont.systemFont(ofSize: 22.0), color1: UIColor(white: 1.0, alpha: 0.6), string2: totalCashFlow.commaFormatted(), font2: UIFont(name: "Montserrat-Bold", size: 42)!, color2: UIColor(white: 1.0, alpha: 1.0))
                    }
                    if (changeCashFlow.isNaN || changeCashFlow.isInfinite) {
                         cellReward.prevAmount.text = ""
                    }
                    else {
                        if changeCashFlow > 0 {
                            cellReward.prevAmount.text = "+" + changeCashFlow.commaFormatted() + " from prev month"
                        }
                        else {
                            cellReward.prevAmount.text = changeCashFlow.commaFormatted() + " from prev month"
                        }
                    }
                    
                    cellReward.whiteArrow.isHidden = true
                    let aroundImageView = UIView(frame: CGRect(x: 10, y: 10, width: cellReward.frame.width - 20, height: cellReward.frame.height - 20))
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: aroundImageView.frame.width, height: aroundImageView.frame.height - 10))
                    if changeCashFlow >= 0 {
                        imageView.image = UIImage(named: "positiveIncome")
                        aroundImageView.backgroundColor = lightGreen
                    }
                    else {
                        imageView.image = UIImage(named: "negativeSpending")
                        aroundImageView.backgroundColor = lightRed
                    }
                    cellReward.backgroundView = UIView()
                    aroundImageView.addSubview(imageView)
                    cellReward.backgroundView!.addSubview(aroundImageView)
                }
                cellReward.selectionStyle = UITableViewCellSelectionStyle.none
                return cellReward
           }
        }
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SBGestureTableViewCell
        let trans = transactionItems[(indexPath as NSIndexPath).row]
        cell.nameCellLabel.text = trans.name
        
        
        if trans.ctype == 86
        {
            cell.typeImageView.image = UIImage(named: "dont_count")
        }
        else if trans.ctype == 1
        {
            cell.typeImageView.image = UIImage(named: "blue_bills")
        }
        else if trans.ctype == 2
        {
            cell.typeImageView.image = UIImage(named: "blue_spending")
        }
        else if trans.ctype == 3
        {
            cell.typeImageView.image = UIImage(named: "blue_savings")
        }
        else
        {
            cell.typeImageView.image = UIImage(named: "blue_uncategorized")
        }
        

        cell.firstLeftAction = SBGestureTableViewCellAction(icon: UIImage(named: "happyFaceLeft")!, color: listGreen, fraction: 0.35, didTriggerBlock: removeCellBlockLeft)
        cell.firstRightAction = SBGestureTableViewCellAction(icon: UIImage(named: "sadFaceRight")!, color: listRed, fraction: 0.35, didTriggerBlock: removeCellBlockRight)
        
        cell.amountCellLabel.attributedText = NSAttributedString.createAttributedString(UIFont(name: "Montserrat", size: 22.0)!, string1: "-", color1: UIColor(white: 209/255.0, alpha: 1.0), string2: trans.amount.format(".2"), color2: listBlue)


        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE, MMM dd " //format style. Browse online to get a format that fits your needs.
        let dateString = dateFormatter.string(from: trans.date)
        cell.dateCellLabel.text = dateString.uppercased()
        cell.smallAmountCellLabel.isHidden = true
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rewardIndex =  (indexPath as NSIndexPath).row - transactionItems.count
        if rewardIndex > 0 {
            return 160
        }
        else {
            return 94
        }
    }
    
    
    func swipeCellAtIndex(_ transactionIndex: Int, toLeft: Bool) {
        let indexPath = IndexPath(row: transactionIndex, section: 0)
        if toLeft {
            self.updateTableAt(indexPath: indexPath, direction: 2)
        }
        else {
            let cell = self.transactionsTable.cellForRow(at: indexPath)
            cell!.center = CGPoint(x: cell!.center.x + 10, y: cell!.center.y)
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
    
    fileprivate func setup() {
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 70)
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
    
    fileprivate func setup() {
        self.contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 70)
        let centralLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        centralLabel.textAlignment = .center
        centralLabel.center = self.contentView.center
        centralLabel.text = "show more transactions"
        self.contentView.addSubview(centralLabel)
    }
}

extension mainViewController : UIViewControllerPreviewingDelegate {
    /// Called when the user has pressed a source view in a previewing view controller (Peek).
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        // Get indexPath for location (CGPoint) + cell (for sourceRect)
        guard let indexPath = transactionsTable.indexPathForRow(at: location) else { return nil }
        
        guard let showTransactionViewController = storyboard?.instantiateViewController(withIdentifier: "showTransactionViewController") as? showTransactionViewController else { return nil }
        showTransactionViewController.transaction = transactionItems[(indexPath as NSIndexPath).row]
        showTransactionViewController.transactionIndex = (indexPath as NSIndexPath).row
        showTransactionViewController.mainVC = self
        showTransactionViewController.sourceVC = "main"
        return showTransactionViewController
    }
    
    /// Called to let you prepare the presentation of a commit (Pop).
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Presents viewControllerToCommit in a primary context
        show(viewControllerToCommit, sender: self)
    }
}
