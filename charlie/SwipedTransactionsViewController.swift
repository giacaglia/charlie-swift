//
//  SwipedTransactions.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 11/23/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//

import Foundation
import RealmSwift
import Charts

class SwipedTransactionsViewController : UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var charlieGroupListFiltered = [charlieGroup]()
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let filterNames = ["All", "Bills", "Spending"]
    var totalAll:Double = 0.0
    var totalSpending:Double = 0.0
    var totalBills:Double = 0.0
    var currentRow = 0

//    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let layout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: CGRect(x: 0, y: 300, width: UIScreen.main.bounds.size.width, height: 50), collectionViewLayout: UICollectionViewLayout())

    static let blackView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    var filterType : SortFilterType! = .filterByName
    let sortVC = SortViewController()

    var startDate:Date = Date()
    var endDate:Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 27, height: 24))
        button.setBackgroundImage(UIImage(named: "btn_filter"), for: UIControlState())
        button.addTarget(self, action: #selector(SwipedTransactionsViewController.didTouchFilter(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.title = "Worth It?"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SwipedTransactionsViewController.dismissSort))
        SwipedTransactionsViewController.blackView.addGestureRecognizer(tapGesture)
        sortVC.delegate = self

//        let monthFormatter = NSDateFormatter()
//        monthFormatter.dateFormat = "MM"
//        let stringMonth = monthFormatter.stringFromDate(self.startDate)
        
        tableView.tableFooterView = UIView()
        tableView.register(GroupTransactionCell.self, forCellReuseIdentifier: GroupTransactionCell.cellIdentifier())
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.loadData(0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.loadData(currentRow)
        self.changeFilter(self.filterType)
        self.collectionView.reloadData()
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSizeMake((self.view.frame.width/3 - 10), 44)
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! mySpendingCVCell
        
        if (indexPath as NSIndexPath).row == 0
        {
            cell.filterName.text = "\(filterNames[(indexPath as NSIndexPath).row])"
            cell.filterAmount.text = "\(totalAll)"
            
            if currentRow == 0
            {
                cell.filterName.textColor = UIColor.black
                cell.filterAmount.textColor = UIColor.black
            }
            else
            {
                cell.filterName.textColor = UIColor.lightGray
                cell.filterAmount.textColor = UIColor.lightGray
            }
            
            
        }
        else if (indexPath as NSIndexPath).row == 1
        {
            cell.filterName.text = "\(filterNames[(indexPath as NSIndexPath).row])"
            cell.filterAmount.text = "\(totalBills)"
            
            
            if currentRow == 1
            {
                cell.filterName.textColor = UIColor.black
                cell.filterAmount.textColor = UIColor.black
            }
            else
            {
                cell.filterName.textColor = UIColor.lightGray
                cell.filterAmount.textColor = UIColor.lightGray
                
            }
        }
        else if (indexPath as NSIndexPath).row == 2
        {
            cell.filterName.text = "\(filterNames[(indexPath as NSIndexPath).row])"
            cell.filterAmount.text = "\(totalSpending)"
           
            if currentRow == 2
            {
                cell.filterName.textColor = UIColor.black
                cell.filterAmount.textColor = UIColor.black
            }
            else
            {
                cell.filterName.textColor = UIColor.lightGray
                cell.filterAmount.textColor = UIColor.lightGray
                
            }
            
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentRow = (indexPath as NSIndexPath).row
        if (indexPath as NSIndexPath).row == 0 {
            self.loadData(0)
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
        else if (indexPath as NSIndexPath).row  == 1 {
            self.loadData(1)
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
        else if (indexPath as NSIndexPath).row  == 2
        {
         self.loadData(2)
         self.tableView.reloadData()
         self.collectionView.reloadData()
        
        }
        print("pressed")
        
    }
    
    
    func didTouchFilter(_ sender: AnyObject) {
        let topViewController = self.navigationController
        if topViewController == nil {
            return
        }
        self.sortVC.initialFilterType = self.filterType
        let height = self.view.frame.size.height*0.8
        self.sortVC.view.frame = CGRect(x: 0, y: -height, width: self.view.frame.size.width, height: height)
        SwipedTransactionsViewController.blackView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        topViewController!.view.addSubview(SwipedTransactionsViewController.blackView)
        
        topViewController!.addChildViewController(sortVC)
        topViewController!.view.addSubview(sortVC.view)
        UIView.animate(withDuration: 0.5) { () -> Void in
            self.sortVC.view.frame = CGRect(x: 0, y: 0, width: self.sortVC.view.frame.width, height: height)
        }
    }
    
    func dismissSort() {
        self.sortVC.closePressed(self)
    }
    
}

extension SwipedTransactionsViewController {
    fileprivate func loadData(_ spendingType:Int) {
        charlieGroupListFiltered = [charlieGroup]()
        
        var predicate = NSPredicate()
        var count_predicate = NSPredicate()
        var current_name = ""

        let sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: true)]
        
        count_predicate = NSPredicate(format: "date >= %@ and date <= %@", startDate as CVarArg, endDate as CVarArg)
        
        
        if spendingType == 0
        {
            predicate = NSPredicate(format: "date >= %@ and date <= %@", startDate as CVarArg, endDate as CVarArg)
        }
        else if spendingType == 2
        {
            predicate = NSPredicate(format: "date >= %@ and date <= %@ and ctype = 2", startDate as CVarArg, endDate as CVarArg)
            
        }
        else if spendingType == 1
        {
            predicate = NSPredicate(format: "date >= %@ and date <= %@ and ctype = 1", startDate as CVarArg, endDate as CVarArg)
            
        }

        let countItems = realm.objects(Transaction).filter(count_predicate).sorted(sortProperties)
        
        let actedUponItems = realm.objects(Transaction).filter(predicate).sorted(sortProperties)
        var current_index = 1
        print("TOTAL \(actedUponItems.count)")
        
        
       
        totalAll = 0
        totalBills = 0
        totalSpending = 0
       
       
        
        for countI in countItems {
            
            if countI.amount > 0 && countI.ctype != 86 && countI.categories?.id != "21001000"
            {
                totalAll += countI.amount
            }
            if countI.ctype == 1
            {
                totalBills += countI.amount
            }
            else if countI.ctype == 2
            {
                totalSpending += countI.amount
            }

            
            
        }
        
        for trans in actedUponItems {
            
            
            if trans.name == current_name {
                // Approved items
                
               
            
                if trans.status == 1 {
                  //  print("Worth IT \(current_index) - \(trans.name) \(trans.status)")
                    charlieGroupListFiltered[current_index].worthCount = charlieGroupListFiltered[current_index].worthCount + 1
                    charlieGroupListFiltered[current_index].worthValue = charlieGroupListFiltered[current_index].worthValue + trans.amount
                    charlieGroupListFiltered[current_index].happyPercentage = Int((Double(charlieGroupListFiltered[current_index].worthCount) / Double((charlieGroupListFiltered[current_index].transactions - charlieGroupListFiltered[current_index].notSwipedCount )) * 100))
                     charlieGroupListFiltered[current_index].totalAmount +=  trans.amount
                }
                // Flagged items
                else if trans.status == 2 {
                  //  print("NOT Worth IT \(current_index) - \(trans.name) \(trans.status)")
                    charlieGroupListFiltered[current_index].notWorthCount += 1
                    charlieGroupListFiltered[current_index].notWorthValue += trans.amount
                    charlieGroupListFiltered[current_index].happyPercentage = Int((Double(charlieGroupListFiltered[current_index].worthCount) / Double((charlieGroupListFiltered[current_index].transactions - charlieGroupListFiltered[current_index].notSwipedCount )) * 100))
                     charlieGroupListFiltered[current_index].totalAmount +=  trans.amount
                }
               else if trans.status  ==  -1 || trans.status ==  0 {
                  //  print("NOT SWIPED\(current_index) - \(trans.name) \(trans.status)")
                    charlieGroupListFiltered[current_index].notSwipedCount += 1
                    charlieGroupListFiltered[current_index].notSwipedValue += trans.amount
                    charlieGroupListFiltered[current_index].totalAmount +=  trans.amount
                }
            }
            else {                
                let cGroup = charlieGroup(name: trans.name, lastDate: trans.date)
                cGroup.ctype = trans.ctype
                if trans.status == 1 {
                    cGroup.worthCount += 1
                    cGroup.worthValue += trans.amount
                    charlieGroupListFiltered.append((cGroup))
                    
                    current_index = charlieGroupListFiltered.count - 1
                   // print("create new group: WORTH IT \(current_index) - \(trans.name) \(trans.status)")
                }
                else if trans.status == 2 {
                    cGroup.notWorthCount += 1
                    cGroup.notWorthValue += trans.amount
                    charlieGroupListFiltered.append((cGroup))
                    current_index = charlieGroupListFiltered.count - 1
                    //print("create new group: NOT WORTH IT \(current_index) - \(trans.name) \(trans.status)")
                }
                else if trans.status ==  -1 || trans.status ==  0 {
                    cGroup.notSwipedCount += 1
                    cGroup.notSwipedValue += trans.amount
                    charlieGroupListFiltered.append((cGroup))
                    current_index = charlieGroupListFiltered.count - 1
                   // print("create new group: NOT SWIPED \(current_index) - \(trans.name) \(trans.status)")
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
    
    func changeFilter(_ filterType:SortFilterType){
        self.filterType = filterType
        self.filterBy(self.filterType)
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
        })
        SwipedTransactionsViewController.blackView.removeFromSuperview()
    }
    
    func changeTransactionType(_ type: TransactionType) {
        self.filterBy(self.filterType)
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
        })
        SwipedTransactionsViewController.blackView.removeFromSuperview()
    }
    
    fileprivate func filterBy(_ sortFilter: SortFilterType) {
        if (sortFilter == .filterByMostWorth) {
           self.charlieGroupListFiltered = self.charlieGroupListFiltered.sorted {
                return $0.happyPercentage > $1.happyPercentage
            }
        }
        else if (sortFilter == .filterByLeastWorth) {
            self.charlieGroupListFiltered = self.charlieGroupListFiltered.sorted {
                return $0.happyPercentage < $1.happyPercentage
            }
        }

        else if (sortFilter == .filterByAmount) {
            self.charlieGroupListFiltered = self.charlieGroupListFiltered.sorted {
                return $0.totalAmount > $1.totalAmount
            }
        }
        
        else if (sortFilter == .filterByName) {
            self.charlieGroupListFiltered = self.charlieGroupListFiltered.sorted {
                return $0.name < $1.name
            }
        }
            
            
        else if (sortFilter == .filterByDescendingDate) {
            self.charlieGroupListFiltered = self.charlieGroupListFiltered.sorted {
                return String($0.lastDate) > String($1.lastDate)
            }
        }
        else if (sortFilter == .filterByDate) {
            self.charlieGroupListFiltered = self.charlieGroupListFiltered.sorted {
                return String($0.lastDate) < String($1.lastDate)
            }
        }
    }
}

extension SwipedTransactionsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: GroupTransactionCell.cellIdentifier(), for: indexPath) as! GroupTransactionCell
        let charlieGroup = charlieGroupListFiltered[(indexPath as NSIndexPath).row]
       
        let attrsA = [NSFontAttributeName: UIFont(name: "Montserrat", size: 15.0)!, NSForegroundColorAttributeName: UIColor(white: 74.0/255.0, alpha: 1.0)]
        let a = NSMutableAttributedString(string:charlieGroup.name, attributes:attrsA)
        if charlieGroup.transactions == 1 {
            cell.nameLabel.attributedText = a
        }
        else {
            let attrsB = [NSFontAttributeName: UIFont(name: "Montserrat", size: 15.0)!, NSForegroundColorAttributeName: UIColor(white: 155.0/255.0, alpha: 1.0)]
            let b = NSAttributedString(string:" (\(charlieGroup.transactions))", attributes:attrsB)
            a.append(b)
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
        
        
        let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "EE, MMM dd "
        
        let dateString = dateFormatter.string(from: charlieGroup.lastDate as Date)
        cell.dateLabel.text = dateString.uppercased()

        //dateFormatter.dateFormat = "MMM dd, YYYY"
       // let tempDate = dateFormatter.dateFromString(charlieGroup.lastDate)
        cell.dateLabel.text = dateString.uppercased()
        
        if charlieGroup.ctype == 86
        {
            cell.typeImageView.image = UIImage(named: "dont_count")
        }
        else if charlieGroup.ctype == 1
        {
            cell.typeImageView.image = UIImage(named: "blue_bills")
        }
        else if charlieGroup.ctype == 2
        {
            cell.typeImageView.image = UIImage(named: "blue_spending")
        }
        else if charlieGroup.ctype == 3
        {
            cell.typeImageView.image = UIImage(named: "blue_savings")
        }
        else
        {
            cell.typeImageView.image = UIImage(named: "blue_uncategorized")
        }
        
        cell.dollarLabel.attributedText = NSAttributedString.createAttributedString(UIFont(name: "Montserrat-Light", size: 18.0)!, string1: "$", color1: UIColor(white: 209/255.0, alpha: 1.0), string2: (charlieGroup.worthValue + charlieGroup.notWorthValue + charlieGroup.notSwipedValue).format(".2"), color2: UIColor(white: 92/255.0, alpha: 1.0))
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charlieGroupListFiltered.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = charlieGroupListFiltered[(indexPath as NSIndexPath).row]
        //if group.transactions > 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let groupDetailVC = storyboard.instantiateViewController(withIdentifier: "GroupDetailViewController") as? GroupDetailViewController else {
                return
            }
            
            groupDetailVC.startDate = self.startDate
            groupDetailVC.transactionName =  group.name
            groupDetailVC.endDate = self.endDate
            self.navigationController?.pushViewController(groupDetailVC, animated: true)
//        }
//        else {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            guard let showTransactionVC = storyboard.instantiateViewControllerWithIdentifier("showTransactionViewController") as? showTransactionViewController else {
//                return
//            }
//            let sortProperties = [SortDescriptor(property: "name", ascending: true), SortDescriptor(property: "date", ascending: false)]
//            let predicate = NSPredicate(format: "name = %@", group.name)
//            transactionItems = realm.objects(Transaction).filter(predicate).sorted(sortProperties)
//            let transaction = transactionItems[0]
//            showTransactionVC.transaction = transaction
//            showTransactionVC.transactionIndex = 0
//            if transaction.status == -1 {
//                showTransactionVC.sourceVC = "main"
//            }
//            else if transaction.status == 1 {
//                showTransactionVC.sourceVC = "happy"
//            }
//            else {
//                showTransactionVC.sourceVC = "sad"
//            }
//            self.navigationController?.pushViewController(showTransactionVC, animated: true)
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 350.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = .white()
        let pieChart = PieChartView(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: 0, width: 300, height: 300))
        let dataPoints = ["Bills", "Spending"]
        let values = [totalBills, totalSpending]
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries)
        pieChartDataSet.colors = [UIColor(white: 216/255.0, alpha: 1.0), listBlue]
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)

        pieChart.drawHoleEnabled = false
        pieChart.data = pieChartData
        vw.addSubview(pieChart)
        
        vw.addSubview(collectionView)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: (self.view.frame.width/3), height: 50)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .white()
        collectionView.register(UINib(nibName: "mySpendingCVCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self

        return vw
    }
}

class GroupTransactionCell : UITableViewCell {
    let nameLabel = UILabel()
    let amountLabel = UILabel()
    let dateLabel = UILabel()
    let dollarLabel = UILabel()
    let typeImageView = UIImageView()
    
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
        typeImageView.frame = CGRect(x: 16, y: 30, width: 39, height: 39)
        
        self.contentView.addSubview(typeImageView)
        
        nameLabel.frame = CGRect(x: 66, y: 26, width: UIScreen.main.bounds.size.width - 15 -  80 - 14 - 5 - 42, height: 20)
        nameLabel.font = UIFont(name: "Montserrat", size: 15.0)
        nameLabel.textColor = UIColor(white: 74.0/255.0, alpha: 1.0)
        nameLabel.textAlignment = .left
        self.contentView.addSubview(nameLabel)
        
        dateLabel.frame = CGRect(x: 66, y: 50, width: UIScreen.main.bounds.size.width - 15 -  80 - 14 - 5, height: 20)
        dateLabel.font = UIFont(name: "Montserrat", size: 12.0)
        dateLabel.textColor = UIColor(white: 74.0/255.0, alpha: 1.0)
        dateLabel.textAlignment = .left
        self.contentView.addSubview(dateLabel)
        
        
        
        dollarLabel.frame = CGRect(x: UIScreen.main.bounds.size.width - 15 -  90, y: 26, width: 90, height: 18)
        dollarLabel.font = UIFont(name: "Montserrat-Light", size: 18.0)
        dollarLabel.textColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
        dollarLabel.textAlignment = .right
        self.contentView.addSubview(dollarLabel)
        
        amountLabel.frame = CGRect(x: UIScreen.main.bounds.size.width - 15 -  60, y: 50, width: 60, height: 18)
        amountLabel.font = UIFont(name: "Montserrat", size: 18.0)
        amountLabel.textAlignment = .right
        self.contentView.addSubview(amountLabel)

    }
}
