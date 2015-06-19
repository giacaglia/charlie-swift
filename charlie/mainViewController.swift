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

var transactionItems = realm.objects(Transaction).filter("status = 0")


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
    
    //this is a test
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
     
       
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

        
        
        if accounts.count  == 0
        {
            addAccountButton.hidden = false
            transactionsTable.hidden = true
        }
            
        else
        {addAccountButton.hidden = true}
        
        
        inboxListButton.tag = 1 //set inbox to default
    
        
        removeCellBlockLeft = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            let indexPath = tableView.indexPathForCell(cell)
            if self.inboxListButton.tag == 1 || self.flagListButton.tag == 1
            {
                realm.beginWrite()
                transactionItems[indexPath!.row].status = 1 //approved
                realm.commitWrite()
                tableView.removeCell(cell, duration: 0.3, completion: nil)
                let transactionSum = self.sumTransactionsCount()
                let transactionSumCurrecnyFormat = self.formatCurrency(transactionSum)
                let finalFormat = self.stripCents(transactionSumCurrecnyFormat)
                self.moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
                
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
        
        performSegueWithIdentifier("segueFromMainToDetailView", sender: self)
        
    }
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let size = CGSizeMake(30, 30)
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SBGestureTableViewCell
        cell.firstLeftAction = SBGestureTableViewCellAction(icon: checkImage!, color: listGreen, fraction: 0.35, didTriggerBlock: removeCellBlockLeft)
        cell.firstRightAction = SBGestureTableViewCellAction(icon: flagImage!, color: listRed, fraction: 0.35, didTriggerBlock: removeCellBlockRight)
        cell.nameCellLabel.text = transactionItems[indexPath.row].name
        cell.amountCellLabel.text = formatCurrency(transactionItems[indexPath.row].amount)
        cell.dateCellLabel.text = transactionItems[indexPath.row].date
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
        

        
        println(transactionSum)
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
            let indexPath = self.transactionsTable.indexPathForSelectedRow()
            viewController.transactionIndex = indexPath!.row
            
            
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
    
        moneyCountSubHeadLabel.text = "Approved"
        
        let transactionSum = sumTransactionsCount()
        let transactionSumCurrecnyFormat = formatCurrency(transactionSum)
        let finalFormat = stripCents(transactionSumCurrecnyFormat)
        moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
        


        menuButton.setImage(menuButtonGreenImage, forState: .Normal)
        cardButton.setImage(cardButtonGreenImage, forState: .Normal)

    
        
    }
   
    
    
    @IBAction func inboxListButtonPress(sender: UIButton) {
        
        transactionItems = realm.objects(Transaction).filter("status = 0")
        transactionsTable.reloadData()
      
        
        inboxListButton.tag = 1
        inboxListButton.setImage(inboxSelectedButtonImage, forState: .Normal)
        topView.backgroundColor = listBlue
        dividerView.backgroundColor = listBlue
        moneyCountSubHeadLabel.text = "to aprrove"
        
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
        moneyCountSubHeadLabel.text = "Flagged"
        
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
                    
                    let transactions = response["transactions"] as! [NSDictionary]
                    realm.write {
                        // Save one Venue object (and dependents) for each element of the array
                        for transaction in transactions {
                            realm.create(Transaction.self, value: transaction, update: true)
                            println("saved")
                        }
                    }
                    let alert = UIAlertView()
                    alert.title = "Saved"
                    alert.message = "Yahoo!"
                    alert.addButtonWithTitle("Ok")
                   // alert.show()
                    self.addAccountButton.hidden = true
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

















