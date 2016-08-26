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
    @IBOutlet weak var monthLabel: UILabel!
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var startDate = Date()
    var endDate = Date()
    var incomeItems = realm.objects(Transaction)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Worth It?"
        
        loadData()
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MM"
        let stringMonth = monthFormatter.string(from: self.startDate)
        monthLabel.text = "My \(months[Int(stringMonth)! - 1]) Income"


        tableView.tableFooterView = UIView()
        tableView.register(IncomeTransactionCell.self, forCellReuseIdentifier: GroupTransactionCell.cellIdentifier())
        tableView.delegate = self
        tableView.dataSource = self
        
        self.automaticallyAdjustsScrollViewInsets = false
    }

    fileprivate func loadData() {
        // var current_name = ""
        let sortProperties : Array<SortDescriptor>!
        sortProperties = [SortDescriptor(property: "amount", ascending: true)]
        let predicate = NSPredicate(format: "date >= %@ and date <= %@ and amount < -10.00 and categories.id != '21001000'", startDate as CVarArg, endDate as CVarArg)
        incomeItems = realm.objects(Transaction).filter(predicate).sorted(sortProperties)
    }
}

extension incomeTransactionsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       

            let cell = tableView .dequeueReusableCell(withIdentifier: IncomeTransactionCell.cellIdentifier(), for: indexPath) as! IncomeTransactionCell
            cell.nameLabel.text = incomeItems[(indexPath as NSIndexPath).row].name
            
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, YYYY"
        
            let dateString = dateFormatter.string(from: incomeItems[(indexPath as NSIndexPath).row].date)
        
            //gray out if it doesn't count
            if incomeItems[(indexPath as NSIndexPath).row].ctype == 86
            {
            
             cell.dateLabel.text = dateString.uppercased()
             cell.dateLabel.textColor = UIColor.lightGray
             cell.amountLabel.textColor = UIColor.lightGray
             cell.nameLabel.textColor = UIColor.lightGray
                cell.amountLabel.attributedText = NSAttributedString.createAttributedString(UIFont(name: "Montserrat", size: 18.0)!, string1: "$", color1: UIColor.lightGray, string2: (-incomeItems[(indexPath as NSIndexPath).row].amount).format(".2"), color2: UIColor.lightGray)
            }
            else
            {
            cell.dateLabel.text = dateString.uppercased()
            cell.amountLabel.attributedText = NSAttributedString.createAttributedString(UIFont(name: "Montserrat", size: 18.0)!, string1: "$", color1: UIColor(white: 209/255.0, alpha: 1.0), string2: (-incomeItems[(indexPath as NSIndexPath).row].amount).format(".2"), color2: UIColor(white: 92/255.0, alpha: 1.0))
            }
            return cell

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incomeItems.count   //charlieGroupListFiltered.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let transactionDetailVC = storyboard.instantiateViewController(withIdentifier: "showTransactionViewController") as? showTransactionViewController else {
            return
        }

        
        

        transactionDetailVC.transaction = incomeItems[(indexPath as NSIndexPath).row]

        
        self.navigationController?.pushViewController(transactionDetailVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
}

class IncomeTransactionCell : UITableViewCell {
    let nameLabel = UILabel()
    let dateLabel = UILabel()
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
    
    fileprivate func setup() {
        nameLabel.frame = CGRect(x: 14, y: 26, width: 220, height: 20)
        nameLabel.font = UIFont(name: "Montserrat", size: 16.0)
        nameLabel.textColor = UIColor(white: 74/255.0, alpha: 1.0)

        dateLabel.frame = CGRect(x: 14, y: 50, width: 220, height: 20)
        dateLabel.font = UIFont(name: "Montserrat", size: 13.0)
        dateLabel.textColor = UIColor(white: 74/255.0, alpha: 1.0)

        
        nameLabel.textAlignment = .left
        self.contentView.addSubview(nameLabel)
        
        dateLabel.textAlignment = .left
        self.contentView.addSubview(dateLabel)
        
        amountLabel.frame = CGRect(x: UIScreen.main.bounds.size.width - 16 -  100, y: 26, width: 100, height: 20)
        amountLabel.textAlignment = .right
        self.contentView.addSubview(amountLabel)
    }
    
}
