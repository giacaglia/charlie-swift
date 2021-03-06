//
//  CardsViewController.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 11/12/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//


import Foundation

class CardsViewController : UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var mainVC : MainViewControllerDelegate?
    let titleArray = ["MY INCOME", "MY SPENDING", "MY CASH FLOW"]
    var (totalCashFlow, changeCashFlow, totalSpending, changeSpending, totalIncome, changeIncome) = cHelp.getCashFlow(Date(), isCurrentMonth: true)
    var subtitleArray = [String]()
   // let transactions = realm.objects(Transaction).filter(NSPredicate(format: "status > 0 and status < 5"))
    //let totalIncome = cHelp.getIncome(startDate: NSDate().startOfMonth()!, endDate:   NSDate())
    //let totalSpending = cHelp.getSpending(startDate: NSDate().startOfMonth()!, endDate: NSDate())
    var percentageArray = ["+0 0.0%", "+0 0.0%", "+0 0.0%"]
    var percentageChangeIncome = "0.0"
    var percentageChangeSpending = "0.0"
    var percentageCashFlow = "0.0"
    
    
    
   // percentageArray = ["\(changeIncome)%", "\(changeSpending)%", "\(changeCashFlow)%"]
    
    fileprivate func genAttributedString(_ string: String, coloredString:String, color: UIColor) -> NSAttributedString {
        let range = (string as NSString).range(of: coloredString)
        let attributedString = NSMutableAttributedString(string:string)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: color , range: range)
        return attributedString
    }
    
    override func viewDidLoad() {
        subtitleArray = ["\(totalIncome.format(".2"))", "\(totalSpending.format(".2"))", "\(totalCashFlow.format(".2"))"]
        self.getPercentageChange()
        self.collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.cellIdentifier())
        self.collectionView.register(TotalTransactionCell.self, forCellWithReuseIdentifier: TotalTransactionCell.cellIdentifier())
        self.collectionView.register(HabitsCell.self, forCellWithReuseIdentifier: HabitsCell.cellIdentifier())
        self.collectionView.collectionViewLayout = CardLayout()
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func getPercentageChange() {
        let lastMonthDate = Date().dateByAddingMonths(-1)
        
        let lastMonthIncome = cHelp.getIncome(startDate: lastMonthDate!.startOfMonth()!, endDate: cHelp.dateByAddingMonths(-1, date: Date())!)
//        let changeIncome = totalIncome - lastMonthIncome
        
//        if changeIncome != 0 {
//            percentageChangeIncome = (changeIncome/lastMonthIncome * 100).format(".2")
//        }
        
        let lastMonthSpending = cHelp.getSpending(startDate: lastMonthDate!.startOfMonth()!, endDate: lastMonthDate!)
       // let changeSpending = totalSpending - lastMonthSpending
        if changeSpending != 0 {
            percentageChangeSpending = (changeSpending/lastMonthSpending * 100).format(".2")
        }
        
        let lastMonthCashFlow = lastMonthIncome - lastMonthSpending
        //let cashFlow = totalIncome - totalSpending
        ///let changeCashFlow = cashFlow - lastMonthCashFlow
        if changeCashFlow != 0 {
            percentageCashFlow = (changeCashFlow/lastMonthCashFlow * 100).format(".2")
        }
        
        var changeIncomeFormat = ""
        
        var changeSpendingFormat = ""
        
        var changeCashFlowFormat = ""

        if changeIncome  < 0
        {
            changeIncomeFormat = "\(changeIncome.format("0.2"))% from last month"
        }
        else if changeIncome  > 0
        {
            changeIncomeFormat = "\(changeIncome.format("0.2"))% up from last month"
        }
        else
        {
            changeIncomeFormat = "\(changeIncome.format("0.2"))% same as last month"
        }
        
        
        if changeSpending  < 0
        {
            changeSpendingFormat = "\(changeSpending.format("0.2"))% from last month"
        }
        else if changeSpending  > 0
        {
            changeSpendingFormat = "\(changeSpending.format("0.2"))% up from last month"
        }
        else
        {
            changeSpendingFormat = "\(changeSpending.format("0.2"))% same as last month"
        }
        
        if changeCashFlow  < 0
        {
            changeCashFlowFormat = "\(changeCashFlow.format("0.2"))% from last month"
        }
        else if changeSpending  > 0
        {
            changeCashFlowFormat = "\(changeCashFlow.format("0.2"))% up from last month"
        }
        else
        {
            changeCashFlowFormat = "\(changeCashFlow.format("0.2"))% same as last month"
        }

        
        
        
        percentageArray = ["\(changeIncomeFormat)", "\(changeSpendingFormat)", "\(changeCashFlowFormat)"]
    }
    
}


extension CardsViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (indexPath as NSIndexPath).section == 0 {
            return CGSize(width: UIScreen.main.bounds.size.width - 20, height: 160)
        }
        else {
            return CGSize(width: UIScreen.main.bounds.size.width - 20, height: 280)
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //if (transactions.count > 0) {
            return 2
//        }
//        else {
//            return 0   
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return titleArray.count
        }
        else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.cellIdentifier(), for: indexPath) as! CardCell
            if (indexPath as NSIndexPath).row == 0 {
                if Double(changeIncome) >= 0 {
                    cell.backgroundColor = lightGreen
                    cell.backgroundImageView.image = UIImage(named: "positiveIncome")
                }
                else {
                    cell.backgroundColor = lightRed
                }
            }
            else if (indexPath as NSIndexPath).row == 1 {
                if Double(changeSpending) >= 0 {
                    cell.backgroundColor = lightRed
                    cell.backgroundImageView.image = UIImage(named: "negativeSpending")
                }
                else {
                    cell.backgroundColor = lightGreen
                }
            }
            else {
                if Double(changeCashFlow) >= 0 {
                    cell.backgroundColor = lightGreen
                    cell.backgroundImageView.image = UIImage(named: "positiveCashFlow")
                }
                else {
                    cell.backgroundColor = lightRed
                }
            }
            
            cell.titleLabel.text = titleArray[(indexPath as NSIndexPath).row]
            cell.bigTitleLabel.text = subtitleArray[(indexPath as NSIndexPath).row]
            cell.bigTitleLabel.sizeToFit()
            cell.bigTitleLabel.center = CGPoint(x: cell.contentView.center.x + 10, y: cell.bigTitleLabel.center.y)
//            if (indexPath.row == 2) {
//                cell.dollarSignLabel.text = "-$"
//            }
//            else {
//                cell.dollarSignLabel.text = "$"
//            }
            cell.dollarSignLabel.sizeToFit()
            let dollarFrame = cell.dollarSignLabel.frame
            cell.dollarSignLabel.frame = CGRect(x: cell.bigTitleLabel.frame.origin.x - dollarFrame.size.width, y: dollarFrame.origin.y, width: dollarFrame.size.width, height: dollarFrame.size.height)

            cell.subtitleLabel.text = percentageArray[(indexPath as NSIndexPath).row]
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HabitsCell.cellIdentifier(), for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 1 {
//            if mainVC != nil {
//                mainVC?.hideCardsAndShowTransactions()
//            }
            self.present(SwipedTransactionsViewController(), animated: true) { () -> Void in}

        }
    }
}

class TotalTransactionCell : UICollectionViewCell {
    let titleLabel = UILabel()
    let rightArrow = UIImageView()
    
    static func cellIdentifier() -> String {
        return "totalTransactionCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    fileprivate func setup() {
        self.backgroundColor = UIColor.white
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1.0).cgColor
        self.layer.cornerRadius = 1
        
        titleLabel.frame = CGRect(x: 20, y: 11, width: self.frame.size.width, height: 30)
        titleLabel.center = CGPoint(x: titleLabel.center.x, y: self.contentView.center.y)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        titleLabel.textAlignment = .left
        self.contentView.addSubview(titleLabel)

        rightArrow.frame = CGRect(x: self.frame.size.width - 20 - 20, y: 11, width: 20, height: 20)
        rightArrow.center = CGPoint(x: rightArrow.center.x, y: self.contentView.center.y)
        rightArrow.image = UIImage(named: "rightArrow")
        rightArrow.contentMode = .scaleAspectFit
        self.contentView.addSubview(rightArrow)
    }
}

class CardCell : UICollectionViewCell {
    let backgroundImageView = UIImageView()
    let dollarSignLabel = UILabel()
    let bigTitleLabel = UILabel()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let string1 : String = ""
    let string2 : String = ""
    
    static func cellIdentifier() -> String {
        return "cardCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    fileprivate func setup() {
        self.backgroundColor = UIColor.white
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1.0).cgColor
        self.clipsToBounds = true
        
        backgroundImageView.frame = CGRect(x: 0,y: self.frame.size.height - 88, width: self.frame.size.width, height: 88)
        backgroundImageView.contentMode = .scaleAspectFill
        self.contentView.addSubview(backgroundImageView)
        
        titleLabel.frame = CGRect(x: 0, y: 11, width: self.frame.size.width, height: 30)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.center = CGPoint(x: self.center.x, y: titleLabel.center.y)
        self.contentView.addSubview(titleLabel)
        
        let lineView = UIView(frame: CGRect(x: 0, y: 46, width: 40, height: 5))
        lineView.center = CGPoint(x: self.center.x, y: lineView.center.y)
        lineView.backgroundColor = UIColor.white
        lineView.alpha = 0.6
        self.contentView.addSubview(lineView)
        
        dollarSignLabel.frame = CGRect(x: 0, y: 72, width: self.frame.size.width, height: 22)
        dollarSignLabel.text = "$"
        dollarSignLabel.font = UIFont.systemFont(ofSize: 30)
        dollarSignLabel.textColor = UIColor.white
        dollarSignLabel.alpha = 0.6
        dollarSignLabel.textAlignment = .center
        dollarSignLabel.sizeToFit()
        dollarSignLabel.center = CGPoint(x: self.center.x, y: dollarSignLabel.center.y)
        self.contentView.addSubview(dollarSignLabel)

        bigTitleLabel.frame = CGRect(x: 0, y: 62, width: self.frame.size.width, height: 35)
        bigTitleLabel.center = CGPoint(x: self.center.x, y: bigTitleLabel.center.y)
        bigTitleLabel.font = UIFont.boldSystemFont(ofSize: 42.0)
        bigTitleLabel.textColor = UIColor.white
        bigTitleLabel.textAlignment = .center
        self.contentView.addSubview(bigTitleLabel)
        
        subtitleLabel.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width - 70, height: 30)
        subtitleLabel.center = CGPoint(x: self.center.x, y: subtitleLabel.center.y)
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        self.contentView.addSubview(subtitleLabel)
    }
}

class HabitsCell : UICollectionViewCell {
    let happiestCityLabel = UILabel()
    let spendOnline = UILabel()
    let happyFlow = UILabel()
    let mostExpensiveCiy = UILabel()
    
    static func cellIdentifier() -> String {
        return "habitsCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    fileprivate func setup() {
        self.backgroundColor = UIColor.white
      
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1.0).cgColor
        self.layer.cornerRadius = 1
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 15, y: 11, width: self.frame.size.width - 30, height: 30)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        titleLabel.textColor = UIColor(red: 163/255.0, green: 163/255.0, blue: 163/255.0, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.center = CGPoint(x: self.center.x, y: titleLabel.center.y)
        titleLabel.text = "MY HABITS"
        self.contentView.addSubview(titleLabel)
        
        let lineView = UIView(frame: CGRect(x: 0, y: 46, width: 40, height: 5))
        lineView.center = CGPoint(x: self.center.x, y: lineView.center.y)
        lineView.backgroundColor = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1.0)
        lineView.alpha = 0.6
        self.contentView.addSubview(lineView)
        
        self.setLabel(happiestCityLabel, atPosition: 51)
        self.setLabel(spendOnline, atPosition: 101)
        self.setLabel(happyFlow, atPosition: 151)
        self.setLabel(mostExpensiveCiy, atPosition: 201)
        let mostHappy = cHelp.getMostHappyCity()
        if !mostHappy.isEmpty {
             happiestCityLabel.text = "My happiest city is \(mostHappy)"
        }
        let (digitalHappyFlow, digitalSpentPercentage, _, _, placeHappyFlow, placeSpentPercentage) = cHelp.getTypeSpent()
        if (digitalHappyFlow > placeHappyFlow) {
            spendOnline.text = "I should spend more online than offline. Currently I spend \(digitalSpentPercentage.format("0.2"))% online."
        }
        else {
            spendOnline.text = "I should spend more offline than online. Currently I spend \(placeSpentPercentage.format("0.2"))% offline."
        }
        happyFlow.text = "My happiness flow for offline is \(placeHappyFlow.format(".2"))%."

        let mostSpentCity = cHelp.getCityMostSpentMoney()
        if !mostSpentCity.isEmpty {
            mostExpensiveCiy.text = "I shouldn't spend so much money in \(mostSpentCity)"
        }
    }
    
    fileprivate func setLabel(_ label: UILabel,atPosition y: CGFloat) {
        label.frame = CGRect(x: 15, y: y, width: self.frame.size.width - 30, height: 50)
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textColor = UIColor(red: 92/255.0, green: 92/255.0, blue: 92/255.0, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.center = CGPoint(x: self.center.x, y: label.center.y)
        self.contentView.addSubview(label)
    }
}

class CardLayout : UICollectionViewFlowLayout {
    override init() {
        super.init()
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
  
    fileprivate func setup() {
        self.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        self.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 20, height: 160)
        self.scrollDirection = .vertical
    }
}

extension Double {
    func format(_ f: String) -> String {
        return NSString(format: "%\(f)f as NSString as NSString as NSString as NSString as NSString as NSString as NSString", self) as String
    }
    
    func commaFormatted() -> String {
        let integer = Int(self)
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        return fmt.string(from: NSNumber(integer))!
    }
}
