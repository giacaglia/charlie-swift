//
//  incomeTransactionsViewController.swift
//  charlie
//
//  Created by James Caralis on 12/7/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//
import Foundation
import RealmSwift

class incomeTransactionsViewController : UIViewController {
    @IBOutlet weak var tableView: UITableView!
   
   
      let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    @IBOutlet weak var monthLabel: UILabel!
    var startDate:NSDate = NSDate()
    var endDate:NSDate = NSDate()
    var incomeItems = realm.objects(Transaction)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Worth It?"
        
        loadData()
        
        let monthFormatter = NSDateFormatter()
        monthFormatter.dateFormat = "MM"
        let stringMonth = monthFormatter.stringFromDate(self.startDate)
        monthLabel.text = "My \(months[Int(stringMonth)! - 1]) Income"

        
        
        
        tableView.tableFooterView = UIView()
        tableView.registerClass(IncomeTransactionCell.self, forCellReuseIdentifier: GroupTransactionCell.cellIdentifier())
        tableView.delegate = self
        tableView.dataSource = self
        
        self.automaticallyAdjustsScrollViewInsets = false
    }

    private func loadData() {
        // var current_name = ""
        let sortProperties : Array<SortDescriptor>!
        sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: true)]
        let predicate = NSPredicate(format: "date >= %@ and date <= %@ and amount < -10.00", startDate, endDate)
        incomeItems = realm.objects(Transaction).filter(predicate).sorted(sortProperties)
    }
}

extension incomeTransactionsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier(IncomeTransactionCell.cellIdentifier(), forIndexPath: indexPath) as! IncomeTransactionCell
        cell.nameLabel.text = incomeItems[indexPath.row].name
        cell.amountLabel.text = "\(incomeItems[indexPath.row].amount)"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incomeItems.count   //charlieGroupListFiltered.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 94
    }
    
    
}

class IncomeTransactionCell : UITableViewCell {
    let nameLabel = UILabel()
    let amountLabel = UILabel()
    
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
        nameLabel.frame = CGRectMake(14, 37, 220, 20)
        nameLabel.font = UIFont(name: "Montserrat", size: 16.0)
        nameLabel.textColor = UIColor.darkGrayColor()
        nameLabel.textAlignment = .Left
        self.contentView.addSubview(nameLabel)
        
        amountLabel.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 16 -  100, 37, 100, 20)
        amountLabel.font = UIFont(name: "Montserrat", size: 20.0)
        amountLabel.textAlignment = .Right
        self.contentView.addSubview(amountLabel)
    }
    
}