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
    var (totalCashFlow, changeCashFlow, totalSpending, changeSpending, totalIncome, changeIncome) = cHelp.getCashFlow(NSDate())
    var subtitleArray = [String]()
   // let transactions = realm.objects(Transaction).filter(NSPredicate(format: "status > 0 and status < 5"))
    //let totalIncome = cHelp.getIncome(startDate: NSDate().startOfMonth()!, endDate:   NSDate())
    //let totalSpending = cHelp.getSpending(startDate: NSDate().startOfMonth()!, endDate: NSDate())
    var percentageArray = ["+0 0.0%", "+0 0.0%", "+0 0.0%"]
    var percentageChangeIncome = "0.0"
    var percentageChangeSpending = "0.0"
    var percentageCashFlow = "0.0"
    
    
    
   // percentageArray = ["\(changeIncome)%", "\(changeSpending)%", "\(changeCashFlow)%"]
    
    private func genAttributedString(string: String, coloredString:String, color: UIColor) -> NSAttributedString {
        let range = (string as NSString).rangeOfString(coloredString)
        let attributedString = NSMutableAttributedString(string:string)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: color , range: range)
        return attributedString
    }
    
    override func viewDidLoad() {
        subtitleArray = ["\(totalIncome.format(".2"))", "\(totalSpending.format(".2"))", "\(totalCashFlow.format(".2"))"]
        self.getPercentageChange()
        self.collectionView.registerClass(CardCell.self, forCellWithReuseIdentifier: CardCell.cellIdentifier())
        self.collectionView.registerClass(TotalTransactionCell.self, forCellWithReuseIdentifier: TotalTransactionCell.cellIdentifier())
        self.collectionView.registerClass(HabitsCell.self, forCellWithReuseIdentifier: HabitsCell.cellIdentifier())
        self.collectionView.collectionViewLayout = CardLayout()
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func getPercentageChange() {
        let lastMonthDate = NSDate().dateByAddingMonths(-1)
        
        let lastMonthIncome = cHelp.getIncome(startDate: lastMonthDate!.startOfMonth()!, endDate: cHelp.dateByAddingMonths(-1, date: NSDate())!)
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSizeMake(UIScreen.mainScreen().bounds.size.width - 20, 160)
        }
        else {
            return CGSizeMake(UIScreen.mainScreen().bounds.size.width - 20, 280)
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //if (transactions.count > 0) {
            return 2
//        }
//        else {
//            return 0   
//        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return titleArray.count
        }
        else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CardCell.cellIdentifier(), forIndexPath: indexPath) as! CardCell
            if indexPath.row == 0 {
                if Double(changeIncome) >= 0 {
                    cell.backgroundColor = lightGreen
                    cell.backgroundImageView.image = UIImage(named: "positiveIncome")
                }
                else {
                    cell.backgroundColor = lightRed
                }
            }
            else if indexPath.row == 1 {
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
            
            cell.titleLabel.text = titleArray[indexPath.row]
            cell.bigTitleLabel.text = subtitleArray[indexPath.row]
            cell.bigTitleLabel.sizeToFit()
            cell.bigTitleLabel.center = CGPointMake(cell.contentView.center.x + 10, cell.bigTitleLabel.center.y)
//            if (indexPath.row == 2) {
//                cell.dollarSignLabel.text = "-$"
//            }
//            else {
//                cell.dollarSignLabel.text = "$"
//            }
            cell.dollarSignLabel.sizeToFit()
            let dollarFrame = cell.dollarSignLabel.frame
            cell.dollarSignLabel.frame = CGRectMake(cell.bigTitleLabel.frame.origin.x - dollarFrame.size.width, dollarFrame.origin.y, dollarFrame.size.width, dollarFrame.size.height)

            cell.subtitleLabel.text = percentageArray[indexPath.row]
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HabitsCell.cellIdentifier(), forIndexPath: indexPath)
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
//            if mainVC != nil {
//                mainVC?.hideCardsAndShowTransactions()
//            }
            self.presentViewController(SwipedTransactionsViewController(), animated: true) { () -> Void in}

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
    
    private func setup() {
        self.backgroundColor = UIColor.whiteColor()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1.0).CGColor
        self.layer.cornerRadius = 1
        
        titleLabel.frame = CGRectMake(20, 11, self.frame.size.width, 30)
        titleLabel.center = CGPointMake(titleLabel.center.x, self.contentView.center.y)
        titleLabel.font = UIFont.boldSystemFontOfSize(15.0)
        titleLabel.textAlignment = .Left
        self.contentView.addSubview(titleLabel)

        rightArrow.frame = CGRectMake(self.frame.size.width - 20 - 20, 11, 20, 20)
        rightArrow.center = CGPointMake(rightArrow.center.x, self.contentView.center.y)
        rightArrow.image = UIImage(named: "rightArrow")
        rightArrow.contentMode = .ScaleAspectFit
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
    
    private func setup() {
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1.0).CGColor
        self.clipsToBounds = true
        
        backgroundImageView.frame = CGRectMake(0,self.frame.size.height - 88, self.frame.size.width, 88)
        backgroundImageView.contentMode = .ScaleAspectFill
        self.contentView.addSubview(backgroundImageView)
        
        titleLabel.frame = CGRectMake(0, 11, self.frame.size.width, 30)
        titleLabel.font = UIFont.boldSystemFontOfSize(15.0)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.center = CGPointMake(self.center.x, titleLabel.center.y)
        self.contentView.addSubview(titleLabel)
        
        let lineView = UIView(frame: CGRectMake(0, 46, 40, 5))
        lineView.center = CGPointMake(self.center.x, lineView.center.y)
        lineView.backgroundColor = UIColor.whiteColor()
        lineView.alpha = 0.6
        self.contentView.addSubview(lineView)
        
        dollarSignLabel.frame = CGRectMake(0, 72, self.frame.size.width, 22)
        dollarSignLabel.text = "$"
        dollarSignLabel.font = UIFont.systemFontOfSize(30)
        dollarSignLabel.textColor = UIColor.whiteColor()
        dollarSignLabel.alpha = 0.6
        dollarSignLabel.textAlignment = .Center
        dollarSignLabel.sizeToFit()
        dollarSignLabel.center = CGPointMake(self.center.x, dollarSignLabel.center.y)
        self.contentView.addSubview(dollarSignLabel)

        bigTitleLabel.frame = CGRectMake(0, 62, self.frame.size.width, 35)
        bigTitleLabel.center = CGPointMake(self.center.x, bigTitleLabel.center.y)
        bigTitleLabel.font = UIFont.boldSystemFontOfSize(42.0)
        bigTitleLabel.textColor = UIColor.whiteColor()
        bigTitleLabel.textAlignment = .Center
        self.contentView.addSubview(bigTitleLabel)
        
        subtitleLabel.frame = CGRectMake(0, 100, UIScreen.mainScreen().bounds.size.width - 70, 30)
        subtitleLabel.center = CGPointMake(self.center.x, subtitleLabel.center.y)
        subtitleLabel.textColor = UIColor.whiteColor()
        subtitleLabel.textAlignment = .Center
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
    
    private func setup() {
        self.backgroundColor = UIColor.whiteColor()
      
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1.0).CGColor
        self.layer.cornerRadius = 1
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRectMake(15, 11, self.frame.size.width - 30, 30)
        titleLabel.font = UIFont.boldSystemFontOfSize(15.0)
        titleLabel.textColor = UIColor(red: 163/255.0, green: 163/255.0, blue: 163/255.0, alpha: 1.0)
        titleLabel.textAlignment = .Center
        titleLabel.center = CGPointMake(self.center.x, titleLabel.center.y)
        titleLabel.text = "MY HABITS"
        self.contentView.addSubview(titleLabel)
        
        let lineView = UIView(frame: CGRectMake(0, 46, 40, 5))
        lineView.center = CGPointMake(self.center.x, lineView.center.y)
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
    
    private func setLabel(label: UILabel,atPosition y: CGFloat) {
        label.frame = CGRectMake(15, y, self.frame.size.width - 30, 50)
        label.font = UIFont.boldSystemFontOfSize(14.0)
        label.textColor = UIColor(red: 92/255.0, green: 92/255.0, blue: 92/255.0, alpha: 1.0)
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.center = CGPointMake(self.center.x, label.center.y)
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
  
    private func setup() {
        self.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        self.itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width - 20, 160)
        self.scrollDirection = .Vertical
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}
