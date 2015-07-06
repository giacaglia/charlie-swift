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

let date = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -30x  , toDate: NSDate(), options: nil)!
let status = 0
let inboxPredicate = NSPredicate(format: "status = %i AND date > %@", status, date)
//let inboxPredicate = NSPredicate(format: "status = %i", status)
var transactionItems = realm.objects(Transaction)


class mainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, WKScriptMessageHandler {
    
    @IBOutlet weak var transactionsTable: SBGestureTableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var approvedListButton: UIButton!
    @IBOutlet weak var inboxListButton: UIButton!
    @IBOutlet weak var flagListButton: UIButton!
    
    @IBOutlet weak var dividerView: UIView!
    
   
    @IBOutlet weak var moneyActionAmountLabel: UILabel!
    
    @IBOutlet weak var moneyActionDetailLabel: UILabel!
    
    
    
    
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
    
    let inboxUnSelectedButtonImage = UIImage(named: "Neutral-Gray-50")
    let inboxSelectedButtonImage = UIImage(named: "Neutral-50-Blue")

    let flagUnSelectedButtonImage = UIImage(named: "Sad-50-Gray")
    let flagSelectedButtonImage = UIImage(named: "Sad-50-Red")

    let approvedUnSelectedButtonImage = UIImage(named: "Wink-Gray-50")
    let approvedSelectedButtonImage = UIImage(named: "Wink-Yellow-50")


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
            {
                realm.beginWrite()
                    transactionItems[indexPath!.row].status = 1
                realm.commitWrite()
                
               

                let predicate = NSPredicate(format: "name = %@", transactionItems[indexPath!.row].name )
                var sameTransactions = realm.objects(Transaction).filter(predicate)
                if sameTransactions.count > 10
                {
                    for trans in sameTransactions
                    {
                        realm.beginWrite()
                        trans.status = 1
                        realm.commitWrite()
                    }
                    
                    transactionItems = realm.objects(Transaction).filter(inboxPredicate)
                    self.transactionsTable.reloadData()
                }
                else
                {
                    tableView.removeCell(cell, duration: 0.3, completion: nil)
                }
                
                let transactionSum = self.sumTransactionsCount()
                let transactionSumCurrecnyFormat = self.cHelp.formatCurrency(transactionSum)
                let finalFormat = self.stripCents(transactionSumCurrecnyFormat)
                self.moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
                
                
    
        }
        else
        { tableView.reloadData() }
        
        }
            
            
            
            
        
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
                let transactionSumCurrecnyFormat = self.cHelp.formatCurrency(transactionSum)
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
        
        
        
        topView.backgroundColor = UIColor.whiteColor()
        let transactionSum = sumTransactionsCount()
        let transactionSumCurrecnyFormat = cHelp.formatCurrency(transactionSum)
        let finalFormat = stripCents(transactionSumCurrecnyFormat)
        moneyCountLabel.text = String(stringInterpolationSegment: finalFormat)
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if accounts.count > 0 && transactionItems.count > 0
        {
           println("normal all is loaded")
        }
        else if accounts.count > 0 && transactionItems.count == 0
        {
                     println("account but no transactions")
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
    
    
    
   
    
    @IBAction func addAccountWeb(sender: UIButton) {
        
        var filePath = NSBundle.mainBundle().pathForResource("plaid", ofType: "html")
        filePath = cHelp.pathForBuggyWKWebView(filePath) // This is the reason of this entire thread!
        let req = NSURLRequest(URL: NSURL.fileURLWithPath(filePath!)!)
        
        var webView: WKWebView?
        var contentController = WKUserContentController();

        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        
        var config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(
            frame: self.view.bounds,
            configuration: config
        )
        
         self.view.addSubview(webView!)

    
        webView?.sizeToFit()
        webView!.loadRequest(req)
        
        
    }
    

   

    
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            println("JavaScript is sending a message \(message.body)")
            
            //get access_token
            
            var public_token = message.body as! String
            
            if public_token == "exit"
            {
              println("Exit")
            
            }
            else
            {
            
            cService.getAccessToken(public_token)
                {
                    (response) in
                    var access_token = response["access_token"] as! String
                    realm.beginWrite()
                    self.users[0].access_token = access_token
                    realm.commitWrite()
                    
                    
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
                                    var modifiedDate =  self.cHelp.convertDate(dictDate!)
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
            
            }
        }
    }

    
    func webViewDidFinishLoad(webView: UIWebView) {
        let href = webView.stringByEvaluatingJavaScriptFromString("window.location.href")
        println("window.location.href  = \(href)")
        
    }
    
    
    @IBAction func refreshAccounts(sender: UIButton) {
        
      
      if accounts.count > 0
      {
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
                        var modifiedDate = self.cHelp.convertDate(dictDate!)
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
    
        moneyCountSubHeadLabel.text = "Worth it!"
        
        let transactionSum = sumTransactionsCount()
        let transactionSumCurrecnyFormat = cHelp.formatCurrency(transactionSum)
        let finalFormat = stripCents(transactionSumCurrecnyFormat)
       
        
        
        moneyCountLabel.hidden = true
        moneyCountSubHeadLabel.hidden = true
        moneyCountSubSubHeadLabel.hidden = true
        moneySeperator.hidden =  true
        
        moneyActionAmountLabel.hidden = false
        moneyActionDetailLabel.hidden = false
        
        moneyActionAmountLabel.text = String(stringInterpolationSegment: finalFormat)
        moneyActionDetailLabel.text = "money well spent"

        

        menuButton.setImage(menuButtonGreenImage, forState: .Normal)
        cardButton.setImage(cardButtonGreenImage, forState: .Normal)

    
        
    }
   
    
    
    @IBAction func inboxListButtonPress(sender: UIButton) {
        
        transactionItems = realm.objects(Transaction).filter(inboxPredicate).sorted("date", ascending: false)
        transactionsTable.reloadData()
      
        
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

        
        moneyActionAmountLabel.text = String(stringInterpolationSegment: finalFormat)
        moneyActionDetailLabel.text = "could've spent better"
        
        
        approvedListButton.tag = 0
        approvedListButton.setImage(approvedUnSelectedButtonImage, forState: .Normal)
        
        menuButton.setImage(menuButtonRedImage, forState: .Normal)
        cardButton.setImage(cardButtonRedImage, forState: .Normal)

        
    }
    
    
   
  
    @IBAction func addCard(sender: UIButton) {
        
        
     
        var filePath = NSBundle.mainBundle().pathForResource("plaid", ofType: "html")
        filePath = cHelp.pathForBuggyWKWebView(filePath) // This is the reason of this entire thread!
        let req = NSURLRequest(URL: NSURL.fileURLWithPath(filePath!)!)
        
        var webView: WKWebView?
        var contentController = WKUserContentController();
        
        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        
        var config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(
            frame: self.view.bounds,
            configuration: config
        )
        self.view = webView!
        
        webView?.sizeToFit()
        webView!.loadRequest(req)
        
        
        
        
        /*
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
                        // Save one Venue object (and dependents) for each element of the array
                        for transaction in transactions {
                            println("saved")
                           
                            realm.write {
                            
                            //clean up name
                            var dictName = transaction.valueForKey("name") as? String
                            transaction.setValue(self.cleanName(dictName!), forKey: "name")
                            
                            println(dictName)
                            
                            //convert string to date before insert
                            var dictDate = transaction.valueForKey("date") as? String
                            transaction.setValue(self.convertDate(dictDate!), forKey: "date")
                            
                            
                            //add category
                            if let category_id = transaction.valueForKey("category_id") as? String
                            {
                                let predicate = NSPredicate(format: "id = %@", category_id)
                                var categoryToAdd = realm.objects(Category).filter(predicate)
                                var newTrans =  realm.create(Transaction.self, value: transaction, update: true)
                                newTrans.categories = categoryToAdd[0]
                            }
                             else
                            {
                                var newTrans =  realm.create(Transaction.self, value: transaction, update: true)
                                
                            }
                            
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
        */
        
        
        
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

















