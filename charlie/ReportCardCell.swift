//
//  ReportCardCell.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 11/6/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//

import Foundation

class ReportCardCell : UITableViewCell {
    var leftIcon = UIImageView()
    var nameLabel = UILabel()
    var priceLabel = UILabel()
    var rightArrow = UIImageView()
    var happyFlowNumber = UILabel()
    var happyLabel = UILabel()
    
    class func cellIdentifier() -> String {
        return "reportCardCell"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 74)
        
        leftIcon = UIImageView(frame: CGRectMake(5, 0, 20, 20))
        leftIcon.center = CGPointMake(leftIcon.center.x, self.contentView.center.y)
        leftIcon.contentMode = .ScaleAspectFit
        self.contentView.addSubview(leftIcon)
        
        nameLabel = UILabel(frame: CGRectMake(30, 0, 200, 20))
        nameLabel.center = CGPointMake(nameLabel.center.x, self.contentView.center.y)
        nameLabel.textColor = RGB(75, green: 75, blue: 75)
        nameLabel.font = UIFont.boldSystemFontOfSize(14.0)
        self.contentView.addSubview(nameLabel)
        
        priceLabel = UILabel(frame: CGRectMake(self.contentView.frame.size.width - 15 - 15 - 5 - 200, 30, 200, 30))
        priceLabel.center = CGPointMake(priceLabel.center.x, self.contentView.center.y)
        priceLabel.textColor = listBlue
        priceLabel.textAlignment = .Right
        priceLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        self.contentView.addSubview(priceLabel)
        
        rightArrow = UIImageView(frame: CGRectMake(self.contentView.frame.size.width - 15 - 15, 0, 15, 15))
        rightArrow.center = CGPointMake(rightArrow.center.x, self.contentView.center.y)
        rightArrow.contentMode = .ScaleAspectFit
        rightArrow.image = UIImage(named: "rightArrow")
        self.contentView.addSubview(rightArrow)
        
        happyFlowNumber = UILabel(frame: CGRectMake(0, 0, 200, 50))
        happyFlowNumber.center = CGPointMake(self.contentView.center.x, 80)
        happyFlowNumber.textColor = listBlue
        happyFlowNumber.textAlignment = .Center
        happyFlowNumber.font = UIFont(name: "HelveticaNeue-Medium", size: 60)
        self.contentView.addSubview(happyFlowNumber)
        
        happyLabel = UILabel(frame: CGRectMake(0, 0, 200, 50))
        happyLabel.center = CGPointMake(self.contentView.center.x, 120)
        happyLabel.textColor = listBlue
        happyLabel.textAlignment = .Center
        happyLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        happyLabel.text = "HAPPY FLOW"
        self.contentView.addSubview(happyLabel)
    }
    
    func setupByType(type: ReportCardType) {
        happyFlowNumber.hidden = true
        happyLabel.hidden = true
        if type == .HappyFlowType {
            self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 200)
            self.contentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 200)
            rightArrow.hidden = true
            happyFlowNumber.hidden = false
            happyFlowNumber.text = "50%"
            happyLabel.hidden = false
        }
        else if type == .CashFlowType {
            nameLabel.text = "CASH FLOW"
            leftIcon.image = UIImage(named: "cashFlow")
            priceLabel.text = "$4,000"
            rightArrow.hidden = false
        }
        else if type == .LocationType {
            nameLabel.text = "POPULAR LOCATIONS"
            leftIcon.image = UIImage(named: "location")
            priceLabel.text = "New York City"
            rightArrow.hidden = false
        }
    }
}
