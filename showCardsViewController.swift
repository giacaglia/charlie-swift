//
//  showCardsViewController.swift
//  charlie
//
//  Created by Jim Caralis on 6/22/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//


import UIKit
import Realm


class showCardsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
   
    @IBOutlet weak var cardsTableView: UITableView!
    
    
    @IBOutlet weak var addAccountButton: UIButton!
   
    
     let accounts = realm.objects(Account)
    
    
    
    
    func willEnterForeground(notification: NSNotification!) {
        
        
        if let resultController = storyboard!.instantiateViewControllerWithIdentifier("passcodeViewController") as? passcodeViewController {
            
            presentViewController(resultController, animated: true, completion: { () -> Void in
                
                self.view.viewWithTag(86)?.removeFromSuperview()
                
                
            })
        }
        
    }
    
    
    func didEnterBackgroundNotification(notification: NSNotification)
    {
        var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blur.frame = view.frame
        blur.tag = 86
        view.addSubview(blur)
    }
    
    

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackgroundNotification:", name: UIApplicationDidEnterBackgroundNotification, object: nil)

        
        if accounts.count > 0
        {
            
            addAccountButton.enabled = false
            
        }
        
    }
    
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! cardTableViewCell
        
        cell.cardView.layer.cornerRadius = 20
        cell.cardView.layer.borderColor = listBlue.CGColor
        cell.cardView.layer.borderWidth = 0.5
        
        cell.cardBalance.text = String(stringInterpolationSegment: accounts[indexPath.row].balance.available)
        cell.cardName.text = accounts[indexPath.row].meta.name
        cell.cardAccountNumber.text = accounts[indexPath.row].meta.number
        cell.accountID.text = accounts[indexPath.row]._id
        
        
        
        
        return cell
    }

    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            
            if let tv=tableView
            {
                
                var acctID = accounts[indexPath.row]._id
                var acct = accounts[indexPath.row]
                
                let transactionsToDeletePred = NSPredicate(format: "_account = %@", acctID)
                let transactions = realm.objects(Transaction).filter(transactionsToDeletePred)
                
                for transaction in transactions
                {
                    realm.write {
                        realm.delete(transaction)
                    }
                    
                }
                
                realm.write {
                    realm.delete(acct)
                }
                
                
                
                tv.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                
                
                
            }
        }
    
    }
    
    @IBAction func dismissViewButtonPress(sender: UIButton ) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    
}
