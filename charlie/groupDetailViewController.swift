//
//  groupDetailViewController.swift
//  charlie
//
//  Created by James Caralis on 8/24/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import RealmSwift
import UIKit

class groupDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var sadButton: UIButton!
    
    
    @IBOutlet weak var happyButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var transactionCount: UILabel!
    @IBOutlet weak var happyPercentage: UILabel!
    
    var transactionName:String = ""
    var transactionItems = realm.objects(Transaction)
    var happyItems = realm.objects(Transaction)
    var sadItems = realm.objects(Transaction)
    var comingFromSad:Bool = false
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        
        
        
        
        
        
        
        
        self.name.text = transactionName
        
        var groupDetailPredicate = NSPredicate(format: "status > 0 AND name = %@", transactionName)
        
        let sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: true)]
        transactionItems = realm.objects(Transaction).filter(groupDetailPredicate).sorted(sortProperties)

        happyItems = transactionItems.filter("status = 1").sorted("date", ascending: true)
        sadItems = transactionItems.filter("status = 2").sorted("date", ascending: true)
        
        
        if transactionItems.count == 1
        { self.transactionCount.text = "\(transactionItems.count) transaction" }
        else
        { self.transactionCount.text = "\(transactionItems.count) transactions" }
       self.happyPercentage.text = "\(calculateHappy())%"
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        
        
        if comingFromSad
        {
            sadButton.tag = 1
            happyButton.tag = 0
            sadButton.backgroundColor = listRed
            happyButton.backgroundColor = UIColor.whiteColor()
            sadButton.tintColor = UIColor.whiteColor()
            happyButton.tintColor = listGreen
            setAttribText("NOT WORTH IT", message2: "sad", button: sadButton)
            setAttribText("WORTH IT", message2: "happy", button: happyButton)

        }
        else
        {
            sadButton.tag = 0
            happyButton.tag = 1
            sadButton.backgroundColor = UIColor.whiteColor()
            happyButton.backgroundColor = listGreen
            sadButton.tintColor = listRed
            happyButton.tintColor = UIColor.whiteColor()
            setAttribText("NOT WORTH IT", message2: "sad", button: sadButton)
            setAttribText("WORTH IT", message2: "happy", button: happyButton)
        }
        
        
        

        
        
        
        //tableView.reloadData()
    }
    
   func  setAttribText(message1:NSString, message2:NSString, button:UIButton)
    {
    
        
        button.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        var buttonText: NSString = "\(message1)\n\(message2)"

        //getting the range to separate the button title strings
        var newlineRange: NSRange = buttonText.rangeOfString("\n")
        
        //getting both substrings
        var substring1: NSString = ""
        var substring2: NSString = ""
        
        if(newlineRange.location != NSNotFound) {
            substring1 = buttonText.substringToIndex(newlineRange.location)
            substring2 = buttonText.substringFromIndex(newlineRange.location)
        }
        
        //assigning diffrent fonts to both substrings
        let font:UIFont? = UIFont(name: "Avenir Next", size: 17.0)
        let attrString = NSMutableAttributedString(
            string: substring1 as String,
            attributes: NSDictionary(
                object: font!,
                forKey: NSFontAttributeName) as [NSObject : AnyObject])
        
        let font1:UIFont? = UIFont(name: "Avenir Next", size: 11.0)
        let attrString1 = NSMutableAttributedString(
            string: substring2 as String,
            attributes: NSDictionary(
                object: font1!,
                forKey: NSFontAttributeName) as [NSObject : AnyObject])
        
        //appending both attributed strings
        attrString.appendAttributedString(attrString1)
        
        //assigning the resultant attributed strings to the button
        button.setAttributedTitle(attrString, forState: UIControlState.Normal)
        
    }
    
    
    func calculateHappy() -> Int
    {
        var happy = 0
        var sad = 0
        for trans in transactionItems
        {
            if trans.status == 1
            {   happy += 1 }
            if trans.status == 2
            {   sad += 1 }
        }
        
    return Int((Double(happy) / Double((happy + sad)) * 100))
    }
    
    
    
    
    
    
    
//table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sadButton.tag == 1
        {
            return sadItems.count
 
        }
        else if happyButton.tag == 1
        {
            return happyItems.count
        }
        else
        {  return happyItems.count }
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupDetailCell", forIndexPath: indexPath) as! groupDetailTableViewCell
        
        if sadButton.tag == 1
        {
            
            let dateString = cHelp.convertDateGroup(sadItems[indexPath.row].date)
            let currencyString = cHelp.formatCurrency(sadItems[indexPath.row].amount)
            cell.transactionDate.text = dateString
            cell.transactionAmount.text =  currencyString
        }
        else if happyButton.tag == 1
        {
            
            let dateString = cHelp.convertDateGroup(happyItems[indexPath.row].date)
            let currencyString = cHelp.formatCurrency(happyItems[indexPath.row].amount)
            cell.transactionDate.text = dateString
            cell.transactionAmount.text = currencyString

        }
        
        
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
       
       performSegueWithIdentifier("groupToDetail", sender: self)
       
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        
        if (segue.identifier == "groupToDetail") {
            let viewController = segue.destinationViewController as! showTransactionViewController
            //viewController.mainVC = self
            let indexPath = tableView.indexPathForSelectedRow()
            if happyButton.tag == 1
            {    viewController.transactionID = happyItems[indexPath!.row]._id }
            else
            {    viewController.transactionID = sadItems[indexPath!.row]._id }
            
            
        }
    }
    
    @IBAction func notWorthButtonPress(sender: UIButton) {
        
        
        sadButton.tag =  1
        happyButton.tag = 0
        sadButton.backgroundColor = listRed
        sadButton.tintColor = UIColor.whiteColor()
        happyButton.tintColor = listGreen
        happyButton.backgroundColor = UIColor.whiteColor()
        tableView.reloadData()
        
        
    }
    
    
    
    @IBAction func worthButtonPress(sender: UIButton) {
        
        sadButton.tag =  0
        happyButton.tag = 1
        sadButton.backgroundColor = UIColor.whiteColor()
        happyButton.backgroundColor = listGreen
        sadButton.tintColor = listRed
        happyButton.tintColor = UIColor.whiteColor()

        tableView.reloadData()

        
    }
    
    
//actions
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }


}
