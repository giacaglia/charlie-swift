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

@IBOutlet var incomeTransView: UIView!
@IBOutlet weak var tableView: UITableView!

    
var charlieGroupListFiltered = [charlieGroup]()
let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    
    var startDate:NSDate = NSDate()
    var endDate:NSDate = NSDate()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        tableView.tableFooterView = UIView()
        tableView.registerClass(IncomeTransactionCell.self, forCellReuseIdentifier: GroupTransactionCell.cellIdentifier())
        tableView.delegate = self
        tableView.dataSource = self
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        
        
        
        
    }
    
    
    

}

extension incomeTransactionsViewController {
   
    private func loadData() {
        var current_name = ""
        let sortProperties : Array<SortDescriptor>!
        
        sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: true)]
        let predicate = NSPredicate(format: "date >= %@ and date <= %@ and amount < -10.00", startDate, endDate)
        let incomeItems = realm.objects(Transaction).filter(predicate).sorted(sortProperties)
        var current_index = 1
        
        for trans in incomeItems {
            if trans.name == current_name {
                charlieGroupListFiltered[current_index].totalAmount +=  trans.amount
            }
            else {
                
                let cGroup = charlieGroup(name: trans.name, lastDate: String(trans.date))
                charlieGroupListFiltered.append((cGroup))
                current_index = charlieGroupListFiltered.count - 1
                charlieGroupListFiltered[current_index].totalAmount +=  trans.amount

            }
            current_name = trans.name
            
        }
    }
    
}



extension incomeTransactionsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        
        let cell = tableView .dequeueReusableCellWithIdentifier(IncomeTransactionCell.cellIdentifier(), forIndexPath: indexPath) as! IncomeTransactionCell
        
        let charlieGroup = charlieGroupListFiltered[indexPath.row]
        
        cell.nameLabel.text = charlieGroup.name
        cell.amountLabel.text = "\(charlieGroup.totalAmount)"
        
       return cell
        
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charlieGroupListFiltered.count
    }
    
}

class IncomeTransactionCell : UITableViewCell {
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
        amountLabel.font = UIFont.systemFontOfSize(16.0)
        amountLabel.textAlignment = .Right
        self.contentView.addSubview(amountLabel)
        
        dollarLabel.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 15 -  70, 49, 80, 18)
        dollarLabel.font = UIFont(name: "Montserrat-Bold", size: 15.0)
        dollarLabel.textColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
        dollarLabel.textAlignment = .Right
        self.contentView.addSubview(dollarLabel)
    }
    
}