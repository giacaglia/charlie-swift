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
    var accounts = realm.objects(Account)
      
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if accounts.count > 0 {
            addAccountButton.enabled = false
        }
        cardsTableView.tableFooterView = UIView()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    //for test checkin
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! cardTableViewCell
        cell.cardView.layer.cornerRadius = 20
        cell.cardView.layer.borderColor = listBlue.CGColor
        cell.cardView.layer.borderWidth = 0.5
        if let current = accounts[indexPath.row].balance!.current.value
        {
            cell.cardBalance.text = String(stringInterpolationSegment: current)
        }
        else
        {
            cell.cardBalance.text = "n/a"
        }
        cell.cardName.text = accounts[indexPath.row].meta!.name
        cell.cardAccountNumber.text = accounts[indexPath.row].meta!.number
        cell.accountID.text = accounts[indexPath.row]._id
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    @IBAction func dismissViewButtonPress(sender: UIButton ) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func openLink(sender: UIButton) {
        if sender.tag == 0 {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.charliestudios.com/terms")!)
        }
        else {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.charliestudios.com/privacy")!)
        }
    }
    
}