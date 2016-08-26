//
//  ReportCardCell.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 11/6/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//

import Foundation
import Charts

class ReportCardCell : UITableViewCell {
    var leftIcon = UIImageView()
    var nameLabel = UILabel()
    var priceLabel = UILabel()
    var rightArrow = UIImageView()
    var happyFlowNumber = UILabel()
    var happyLabel = UILabel()
    var lineChart = LineChartView()
    
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
    
    fileprivate func setup() {
        self.contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 74)
        
        leftIcon = UIImageView(frame: CGRect(x: 5, y: 0, width: 20, height: 20))
        leftIcon.center = CGPoint(x: leftIcon.center.x, y: self.contentView.center.y)
        leftIcon.contentMode = .scaleAspectFit
        self.contentView.addSubview(leftIcon)
        
        nameLabel = UILabel(frame: CGRect(x: 30, y: 0, width: 200, height: 20))
        nameLabel.center = CGPoint(x: nameLabel.center.x, y: self.contentView.center.y)
        nameLabel.textColor = RGB(75, green: 75, blue: 75)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        self.contentView.addSubview(nameLabel)
        
        priceLabel = UILabel(frame: CGRect(x: self.contentView.frame.size.width - 15 - 15 - 5 - 200, y: 30, width: 200, height: 30))
        priceLabel.center = CGPoint(x: priceLabel.center.x, y: self.contentView.center.y)
        priceLabel.textColor = listBlue
        priceLabel.textAlignment = .right
        priceLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        self.contentView.addSubview(priceLabel)
        
        rightArrow = UIImageView(frame: CGRect(x: self.contentView.frame.size.width - 15 - 15, y: 0, width: 15, height: 15))
        rightArrow.center = CGPoint(x: rightArrow.center.x, y: self.contentView.center.y)
        rightArrow.contentMode = .scaleAspectFit
        rightArrow.image = UIImage(named: "rightArrow")
        self.contentView.addSubview(rightArrow)
        
        let rewardVC = RewardViewController()
        rewardVC.fillUpWithCashFlow(lineChart)
        lineChart.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200)
        lineChart.isHidden = true
        lineChart.gridBackgroundColor = UIColor.white
        lineChart.backgroundColor = UIColor.white
        lineChart.leftAxis.enabled = false
        lineChart.pinchZoomEnabled = false
        lineChart.xAxis.enabled = false
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.axisLineColor = UIColor.clear
        lineChart.xAxis.labelTextColor = UIColor.clear
        self.contentView.addSubview(lineChart)
        
        happyFlowNumber = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        happyFlowNumber.center = CGPoint(x: self.contentView.center.x, y: 80)
        happyFlowNumber.textColor = listBlue
        happyFlowNumber.textAlignment = .center
        happyFlowNumber.font = UIFont(name: "HelveticaNeue-Medium", size: 60)
        self.contentView.addSubview(happyFlowNumber)
        
        happyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        happyLabel.center = CGPoint(x: self.contentView.center.x, y: 120)
        happyLabel.textColor = listBlue
        happyLabel.textAlignment = .center
        happyLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        happyLabel.text = "HAPPY FLOW"
        self.contentView.addSubview(happyLabel)
    }
    
    func setupByType(_ type: ReportCardType) {
        happyFlowNumber.isHidden = true
        happyLabel.isHidden = true
        if type == .happyFlowType {
            self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200)
            self.contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200)
            rightArrow.isHidden = true
            happyFlowNumber.isHidden = false
            happyFlowNumber.text = "50%"
            happyLabel.isHidden = false
            lineChart.isHidden = false
        }
        else if type == .cashFlowType {
            nameLabel.text = "CASH FLOW"
            leftIcon.image = UIImage(named: "cashFlow")
            priceLabel.text = "$4,000"
            rightArrow.isHidden = false
        }
        else if type == .locationType {
            nameLabel.text = "POPULAR LOCATIONS"
            leftIcon.image = UIImage(named: "location")
            priceLabel.text = "New York City"
            rightArrow.isHidden = false
        }
    }
}
