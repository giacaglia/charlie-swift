//
//  GroupDetailViewController.swift
//  charlie
//
//  Created by James Caralis on 8/24/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//
import RealmSwift
import UIKit

class GroupDetailViewController: UIViewController {
    @IBOutlet weak var groupTableView: SBGestureTableViewGroup!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var transactionCount: UILabel!
    @IBOutlet weak var happyPercentage: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    var transactionName:String = ""
    var transactionGroupItems = realm.objects(Transaction)
    var happyItems = realm.objects(Transaction)
    var comingFromSad = false
    
    var happyAmount = 0.0
    var sadAmount = 0.0
    
    var startDate:NSDate = NSDate()
    var endDate:NSDate = NSDate()
    
    var currentTransactionSwipeID = ""
    var currentTransactionCell:SBGestureTableViewGroupCell!
    let checkImage = UIImage(named: "happy_on")
    let flagImage = UIImage(named: "sad_on")
    
    var removeCellBlockLeft: ((SBGestureTableViewGroup, SBGestureTableViewGroupCell) -> Void)!
    var removeCellBlockRight: ((SBGestureTableViewGroup, SBGestureTableViewGroupCell) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()

        groupTableView.tableFooterView = UIView();

        
        let sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: false)]
        let predicate = NSPredicate(format: "date >= %@ and date <= %@ and name = %@", self.startDate, self.endDate, transactionName)
        transactionGroupItems = realm.objects(Transaction).filter(predicate).sorted(sortProperties)
        
        
        
        name.text = transactionName
        let transaction = transactionGroupItems[0]
        
        if let categories = transaction.categories {
            categoriesLabel.text = categories.categories
        }
        
        happyItems = transactionGroupItems.sorted("date", ascending: true)
        
        if transactionGroupItems.count == 1 {
            self.transactionCount.text = "\(transactionGroupItems.count) transaction"
        }
        else {
            self.transactionCount.text = "\(transactionGroupItems.count) transactions"
        }
    
        happyAmount = happyItems.sum("amount")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let happyPercentage = self.calculateHappy()
        if (happyPercentage >= 50) {
            self.happyPercentage.textColor = listGreen
        }
        else {
            self.happyPercentage.textColor = listRed
        }
        self.happyPercentage.text = "\(happyPercentage)%"

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
      
        self.groupTableView.reloadData()
    }
    
    
    func finishSwipe(tableView: SBGestureTableViewGroup, cell: SBGestureTableViewGroupCell, direction: Int) {
        let indexPath = tableView.indexPathForCell(cell)
        currentTransactionCell = cell
        print("Direction \(direction)")
        
        currentTransactionSwipeID = transactionGroupItems[indexPath!.row]._id
        realm.beginWrite()
        transactionGroupItems[indexPath!.row].status = direction
        tableView.removeCell(cell, duration: 0.3, completion: nil)
        try! realm.commitWrite()
        
        happyAmount = happyItems.sum("amount")
      
        self.happyPercentage.text = "\(self.calculateHappy())%"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "groupToDetail") {
            let viewController = segue.destinationViewController as! showTransactionViewController
            let indexPath = groupTableView.indexPathForSelectedRow
            viewController.transaction = transactionGroupItems[indexPath!.row]
            viewController.transactionIndex = indexPath!.row
            viewController.sourceVC = "happy"
        }
    }
    @IBAction func closeButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension GroupDetailViewController {
    func calculateHappy() -> Int {
        var happy = 0
        var sad = 0
        for trans in transactionGroupItems {
            if trans.status == 1 {
                happy += 1
            }
            if trans.status == 2 {
                sad += 1
            }
        }
        if happy + sad == 0 {
            return 0
        }
        return Int((Double(happy) / Double((happy + sad)) * 100))
    }
}

// TableView Methods
extension GroupDetailViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionGroupItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SBGestureTableViewGroupCell
        let trans = transactionGroupItems[indexPath.row]
        let dateString = cHelp.convertDateGroup(trans.date)
        let currencyString = cHelp.formatCurrency(trans.amount)
        cell.transactionDate.text = dateString
        cell.transactionAmount.text = currencyString
        if trans.status == 2 { cell.transactionAmount.textColor = listRed }
        else if trans.status == 1 { cell.transactionAmount.textColor = listGreen }
        else { cell.transactionAmount.textColor = mediumGray }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("groupToDetail", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
