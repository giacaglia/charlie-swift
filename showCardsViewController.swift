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
   
    
     let accounts = realm.objects(Account)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! cardTableViewCell
        
        cell.cardView.layer.cornerRadius = 20
        cell.cardView.layer.borderColor = listBlue.CGColor
        cell.cardView.layer.borderWidth = 0.5
        
        cell.cardBalance.text = String(stringInterpolationSegment: accounts[indexPath.row].balance.current)
        cell.cardName.text = accounts[indexPath.row].meta.name
        cell.cardAccountNumber.text = accounts[indexPath.row].meta.number
        
        
        return cell
    }

    
    
    
    @IBAction func dismissViewButtonPress(sender: UIButton ) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    
}
