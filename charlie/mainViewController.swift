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


//let date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitWeek, value: -1, toDate: NSDate(), options: nil)!

let date = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -10, toDate: NSDate(), options: nil)!
let status = 0


//let inboxPredicate = NSPredicate(format: "status = 0 AND date > %@", date)
//let approvedPredicate = NSPredicate(format: "status = 1 AND date > %@", date)
//let flaggedPredicate = NSPredicate(format: "status = 2 AND date > %@", date)


let inboxPredicate = NSPredicate(format: "status = 0")
let approvedPredicate = NSPredicate(format: "status = 1")
let flaggedPredicate = NSPredicate(format: "status = 2")



//let inboxPredicate = NSPredicate(format: "status = %i", status)
var transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
var allTransactionItems = realm.objects(Transaction)

class mainViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var transactionsTable: SBGestureTableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var approvedListButton: UIButton!
    @IBOutlet weak var inboxListButton: UIButton!
    @IBOutlet weak var flagListButton: UIButton!
    
    @IBOutlet weak var dividerView: UIView!
    
    
    @IBOutlet weak var sadRewardPercentage: UILabel!
    
    @IBOutlet weak var happyRewardPercentage: UILabel!
    
   
    @IBOutlet weak var topSeperator: UIView!
    @IBOutlet weak var listNavBar: UIView!
    
    @IBOutlet weak var moneyActionAmountLabel: UILabel!
    
    @IBOutlet weak var moneyActionDetailLabel: UILabel!
    
    
    
    @IBOutlet weak var rewardView: UIView!
    
    @IBOutlet weak var moneyCountLabel: UILabel!
    @IBOutlet weak var moneyCountSubHeadLabel: UILabel!
    
    
    @IBOutlet weak var moneySeperator: UIView!
   
    @IBOutlet weak var moneyCountSubSubHeadLabel: UILabel!
    
    @IBOutlet weak var addAccountButton: UIButton!
    
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var cardButton: UIButton!
    
    
    var cHelp = cHelper()
    
    var currentTransactionSwipeID = ""
    var currentTransactionCell:SBGestureTableViewCell!
 
    let checkImage = UIImage(named: "Wink-50")
    let flagImage = UIImage(named: "Sad-50")
    
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
    

    var blurEffect:UIBlurEffect!
    var blurEffectView:UIVisualEffectView!
    
    
   
    
    
    
    
    func hideReward()
    {
        rewardView.hidden = true
        transactionsTable.hidden = false
        
    }
    
    
    
    
    
    
    
    
    func showReward()
    {
        
    
        
        println("SHOW REWARD")
        
        rewardView.hidden = false
        transactionsTable.hidden = true
        
        var  transactionsHappy = realm.objects(Transaction).filter("status = 1")
        var  transactionsSad = realm.objects(Transaction).filter("status = 2")
        
        let totaltransaction = transactionsHappy.count + transactionsSad.count
        
        let happyPercentage = round((Double(transactionsHappy.count) / Double(totaltransaction)) * 100)
        let sadPercentage = round((Double(transactionsSad.count) / Double(totaltransaction)) * 100)
        
        println("HAPPY = \(happyPercentage)")
        println("SAD = \(sadPercentage)")
        
        happyRewardPercentage.text = "\(Int(happyPercentage))%"
        sadRewardPercentage.text = "\(Int(sadPercentage))%"
        
        var incomeSum:Double = 0.0
        var spendableSum:Double = 0.0
        var billsSum:Double = 0.0
        
        
//        for transaction in transactionItemsReward
//        {
//            if transaction.ctype == 1
//            {incomeSum +=  transaction.amount}
//            if transaction.ctype == 2
//            {spendableSum +=  transaction.amount}
//            if transaction.ctype == 3
//            {billsSum +=  transaction.amount}
//        }
//        
//        println("INCOME \(incomeSum)")
//        println("SPENDABLE \(spendableSum)")
//        println("BILLS \(billsSum)")

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      rewardView.hidden = true
      transactionsTable.hidden = false
        
     inboxListButton.tag =  1
        
      //download categories if don't exist
      let cats = realm.objects(Category)
      if cats.count == 0
      {
        
        cService.getCategories()
            {
                
                (responses) in
                
                for response in responses
                {
                    
                    var cat = Category()
                    var id:String = response["id"] as! String
                    var type:String = response["type"] as! String
                    cat.id = id
                    cat.type = type
                    let categories = ",".join(response["hierarchy"] as! Array)
                    cat.categories = categories
                    realm.write {
                        realm.add(cat, update: true)
                    }
              }
            }
        }
        
        
        
        transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
        

    
        blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds //view is self.view in a UIViewController
        view.addSubview(blurEffectView)

        //add auto layout constraints so that the blur fills the screen upon rotating device
        blurEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        
        blurEffectView.hidden = true
        
        let users = realm.objects(User)
        if users.count  == 0
        {
            // Create a Person object
            let user = User()
            user.email = "test@charlie.com"
            user.pin = "0000"
            user.password = "password"
            realm.write {
                realm.add(user, update: true)
            }
            
        }

        println(realm.path)
        
        if accounts.count  == 0
        {
            addAccountButton.hidden = false
            transactionsTable.hidden = true
        }
            
        else
        {
            addAccountButton.hidden = true
            
            if transactionItems.count == 0 && inboxListButton.tag ==  1
            {
                showReward()
            }
        }
        
        
        inboxListButton.tag = 1 //set inbox to default
        
        
        
        removeCellBlockLeft = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
        let indexPath = tableView.indexPathForCell(cell)
            let name = transactionItems[indexPath!.row].name
            if self.inboxListButton.tag == 1 || self.flagListButton.tag == 1
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
                
                
                if rowCount == 1
                {
                    println("show reward window")
                    self.showReward()
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
                realm.beginWrite()
                transactionItems[indexPath!.row].status = 2
                realm.commitWrite()
                tableView.removeCell(cell, duration: 0.3, completion: nil)
                let transactionSum = self.sumTransactionsCount()
                let transactionSumCurrecnyFormat = self.cHelp.formatCurrency(transactionSum)
                let finalFormat = self.stripCents(transactionSumCurrecnyFormat)
                self.moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
                
                
                var rowCount = Int(tableView.numberOfRowsInSection(0).value)
                
                
                if rowCount == 1
                {
                    println("show reward window")
                    self.showReward()
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
    
    
    
    func updateTrans() -> Void
    {
        println("looking for records")
        cHelp.addUpdateResetAccount(1, access_token: "dadasdasd")
            {
                
                (response) in
                println("added records")
                println(response)
                
                if response > 0
                {
                    self.timer.invalidate()
                    self.transactionsTable.reloadData()
                }
                
        }
    
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if accounts.count > 0 && allTransactionItems.count > 0
        {
           println("normal all is loaded")
        }
        else if accounts.count > 0 && allTransactionItems.count == 0
        {
            println("account but no transactions")
            timer = NSTimer.scheduledTimerWithTimeInterval(10, target:self, selector: Selector("updateTrans"), userInfo: nil, repeats: true)
            performSegueWithIdentifier("showTutorial", sender: self)
   
            
            
            
        }
        else if accounts.count == 0
        {
            println("First Time in or has never added an account")
        }
        
        
        transactionsTable.reloadData()
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transactionItems.count > 0
        {
            transactionsTable.hidden = false
            addAccountButton.hidden = true
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
         blurEffectView.hidden = false  

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
  
    func sumTransactionsCount( ) -> Double
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
            
            
           blurEffectView.hidden = false
         
            let viewController = segue.destinationViewController as! showTypePickerViewController
            //let indexPath = self.transactionsTable.indexPathForSelectedRow()
            viewController.transactionID = currentTransactionSwipeID
            viewController.transactionCell = currentTransactionCell
            viewController.mainVC = self

            
        }
    }
    
    
    
   
   

    @IBAction func showTutorial(sender: UIButton) {
        
          performSegueWithIdentifier("showTutorial", sender: self)
        
    }
   

    
    
   

    
    
    @IBAction func refreshAccounts(sender: UIButton) {
        
      
      if accounts.count > 0
        {
            let access_token = users[0].access_token
            spinner.startAnimating()
            cHelp.addUpdateResetAccount(99, access_token: access_token)
                {
                    (response) in
                    self.transactionsTable.reloadData()
                    self.spinner.stopAnimating()
                }
            

        }
        
        
    }
    
    
    @IBAction func approvedListButtonress(sender: UIButton) {
        
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
        moneySeperator.hidden =  true
        
        moneyActionAmountLabel.hidden = false
        moneyActionDetailLabel.hidden = false
        
        moneyActionAmountLabel.text = String(stringInterpolationSegment: finalFormat)
        moneyActionDetailLabel.text = "money well spent"

        

        //menuButton.setImage(menuButtonGreenImage, forState: .Normal)
        //cardButton.setImage(cardButtonGreenImage, forState: .Normal)

    
        
    }
   
    
    
    @IBAction func inboxListButtonPress(sender: UIButton) {
        
        transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
        
        if transactionItems.count == 0
        {
            showReward()
        }
        
            
           
            transactionsTable.reloadData()
          
            
            listNavBar.backgroundColor = listBlue
            
            moneyCountLabel.hidden = false
            moneyCountSubHeadLabel.hidden = false
            moneyCountSubSubHeadLabel.hidden = false
            moneySeperator.hidden =  false
            
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
        moneySeperator.hidden =  true
        
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
            let access_token = users[0].access_token
            cHelp.addUpdateResetAccount(99, access_token: access_token) {
                (response) in
                self.transactionsTable.reloadData()
            }

        }
  
    }

  }



