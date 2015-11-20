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
    let titleArray = ["MY INCOME", "MY SPENDING", "MY CASH FLOW"]
    let (cashFlow, _, _, _, income, incomeChange) = cHelp.getCashFlow()
    var subtitleArray = [String]()

    private func genAttributedString(string: String, coloredString:String, color: UIColor) -> NSAttributedString {
        let range = (string as NSString).rangeOfString(coloredString)
        let attributedString = NSMutableAttributedString(string:string)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: color , range: range)
        return attributedString
    }
    
    override func viewDidLoad() {
        let cashFlowTotal = (cHelp.getHappyFlow() * 100).format(".2")
        let spending = income - Double(cashFlowTotal)!
        subtitleArray = ["$\(income.format(".2"))", "$\(spending.format(".2"))", "$\(cashFlowTotal)"]
        self.collectionView.registerClass(CardCell.self, forCellWithReuseIdentifier: CardCell.cellIdentifier())
        self.collectionView.registerClass(TotalTransactionCell.self, forCellWithReuseIdentifier: TotalTransactionCell.cellIdentifier())
        self.collectionView.registerClass(HabitsCell.self, forCellWithReuseIdentifier: HabitsCell.cellIdentifier())
        self.collectionView.collectionViewLayout = CardLayout()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
}


extension CardsViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSizeMake(UIScreen.mainScreen().bounds.size.width - 20, 70)
        }
        else if indexPath.section == 1 {
            return CGSizeMake(UIScreen.mainScreen().bounds.size.width - 20, 160)
        }
        else {
            return CGSizeMake(UIScreen.mainScreen().bounds.size.width - 20, 250)
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return titleArray.count
        }
        else {
            return 1
        }

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let totalTransactionCell = collectionView.dequeueReusableCellWithReuseIdentifier(TotalTransactionCell.cellIdentifier(), forIndexPath: indexPath) as! TotalTransactionCell
            return totalTransactionCell
        }
        else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CardCell.cellIdentifier(), forIndexPath: indexPath) as! CardCell
            if (indexPath.row == 0) {
                cell.backgroundColor = lightGreen
            }
            else {
                cell.backgroundColor = lightRed
            }
            cell.titleLabel.text = titleArray[indexPath.row]
            cell.bigTitleLabel.text = subtitleArray[indexPath.row]
            cell.subtitleLabel.text = subtitleArray[indexPath.row]
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HabitsCell.cellIdentifier(), forIndexPath: indexPath)
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
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
        titleLabel.text = "87 transactions"
        self.contentView.addSubview(titleLabel)

        rightArrow.frame = CGRectMake(self.frame.size.width - 20 - 20, 11, 20, 20)
        rightArrow.center = CGPointMake(rightArrow.center.x, self.contentView.center.y)
        rightArrow.image = UIImage(named: "rightArrow")
        rightArrow.contentMode = .ScaleAspectFit
        self.contentView.addSubview(rightArrow)
    }
}

class CardCell : UICollectionViewCell {
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
        
        bigTitleLabel.frame = CGRectMake(0, 62, self.frame.size.width, 35)
        bigTitleLabel.center = CGPointMake(self.center.x, bigTitleLabel.center.y)
        bigTitleLabel.font = UIFont.boldSystemFontOfSize(42.0)
        bigTitleLabel.textColor = UIColor.whiteColor()
        bigTitleLabel.textAlignment = .Center
        bigTitleLabel.text = "$2,107"
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
        titleLabel.frame = CGRectMake(0, 11, self.frame.size.width, 30)
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
        
        self.setLabel(happiestCityLabel, atPosition: 41)
        self.setLabel(spendOnline, atPosition: 91)
        self.setLabel(happyFlow, atPosition: 141)
        self.setLabel(mostExpensiveCiy, atPosition: 191)
        
        happiestCityLabel.text = "My happiest city is Boston"
        spendOnline.text = "I spend more offline than online"
        happyFlow.text = "My happiness flow for offline is 85% which is 12% higher than last month"
        mostExpensiveCiy.text = "I shouldnt spend so much money in Worcester, Massachusetts"
    }
    
    private func setLabel(label: UILabel,atPosition y: CGFloat) {
        label.frame = CGRectMake(0, y, self.frame.size.width, 50)
        label.font = UIFont.boldSystemFontOfSize(15.0)
        label.textColor = UIColor.blackColor()
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
