//
//  mainViewController.swift
//  charlie
//
//  Created by James Caralis on 6/7/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
import BladeKit
import CoreData
import RealmSwift


let date = NSCalendar.currentCalendar().dateByAddingUnit(.MonthCalendarUnit, value: -1, toDate: NSDate(), options: nil)!
let status = 0
//let inboxPredicate = NSPredicate(format: "status = %i AND date > %@", status, date)
let inboxPredicate = NSPredicate(format: "status = %i", status)
var transactionItems = realm.objects(Transaction)


class mainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var transactionsTable: SBGestureTableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var approvedListButton: UIButton!
    @IBOutlet weak var inboxListButton: UIButton!
    @IBOutlet weak var flagListButton: UIButton!
    
    @IBOutlet weak var dividerView: UIView!
    
    @IBOutlet weak var moneyCountLabel: UILabel!
    @IBOutlet weak var moneyCountSubHeadLabel: UILabel!
    
    @IBOutlet weak var addAccountButton: UIButton!
    
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var cardButton: UIButton!
    
    
    var currentTransactionSwipeID = ""
    var currentTransactionCell:SBGestureTableViewCell!
 
    let checkImage = UIImage(named: "Checkmark-unselelected_small")
    let flagImage = UIImage(named: "Flag-unselelected_small")
    
    let inboxUnSelectedButtonImage = UIImage(named: "Inbox-unselelected")
    let inboxSelectedButtonImage = UIImage(named: "Inbox-selelected")

    let flagUnSelectedButtonImage = UIImage(named: "Flag-unselelected")
    let flagSelectedButtonImage = UIImage(named: "Flag-selelected")

    let approvedUnSelectedButtonImage = UIImage(named: "Checkmark-unselelected")
    let approvedSelectedButtonImage = UIImage(named: "Checkmark-selelected")


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
    
    
    var DynamicView=UIView(frame: UIScreen.mainScreen().bounds)
    
    //this is a test
    

    var blurEffect:UIBlurEffect!
    var blurEffectView:UIVisualEffectView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
        

    
        blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
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
            
            if transactionItems.count == 0
            {
                println("SHOW REWARD")
                
                var  transactionItemsReward = realm.objects(Transaction).filter("status = 1")
                
                var incomeSum:Double = 0.0
                var spendableSum:Double = 0.0
                var billsSum:Double = 0.0
                
                    
                for transaction in transactionItemsReward
                 {
                    if transaction.ctype == 1
                    {incomeSum +=  transaction.amount}
                    if transaction.ctype == 2
                    {spendableSum +=  transaction.amount}
                    if transaction.ctype == 3
                    {billsSum +=  transaction.amount}
                }
                
                println("INCOME \(incomeSum)")
                println("SPENDABLE \(spendableSum)")
                println("BILLS \(billsSum)")

            }
        }
        
        
        inboxListButton.tag = 1 //set inbox to default
        removeCellBlockLeft = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
        let indexPath = tableView.indexPathForCell(cell)
        if self.inboxListButton.tag == 1 || self.flagListButton.tag == 1
        {
            self.currentTransactionSwipeID = transactionItems[indexPath!.row]._id
            self.currentTransactionCell = cell
            if self.inboxListButton.tag == 1 && transactionItems[indexPath!.row].ctype == 0
                //only show reward or picker if in inbox
            {
                self.performSegueWithIdentifier("showTypePicker", sender: self)
            }
            else //already has a category just save and don't show list
            {
                realm.beginWrite()
                    transactionItems[indexPath!.row].status = 1
                realm.commitWrite()
                
                tableView.removeCell(cell, duration: 0.3, completion: nil)
                
                let transactionSum = self.sumTransactionsCount()
                let transactionSumCurrecnyFormat = self.formatCurrency(transactionSum)
                let finalFormat = self.stripCents(transactionSumCurrecnyFormat)
                self.moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
            }
        }
        else
        { tableView.reloadData() }
        
        }
       
        
        removeCellBlockRight = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            let indexPath = tableView.indexPathForCell(cell)
            if self.inboxListButton.tag == 1 || self.approvedListButton.tag == 1
            {
                realm.beginWrite()
                transactionItems[indexPath!.row].status = 2 //approved
                realm.commitWrite()
                tableView.removeCell(cell, duration: 0.3, completion: nil)
                let transactionSum = self.sumTransactionsCount()
                let transactionSumCurrecnyFormat = self.formatCurrency(transactionSum)
                let finalFormat = self.stripCents(transactionSumCurrecnyFormat)
                self.moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
                
                
                var rowCount = Int(tableView.numberOfRowsInSection(0).value)
                
                
                if rowCount == 1
                {
                    println("show reward window")
                }
            }
            else
            { tableView.reloadData() }
        }
        
        
        
        topView.backgroundColor = listBlue
        let transactionSum = sumTransactionsCount()
        let transactionSumCurrecnyFormat = formatCurrency(transactionSum)
        let finalFormat = stripCents(transactionSumCurrecnyFormat)
        moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
        
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        cell.amountCellLabel.text = formatCurrency(transactionItems[indexPath.row].amount)
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EE, MMMM dd " //format style. Browse online to get a format that fits your needs.
        var dateString = dateFormatter.stringFromDate(transactionItems[indexPath.row].date)
        cell.dateCellLabel.text = dateString
        //cell.selectionStyle = .None
       
        
        
            
         if transactionItems[indexPath.row].ctype ==  1
         {
            cell.categoryImageView.image = UIImage(contentsOfFile: "Money Bag-50")
         }
         else if transactionItems[indexPath.row].ctype ==  2
         {
             cell.categoryImageView.image = UIImage(named:"Expensive 2-50")
           
        }
         else if transactionItems[indexPath.row].ctype ==  3
         {
            cell.categoryImageView.image = UIImage(named:"Bill-50")
            
            }
         else if transactionItems[indexPath.row].ctype ==  4
         {
            cell.categoryImageView.image = UIImage(named:"Money Box-50")
         }
         else if transactionItems[indexPath.row].ctype ==  5
         {
            cell.categoryImageView.image = UIImage(named:"Money Transfer-50")
        }
         else if transactionItems[indexPath.row].ctype ==  0
         {
            cell.categoryImageView.image = nil
        }
        

            
        
        
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
    
    func formatCurrency(currency: Double) -> String
    {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        var numberFromField = currency
        return formatter.stringFromNumber(numberFromField)!
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
    
    
    
    func convertDate(date:String) -> NSDate
    {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.dateFromString(date)!
    }
    
    
    func cleanName(name:String) -> String{
        
        var stringlength = count(name)
        
        var ierror: NSError?
        var regex:NSRegularExpression = NSRegularExpression(pattern: ".*\\*", options: NSRegularExpressionOptions.CaseInsensitive, error: &ierror)!
        
        var regex2:NSRegularExpression = NSRegularExpression(pattern: "^[0-9]*", options: NSRegularExpressionOptions.CaseInsensitive, error: &ierror)!
        
        var modString = regex.stringByReplacingMatchesInString(name, options: nil, range: NSMakeRange(0, stringlength), withTemplate: "")
        
        var stringlength2 = count(modString)
        
        var modString2 = regex2.stringByReplacingMatchesInString(modString, options: nil, range: NSMakeRange(0, stringlength2), withTemplate: "")
        
        return modString2
        
    }
    
    
    @IBAction func refreshAccounts(sender: UIButton) {
        
        
       let access_token = users[0].access_token
        cService.updateAccount(access_token)
            {
              (response) in
                
                let accounts = response["accounts"] as! [NSDictionary]
                realm.write {
                    // Save one Venue object (and dependents) for each element of the array
                    for account in accounts {
                        realm.create(Account.self, value: account, update: true)
                        println("saved accounts")
                    }
                }
                
                let transactions = response["transactions"] as! [NSDictionary]
                realm.write {
                    // Save one Venue object (and dependents) for each element of the array
                    for transaction in transactions {
                        
                        
                        //convert string to date before insert
                        var dictDate = transaction.valueForKey("date") as? String
                        var modifiedDate = self.convertDate(dictDate!)
                        transaction.setValue(modifiedDate, forKey: "date")
                        
                        
                        realm.create(Transaction.self, value: transaction, update: true)
                        println("saved transactions")
                    }
                }
                
                
                //run through transactions and see if they can be preliminarly categorized
                
                
                
                
                
                
                
                transactionItems = realm.objects(Transaction).filter(inboxPredicate)
                self.transactionsTable.reloadData()
                
                
            }

        
        
        
        
        
    }
    
    
    @IBAction func approvedListButtonress(sender: UIButton) {
        
        transactionItems = realm.objects(Transaction).filter("status = 1")
        transactionsTable.reloadData()

        
        inboxListButton.tag = 0
        inboxListButton.setImage(inboxUnSelectedButtonImage, forState: .Normal)
        
        flagListButton.tag = 0
        flagListButton.setImage(flagUnSelectedButtonImage, forState: .Normal)
        
        
        approvedListButton.tag = 1
        approvedListButton.setImage(approvedSelectedButtonImage, forState: .Normal)
        dividerView.backgroundColor = listGreen
        topView.backgroundColor = listGreen
    
        moneyCountSubHeadLabel.text = "cleared"
        
        let transactionSum = sumTransactionsCount()
        let transactionSumCurrecnyFormat = formatCurrency(transactionSum)
        let finalFormat = stripCents(transactionSumCurrecnyFormat)
        moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
        


        menuButton.setImage(menuButtonGreenImage, forState: .Normal)
        cardButton.setImage(cardButtonGreenImage, forState: .Normal)

    
        
    }
   
    
    
    @IBAction func inboxListButtonPress(sender: UIButton) {
        
        transactionItems = realm.objects(Transaction).filter(inboxPredicate)
        transactionsTable.reloadData()
      
        
        inboxListButton.tag = 1
        inboxListButton.setImage(inboxSelectedButtonImage, forState: .Normal)
        topView.backgroundColor = listBlue
        dividerView.backgroundColor = listBlue
        moneyCountSubHeadLabel.text = "to clear"
        
        let transactionSum = sumTransactionsCount()
        let transactionSumCurrecnyFormat = formatCurrency(transactionSum)
        let finalFormat = stripCents(transactionSumCurrecnyFormat)
        moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
        

        
        flagListButton.tag = 0
        flagListButton.setImage(flagUnSelectedButtonImage, forState: .Normal)
        
        
        approvedListButton.tag = 0
        approvedListButton.setImage(approvedUnSelectedButtonImage, forState: .Normal)
        
        menuButton.setImage(menuButtonBlueImage, forState: .Normal)
        cardButton.setImage(cardButtonBlueImage, forState: .Normal)
        
        
        
    }
    
    
    @IBAction func flagListButtonPress(sender: UIButton) {

        transactionItems = realm.objects(Transaction).filter("status = 2")
        transactionsTable.reloadData()
    
        
        inboxListButton.tag = 0
        inboxListButton.setImage(inboxUnSelectedButtonImage, forState: .Normal)
        
        flagListButton.tag = 1
        flagListButton.setImage(flagSelectedButtonImage, forState: .Normal)
        topView.backgroundColor = listRed
        dividerView.backgroundColor = listRed
        moneyCountSubHeadLabel.text = "to resolve"
        
        let transactionSum = sumTransactionsCount()
        let transactionSumCurrecnyFormat = formatCurrency(transactionSum)
        let finalFormat = stripCents(transactionSumCurrecnyFormat)
        moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
        
        
        approvedListButton.tag = 0
        approvedListButton.setImage(approvedUnSelectedButtonImage, forState: .Normal)
        
        menuButton.setImage(menuButtonRedImage, forState: .Normal)
        cardButton.setImage(cardButtonRedImage, forState: .Normal)

        
    }
    
    
   
  
    @IBAction func addCard(sender: UIButton) {
        
        
        
        cService.addAccount("plaid_test", password: "plaid_good", bank: "wells")
            {
                (response) in
                self.transactionsTable.reloadData()
                if response.objectForKey("mfa") != nil
                {
                    //need to use MFA
                    println("NEED MFA")
                }
                else
                {
                    println("NO MFA - save access token")
                    realm.beginWrite()
                    self.users[0].access_token = response.objectForKey("access_token") as! String
                    realm.commitWrite()
                    let accounts = response["accounts"] as! [NSDictionary]
                    realm.write {
                        // Save one Venue object (and dependents) for each element of the array
                        for account in accounts {
                            realm.create(Account.self, value: account, update: true)
                            println("saved")
                        }
                    }
                    
                    var transactions = response["transactions"] as! [NSDictionary]
                    realm.write {
                        // Save one Venue object (and dependents) for each element of the array
                        for transaction in transactions {
                            println("saved")
                            //clean up name
                            var dictName = transaction.valueForKey("name") as? String
                            transaction.setValue(self.cleanName(dictName!), forKey: "name")
                            //convert string to date before insert
                            var dictDate = transaction.valueForKey("date") as? String
                            transaction.setValue(self.convertDate(dictDate!), forKey: "date")
                            realm.create(Transaction.self, value: transaction, update: true)
                            
                        }
                    }
                    
                    self.addAccountButton.hidden = true
                    transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
                    self.transactionsTable.reloadData()
                    let transactionSum = self.sumTransactionsCount()
                    let transactionSumCurrecnyFormat = self.formatCurrency(transactionSum)
                    let finalFormat = self.stripCents(transactionSumCurrecnyFormat)
                    self.moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
                    self.transactionsTable.hidden = false
                    
                    
                    
                }
                
        }
    }
    
    func MFA(response:NSDictionary, callback: NSDictionary->())
    {
        
        let access_token = response.objectForKey("access_token") as! String
        let question = "Test question"
        
        //1. Create the alert controller.
        var alert = UIAlertController(title: "Security Question", message: "You say tomato", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
            
            
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            
            
            cService.submitMFA(access_token, mfa_response: textField.text)
                {
                    
                    (responseMFA) in
                    
                    
                    if responseMFA.objectForKey("accounts") != nil
                    {
                        println("Yahoooo")
                        let accounts = response["accounts"] as! [NSDictionary]
                        realm.write {
                            // Save one Venue object (and dependents) for each element of the array
                            for account in accounts {
                                realm.create(Account.self, value: account, update: true)
                                println("saved")
                            }
                        }
                        
                        let transactions = response["transactions"] as! [NSDictionary]
                        realm.write {
                            // Save one Venue object (and dependents) for each element of the array
                            for transaction in transactions {
                                realm.create(Transaction.self, value: transaction, update: true)
                                println("saved")
                            }
                        }
                        
                    }
                    
                    
                    callback(responseMFA as NSDictionary)
                    
                    
            }
            
            
            println("Text field: \(textField.text)")
        }))
        
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        
        
    }
    
    
}

















