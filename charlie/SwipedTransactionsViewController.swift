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
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
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
        
        let actedUponItems = realm.objects(Transaction).filter(actedUponPredicate).sorted(sortProperties)
        var current_index = 0
        
        for trans in actedUponItems {
            print(trans.name)
            if trans.name == current_name {
                // Approved items
                if trans.status == 1 {
                    charlieGroupListFiltered[current_index].worthCount = charlieGroupListFiltered[current_index].worthCount + 1
                    charlieGroupListFiltered[current_index].worthValue = charlieGroupListFiltered[current_index].worthValue + trans.amount
                }
                    // Flagged items
                else if trans.status == 2 {
                    charlieGroupListFiltered[current_index].notWorthCount = charlieGroupListFiltered[current_index].notWorthCount + 1
                    charlieGroupListFiltered[current_index].notWorthValue = charlieGroupListFiltered[current_index].notWorthValue + trans.amount
                }
                
                charlieGroupListFiltered[current_index].happyPercentage = Int((Double(charlieGroupListFiltered[current_index].worthCount) / Double((charlieGroupListFiltered[current_index].transactions)) * 100))
                
                charlieGroupListFiltered[current_index].totalAmount +=  trans.amount
                
            }
            else {
                
                
                print("create new group: \(trans.name)")
                let cGroup = charlieGroup(name: trans.name, lastDate: String(trans.date))
                if trans.status == 1 {
                    cGroup.worthCount += 1
                    cGroup.worthValue += trans.amount
                    charlieGroupListFiltered.append((cGroup))
                    current_index = charlieGroupListFiltered.count - 1
                }
                else if trans.status == 2 {
                    cGroup.notWorthCount += 1
                    cGroup.notWorthValue += trans.amount
                    charlieGroupListFiltered.append((cGroup))
                    current_index = charlieGroupListFiltered.count - 1
                }
                else {
                    // not added to the list
                }
                if cGroup.transactions == 0 {
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

        cell.amountLabel.text = "\(charlieGroup.happyPercentage)%"
        if charlieGroup.happyPercentage < 50 {
            cell.amountLabel.textColor = listRed
        }
        else {
            cell.amountLabel.textColor = listGreen
        }

        cell.dollarLabel.text = "\(cHelp.formatCurrency(charlieGroup.worthValue + charlieGroup.notWorthValue))"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charlieGroupListFiltered.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        performSegueWithIdentifier("groupDetail", sender: indexPath)
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
        
        amountLabel.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 16 -  40, 27, 40, 18)
        amountLabel.font = UIFont(name: "Montserrat-Bold", size: 15.0)
        amountLabel.textAlignment = .Right
        self.contentView.addSubview(amountLabel)
        
        dollarLabel.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 15 -  70, 49, 70, 18)
        dollarLabel.font = UIFont.systemFontOfSize(14.0)
        dollarLabel.textColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
        dollarLabel.textAlignment = .Right
        self.contentView.addSubview(dollarLabel)
    }
    
}