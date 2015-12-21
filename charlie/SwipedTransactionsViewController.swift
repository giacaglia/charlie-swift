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
   
    @IBOutlet weak var tableView: UITableView!
    static let blackView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
    var filterType : SortFilterType! = .FilterByName
    let sortVC = SortViewController()

    var startDate:NSDate = NSDate()
    var endDate:NSDate = NSDate()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(frame: CGRectMake(0, 0, 27, 24))
        button.setBackgroundImage(UIImage(named: "btn_filter"), forState: .Normal)
        button.addTarget(self, action: "didTouchFilter:", forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.title = "Worth It?"
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissSort")
        SwipedTransactionsViewController.blackView.addGestureRecognizer(tapGesture)
        self.sortVC.delegate = self

        let monthFormatter = NSDateFormatter()
        monthFormatter.dateFormat = "MM"
        let stringMonth = monthFormatter.stringFromDate(self.startDate)
        monthLabel.text = "My \(months[Int(stringMonth)! - 1]) Spending"
        
        tableView.tableFooterView = UIView()
        tableView.registerClass(GroupTransactionCell.self, forCellReuseIdentifier: GroupTransactionCell.cellIdentifier())
        tableView.delegate = self
        tableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.loadData()
        self.tableView.reloadData()
    }
    
    func didTouchFilter(sender: AnyObject) {
        let topViewController = self.navigationController
        if topViewController == nil {
            return
        }
        self.sortVC.initialFilterType = self.filterType
        let height = self.view.frame.size.height*0.8
        self.sortVC.view.frame = CGRectMake(0, -height, self.view.frame.size.width, height)
        SwipedTransactionsViewController.blackView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        topViewController!.view.addSubview(SwipedTransactionsViewController.blackView)
        
        topViewController!.addChildViewController(sortVC)
        topViewController!.view.addSubview(sortVC.view)
        UIView.animateWithDuration(0.5) { () -> Void in
            self.sortVC.view.frame = CGRectMake(0, 0, self.sortVC.view.frame.width, height)
        }
    }
    
    func dismissSort() {
        self.sortVC.closePressed(self)
//        self.presentingViewController?.dismissViewControllerAnimated(<#T##flag: Bool##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
    }
    
}

extension SwipedTransactionsViewController {
    private func loadData() {
        charlieGroupListFiltered = [charlieGroup]()
        var current_name = ""

        let sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: true)]
        let predicate = NSPredicate(format: "date >= %@ and date <= %@", startDate, endDate)
        let actedUponItems = realm.objects(Transaction).filter(predicate).sorted(sortProperties)
        var current_index = 1
        
        for trans in actedUponItems {
            if trans.name == current_name {
                // Approved items
                if trans.status == 1 {
                    print("Worth IT \(current_index) - \(trans.name) \(trans.status)")
                    charlieGroupListFiltered[current_index].worthCount = charlieGroupListFiltered[current_index].worthCount + 1
                    charlieGroupListFiltered[current_index].worthValue = charlieGroupListFiltered[current_index].worthValue + trans.amount
                    charlieGroupListFiltered[current_index].happyPercentage = Int((Double(charlieGroupListFiltered[current_index].worthCount) / Double((charlieGroupListFiltered[current_index].transactions - charlieGroupListFiltered[current_index].notSwipedCount )) * 100))
                     charlieGroupListFiltered[current_index].totalAmount +=  trans.amount
                }
                // Flagged items
                else if trans.status == 2 {
                    print("NOT Worth IT \(current_index) - \(trans.name) \(trans.status)")
                    charlieGroupListFiltered[current_index].notWorthCount += 1
                    charlieGroupListFiltered[current_index].notWorthValue += trans.amount
                    charlieGroupListFiltered[current_index].happyPercentage = Int((Double(charlieGroupListFiltered[current_index].worthCount) / Double((charlieGroupListFiltered[current_index].transactions - charlieGroupListFiltered[current_index].notSwipedCount )) * 100))
                     charlieGroupListFiltered[current_index].totalAmount +=  trans.amount
                }
               else if trans.status  ==  -1 || trans.status ==  0 {
                    print("NOT SWIPED\(current_index) - \(trans.name) \(trans.status)")
                    charlieGroupListFiltered[current_index].notSwipedCount += 1
                    charlieGroupListFiltered[current_index].notSwipedValue += trans.amount
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
                    print("create new group: WORTH IT \(current_index) - \(trans.name) \(trans.status)")
                }
                else if trans.status == 2 {
                    cGroup.notWorthCount += 1
                    cGroup.notWorthValue += trans.amount
                    charlieGroupListFiltered.append((cGroup))
                    current_index = charlieGroupListFiltered.count - 1
                    print("create new group: NOT WORTH IT \(current_index) - \(trans.name) \(trans.status)")
                }
                else if trans.status ==  -1 || trans.status ==  0 {
                    cGroup.notSwipedCount += 1
                    cGroup.notSwipedValue += trans.amount
                    charlieGroupListFiltered.append((cGroup))
                    current_index = charlieGroupListFiltered.count - 1
                    print("create new group: NOT SWIPED \(current_index) - \(trans.name) \(trans.status)")
                }
                else {
                    // not added to the list
                }
                if cGroup.transactions - cGroup.notSwipedCount < 1 {
                    cGroup.happyPercentage = 0
                    cGroup.totalAmount = cGroup.totalAmount + trans.amount
                }
                else {
                    cGroup.happyPercentage = Int((Double(cGroup.worthCount) / Double((cGroup.transactions)) * 100))
                    cGroup.totalAmount = cGroup.totalAmount + trans.amount
                }
                
            }
            current_name = trans.name
        }
    }
}

extension SwipedTransactionsViewController : ChangeFilterProtocol {
    func removeBlackView() {
        SwipedTransactionsViewController.blackView.removeFromSuperview()
    }
    
    func changeFilter(filterType:SortFilterType){
        self.filterType = filterType
        self.filterBy(self.filterType)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            print("ROWCOUNT \(self.charlieGroupListFiltered.count)")

        })
        SwipedTransactionsViewController.blackView.removeFromSuperview()
    }
    
    func changeTransactionType(type: TransactionType) {
        self.filterBy(self.filterType)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
        SwipedTransactionsViewController.blackView.removeFromSuperview()
    }
    
    private func filterBy(sortFilter: SortFilterType) {
        if (sortFilter == .FilterByMostWorth) {
           self.charlieGroupListFiltered = self.charlieGroupListFiltered.sort {
                return $0.happyPercentage > $1.happyPercentage
            }
        }
        else if (sortFilter == .FilterByLeastWorth) {
            self.charlieGroupListFiltered = self.charlieGroupListFiltered.sort {

                return $0.happyPercentage < $1.happyPercentage
            }
        }

        else if (sortFilter == .FilterByAmount) {
            self.charlieGroupListFiltered = self.charlieGroupListFiltered.sort {

                return $0.totalAmount > $1.totalAmount
            }
        }
        
        else if (sortFilter == .FilterByName) {
            self.charlieGroupListFiltered = self.charlieGroupListFiltered.sort {

                return $0.name < $1.name
            }
        }
            
            
        else if (sortFilter == .FilterByDescendingDate) {
            self.charlieGroupListFiltered = self.charlieGroupListFiltered.sort {

                return $0.lastDate > $1.lastDate
            }
        }
        else if (sortFilter == .FilterByDate) {
            self.charlieGroupListFiltered = self.charlieGroupListFiltered.sort {

                return $0.lastDate < $1.lastDate
            }
        }
    }
}

extension SwipedTransactionsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier(GroupTransactionCell.cellIdentifier(), forIndexPath: indexPath) as! GroupTransactionCell
        let charlieGroup = charlieGroupListFiltered[indexPath.row]
       
        let attrsA = [NSFontAttributeName: UIFont(name: "Montserrat", size: 15.0)!, NSForegroundColorAttributeName: UIColor(white: 74.0/255.0, alpha: 1.0)]
        let a = NSMutableAttributedString(string:charlieGroup.name, attributes:attrsA)
        if charlieGroup.transactions == 1 {
            cell.nameLabel.attributedText = a
        }
        else {
            let attrsB = [NSFontAttributeName: UIFont(name: "Montserrat", size: 15.0)!, NSForegroundColorAttributeName: UIColor(white: 155.0/255.0, alpha: 1.0)]
            let b = NSAttributedString(string:" (\(charlieGroup.transactions))", attributes:attrsB)
            a.appendAttributedString(b)
            cell.nameLabel.attributedText = a
        }
        
        if (charlieGroup.transactions - charlieGroup.notSwipedCount) == 0 {
            cell.amountLabel.text = "-"
            cell.amountLabel.textColor = UIColor(white: 209.0/255.0, alpha: 1.0)
        }
        else {
            if charlieGroup.happyPercentage < 50 {
                cell.amountLabel.attributedText = NSAttributedString.createAttributedString(UIFont(name: "Montserrat-Light", size: 18.0)!, string1: "\(charlieGroup.happyPercentage)", color1: listRed, string2: "%", color2:UIColor(white: 209/255.0, alpha: 1.0))
            }
            else {
                cell.amountLabel.attributedText = NSAttributedString.createAttributedString(UIFont(name: "Montserrat-Light", size: 18.0)!, string1: "\(charlieGroup.happyPercentage)", color1: listGreen, string2: "%", color2:UIColor(white: 209/255.0, alpha: 1.0))
            }
        }
//        cell.dollarLabel.text = "\(cHelp.formatCurrency(charlieGroup.worthValue + charlieGroup.notWorthValue + charlieGroup.notSwipedValue ))"
        cell.dollarLabel.attributedText = NSAttributedString.createAttributedString(UIFont(name: "Montserrat-Light", size: 18.0)!, string1: "$", color1: UIColor(white: 209/255.0, alpha: 1.0), string2: (charlieGroup.worthValue + charlieGroup.notWorthValue + charlieGroup.notSwipedValue).format(".2"), color2: UIColor(white: 92/255.0, alpha: 1.0))
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charlieGroupListFiltered.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewControllerWithIdentifier("groupDetailViewController") as? groupDetailViewController else {
            return
        }
        
        viewController.startDate = self.startDate
        viewController.transactionName =  charlieGroupListFiltered[indexPath.row].name
        viewController.endDate = self.endDate
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 94
    }
}

class GroupTransactionCell : UITableViewCell {
    let nameLabel = UILabel()
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
        nameLabel.frame = CGRectMake(14, 39, 270, 20)
        nameLabel.font = UIFont(name: "Montserrat", size: 15.0)
        nameLabel.textColor = UIColor(white: 74.0/255.0, alpha: 1.0)
        nameLabel.textAlignment = .Left
        self.contentView.addSubview(nameLabel)
        
        dollarLabel.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 15 -  80, 26, 80, 18)
        dollarLabel.font = UIFont(name: "Montserrat-Light", size: 18.0)
        dollarLabel.textColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
        dollarLabel.textAlignment = .Right
        self.contentView.addSubview(dollarLabel)
        
        amountLabel.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 16 -  60, 50, 60, 18)
        amountLabel.font = UIFont(name: "Montserrat", size: 18.0)
        amountLabel.textAlignment = .Right
        self.contentView.addSubview(amountLabel)

    }
    
}