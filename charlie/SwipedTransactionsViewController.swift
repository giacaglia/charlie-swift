//
//  SwipedTransactions.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 11/23/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//

import Foundation
import RealmSwift

class SwipedTransactionsViewController : UIViewController {
    var charlieGroupListFiltered = [charlieGroup]()
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.loadData()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
       
       

    }
    
    override func viewDidLoad() {
       super.viewDidLoad()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        dateRangeLabel.text = "\(formatter.stringFromDate(NSDate().startOfMonth()!)) - \(formatter.stringFromDate(NSDate()))"

        let monthFormatter = NSDateFormatter()
        monthFormatter.dateFormat = "MM"
        let stringMonth = monthFormatter.stringFromDate(NSDate())
        monthLabel.text = months[Int(stringMonth)! - 1]
        
        //self.loadData()
        tableView.tableFooterView = UIView()
        tableView.registerClass(GroupTransactionCell.self, forCellReuseIdentifier: GroupTransactionCell.cellIdentifier())
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
}

extension SwipedTransactionsViewController {
    private func loadData() {
        var current_name = ""
        let sortProperties : Array<SortDescriptor>!
        
        sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: true)]
        let predicate = NSPredicate(format: "date >= %@ and date <= %@", NSDate().startOfMonth()!, NSDate())
        let actedUponItems = realm.objects(Transaction).filter(predicate).sorted(sortProperties)
        var current_index = 1
        
        for trans in actedUponItems {
            if trans.name == current_name {
                // Approved items
                if trans.status == 1 {
                    
                    print("Worth IT \(current_index) - \(trans.name)")
                    charlieGroupListFiltered[current_index].worthCount = charlieGroupListFiltered[current_index].worthCount + 1
                    charlieGroupListFiltered[current_index].worthValue = charlieGroupListFiltered[current_index].worthValue + trans.amount
                    
                          charlieGroupListFiltered[current_index].happyPercentage = Int((Double(charlieGroupListFiltered[current_index].worthCount) / Double((charlieGroupListFiltered[current_index].transactions - charlieGroupListFiltered[current_index].notSwipedCount )) * 100))
                    
                    
                     charlieGroupListFiltered[current_index].totalAmount +=  trans.amount
                    
                }
                // Flagged items
                else if trans.status == 2 {
                    
                     print("NOT Worth IT \(current_index) - \(trans.name)")
                    charlieGroupListFiltered[current_index].notWorthCount = charlieGroupListFiltered[current_index].notWorthCount + 1
                    charlieGroupListFiltered[current_index].notWorthValue = charlieGroupListFiltered[current_index].notWorthValue + trans.amount
                    
                          charlieGroupListFiltered[current_index].happyPercentage = Int((Double(charlieGroupListFiltered[current_index].worthCount) / Double((charlieGroupListFiltered[current_index].transactions - charlieGroupListFiltered[current_index].notSwipedCount )) * 100))
                    
                      charlieGroupListFiltered[current_index].totalAmount +=  trans.amount
                    
                    
                }
                
               else if trans.status  ==  -1 || trans.status ==  0
               {
                
                print("NOT SWIPED\(current_index) - \(trans.name)")

                 charlieGroupListFiltered[current_index].notSwipedCount += 1
                
                charlieGroupListFiltered[current_index].totalAmount +=  trans.amount
                
                }
                
          
                
              
                
            }
            else {                
                
                let cGroup = charlieGroup(name: trans.name, lastDate: String(trans.date))
                if trans.status == 1 {
                
                    
                    cGroup.worthCount += 1
                    cGroup.worthValue += trans.amount
                    charlieGroupListFiltered.append((cGroup))
                    current_index = charlieGroupListFiltered.count - 1
                    
                    print("create new group: WORTH IT \(current_index) - \(trans.name)")
                    
                }
                else if trans.status == 2 {
                   
                    cGroup.notWorthCount += 1
                    cGroup.notWorthValue += trans.amount
                    charlieGroupListFiltered.append((cGroup))
                    current_index = charlieGroupListFiltered.count - 1
                     print("create new group: NOT WORTH IT \(current_index) - \(trans.name)")
                }
                else if trans.status ==  -1 || trans.status ==  0
                {
                    
                    cGroup.notSwipedCount += 1
                    cGroup.notSwipedValue += trans.amount
                    charlieGroupListFiltered.append((cGroup))
                    current_index = charlieGroupListFiltered.count - 1
                    print("create new group: NOT SWIPED \(current_index) - \(trans.name)")

                }
                else {
                    // not added to the list
                }
                if cGroup.transactions - cGroup.notSwipedCount < 1 {
                    cGroup.happyPercentage = 0
                }
                else {
                    cGroup.happyPercentage = Int((Double(cGroup.worthCount) / Double((cGroup.transactions)) * 100))
                    cGroup.totalAmount = cGroup.totalAmount + trans.amount
                }
                
            }
            current_name = trans.name
            
        }
    }
    
    private func filterBy() {
//        if (sortFilter == .FilterByMostWorth) {
//            charlieGroupList.sortInPlace {
//                return $0.happyPercentage > $1.happyPercentage
//            }
//        }
//        else if (sortFilter == .FilterByLeastWorth) {
//            charlieGroupList.sortInPlace {
//                return $0.happyPercentage < $1.happyPercentage
//            }
//        }
//
//        else if (sortFilter == .FilterByAmount) {
//            charlieGroupList.sortInPlace {
//                return $0.totalAmount > $1.totalAmount
//            }
//        }
//
//        else if (sortFilter == .FilterByDescendingDate) {
//            charlieGroupList.sortInPlace {
//                return $0.lastDate > $1.lastDate
//            }
//        }
//        else if (sortFilter == .FilterByDate) {
//            charlieGroupList.sortInPlace {
//                return $0.lastDate < $1.lastDate
//            }
//        }
    }
}

extension SwipedTransactionsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier(GroupTransactionCell.cellIdentifier(), forIndexPath: indexPath) as! GroupTransactionCell
        let charlieGroup = charlieGroupListFiltered[indexPath.row]
        cell.nameLabel.text = charlieGroup.name

        if charlieGroup.transactions == 1 {
            cell.numberTransactionsLabel.text = "1 transaction"
        }
        else {
            cell.numberTransactionsLabel.text = "\(charlieGroup.transactions) transactions"
        }

        if (charlieGroup.transactions - charlieGroup.notSwipedCount) == 0
        {
           cell.dollarLabel.text = "?"
        }
        else
        {
        
           cell.dollarLabel.text = "\(charlieGroup.happyPercentage)%"
           if charlieGroup.happyPercentage < 50 {
               cell.dollarLabel.textColor = listRed
           }
           else {
                cell.dollarLabel.textColor = listGreen
            }

        }
        cell.amountLabel.textColor = UIColor.darkGrayColor()
        cell.amountLabel.text = "\(cHelp.formatCurrency(charlieGroup.worthValue + charlieGroup.notWorthValue + charlieGroup.notSwipedValue ))"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charlieGroupListFiltered.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("groupDetailViewController") as? groupDetailViewController
        viewController!.transactionName =  charlieGroupListFiltered[indexPath.row].name
        self.presentViewController(viewController!, animated: true) { () -> Void in }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 94
    }
}

class GroupTransactionCell : UITableViewCell {
    let nameLabel = UILabel()
    let numberTransactionsLabel = UILabel()
    let amountLabel = UILabel()
    let dollarLabel = UILabel()
    
    static func cellIdentifier() -> String {
        return "group_transaction_cell"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
        
    }
    
    private func setup() {
        nameLabel.frame = CGRectMake(14, 27, 270, 20)
        nameLabel.font = UIFont(name: "Montserrat", size: 15.0)
        nameLabel.textColor = UIColor(red: 116/255.0, green: 116/255.0, blue: 116/255.0, alpha: 1.0)
        nameLabel.textAlignment = .Left
        self.contentView.addSubview(nameLabel)
        
        numberTransactionsLabel.frame = CGRectMake(14, 49, 270, 18)
        numberTransactionsLabel.font = UIFont.systemFontOfSize(14.0)
        numberTransactionsLabel.textColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
        numberTransactionsLabel.textAlignment = .Left
        self.contentView.addSubview(numberTransactionsLabel)
        
        amountLabel.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 16 -  70, 27, 80, 18)
        amountLabel.font = UIFont.systemFontOfSize(14.0)
        amountLabel.textAlignment = .Right
        self.contentView.addSubview(amountLabel)
        
        dollarLabel.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 15 -  70, 49, 80, 18)
        dollarLabel.font = UIFont(name: "Montserrat-Bold", size: 15.0)
        dollarLabel.textColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
        dollarLabel.textAlignment = .Right
        self.contentView.addSubview(dollarLabel)
    }
    
}