//
//  groupDetailViewController.swift
//  charlie
//
//  Created by James Caralis on 8/24/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import RealmSwift
import UIKit

class groupDetailViewController: UIViewController, UITableViewDataSource {

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sadButton.tag = 1
        happyButton.tag = 0
        
        self.name.text = transactionName
        
        var groupDetailPredicate = NSPredicate(format: "status > 0 AND name = %@", transactionName)
        
        let sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: true)]
        transactionItems = realm.objects(Transaction).filter(groupDetailPredicate).sorted(sortProperties)

        happyItems = transactionItems.filter("status = 1")
        sadItems = transactionItems.filter("status = 2")
        
        
        if transactionItems.count == 1
        { self.transactionCount.text = "\(transactionItems.count) transaction" }
        else
        { self.transactionCount.text = "\(transactionItems.count) transactions" }
       self.happyPercentage.text = "\(calculateHappy())%"
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //tableView.reloadData()
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
    return (happy / (happy + sad) * 100)
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
            cell.transactionDate.text = "\(sadItems[indexPath.row].date)"
            cell.transactionAmount.text =  "\(sadItems[indexPath.row].amount)"
        }
        else if happyButton.tag == 1
        {
            cell.transactionDate.text = "\(happyItems[indexPath.row].date)"
            cell.transactionAmount.text =  "\(happyItems[indexPath.row].amount)"

        }
        
        
        return cell
    }

    
    
    @IBAction func notWorthButtonPress(sender: UIButton) {
        
        
        sadButton.tag =  1
        happyButton.tag = 0
        tableView.reloadData()
        
        
    }
    
    
    
    @IBAction func worthButtonPress(sender: UIButton) {
        
        sadButton.tag =  0
        happyButton.tag = 1
        tableView.reloadData()

        
    }
    
    
//actions
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }


}
