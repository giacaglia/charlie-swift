//
//  CardsViewController.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 11/12/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//


import Foundation

class CardsViewController : UIViewController {
    
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    let titleArray = ["My Happy Flow", "My Cash Flow", "My Spending", "My Locations", "My Habits"]
    
    private func genAttributedString(string: String, coloredString:String, color: UIColor) -> NSAttributedString {
        let range = (string as NSString).rangeOfString(coloredString)
        let attributedString = NSMutableAttributedString(string:string)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: color , range: range)
        return attributedString
    }
    
    func genSubtitleArray(happyFlow :Double, cashFlow: String, spent: String, city: String, online: String) -> [NSAttributedString] {
        let colorHappyFlow : UIColor
        if happyFlow >= 0.5 {
            colorHappyFlow = listGreen }
        else {
            colorHappyFlow = listRed
        }
        let attributedString = genAttributedString("\(happyFlow * 100)% \n up 5% points from this time last month", coloredString: "\(happyFlow * 100)%", color: colorHappyFlow)
        let attributedString2 = genAttributedString("\(cashFlow) \n up 5% from this time last month", coloredString: "\(cashFlow)", color: listGreen)
        let attributedString3 = genAttributedString("\(spent) \n up $34.00 from this time last month", coloredString: "\(spent)", color: listGreen)
        let attributedString4 = genAttributedString("You spent most of your money in \(city) and it was worth it 70% of the time. Your spending in Gloucester is generally worth it, but try to avoid spending in Worcester.", coloredString: "\(city)", color: listGreen)
        let attributedString5 = genAttributedString("Most of the money you spent \(online) was not worth it.", coloredString: "\(online)", color: listRed)
        return [attributedString, attributedString2, attributedString3, attributedString4, attributedString5]
    }
    var subtitleArray : [NSAttributedString] = []
    
    
    override func viewDidLoad() {
//        let happyFlow = cHelp.
        let cashFlow =  cHelp.getCashFlow()
        let moneySpent =  cHelp.getMoneySpent()
        let (digitalSpentTotal, placeSpentTotal, specialSpentTotal) = cHelp.getTypeSpent()
        let cityMostSpent = cHelp.getCityMostSpentMoney()
        let happyFlow = cHelp.getHappyFlow()
        print("happy flow: \(happyFlow * 100)")
        
        subtitleArray = genSubtitleArray(happyFlow, cashFlow: "$\(cashFlow)", spent:"$\(moneySpent)", city: cityMostSpent, online: "online")
        self.collectionView.registerClass(CardCell.self, forCellWithReuseIdentifier: CardCell.cellIdentifier())
        self.collectionView.collectionViewLayout = CardLayout()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
}


extension CardsViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCellWithReuseIdentifier(CardCell.cellIdentifier(), forIndexPath: indexPath) as! CardCell
        cell.titleLabel.text = titleArray[indexPath.row]
        cell.subtitleLabel.attributedText = subtitleArray[indexPath.row]
        return cell
    }
}

class CardCell : UICollectionViewCell {
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
        titleLabel.textAlignment = .Center
        titleLabel.center = CGPointMake(self.center.x, titleLabel.center.y)
        self.contentView.addSubview(titleLabel)
        
        let lineView = UIView(frame: CGRectMake(0, 46, 40, 5))
        lineView.center = CGPointMake(self.center.x, lineView.center.y)
        lineView.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
        self.contentView.addSubview(lineView)
        
        subtitleLabel.frame = CGRectMake(0, 52, UIScreen.mainScreen().bounds.size.width - 70, 100)
        subtitleLabel.center = CGPointMake(self.center.x, subtitleLabel.center.y)
        subtitleLabel.textColor = UIColor(red: 77/255.0, green: 77/255.0, blue: 77/255.0, alpha: 1.0)
        subtitleLabel.textAlignment = .Center
        subtitleLabel.numberOfLines = 0
        self.contentView.addSubview(subtitleLabel)
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
        self.itemSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width - 20, 160)
        self.scrollDirection = .Vertical
    }
}