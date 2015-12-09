//
//  RewardViewController.swift
//  charlie
//
//  Created by Giuliano Giacaglia on 10/6/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//

import Foundation
import Charts

class RewardViewController : UIViewController {
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var happyRewardPercentage: UILabel!
    var transactionItemsActedUpon = realm.objects(Transaction).filter(actedUponPredicate).sorted("date", ascending: false)
    var typeOfView : RewardType = .HappyFlowType
    enum RewardType  {
       case HappyFlowType, CashFlowType, TripLocationsType
    }
    
    override func viewDidLoad() {
        charlieAnalytics.track("Show Reward")
        
         self.title = "Your Happy Flow"
        
        if transactionItemsActedUpon.count == 0{
            chartView.hidden = true
            return
        }
        chartView.hidden = false
        
        if typeOfView == .HappyFlowType {
            fillUpWithHappyPercentage()
        }
        else {
            let cashFlow = fillUpWithCashFlow(self.chartView!)
            happyRewardPercentage.text = "$\(cashFlow)"
        }
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    
    private func setChart(chart: LineChartView!, dataPoints: [String], values: [Double]) {
        chart.noDataText = "You need to provide data for the chart."
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Weeks")
        lineChartDataSet.drawFilledEnabled = true
        lineChartDataSet.fillColor = listBlue
        lineChartDataSet.drawValuesEnabled = true
        lineChartDataSet.drawCirclesEnabled = true
        lineChartDataSet.drawCubicEnabled = true
        
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        chart!.gridBackgroundColor = lightBlue
        chart!.backgroundColor = lightBlue
        chart!.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        chart!.leftAxis.drawGridLinesEnabled = false
        chart!.leftAxis.labelTextColor = UIColor.whiteColor()
        chart!.leftAxis.labelCount = 4
        chart!.leftAxis.axisLineWidth = 10
        chart!.leftAxis.valueFormatter = NSNumberFormatter()
        chart!.leftAxis.valueFormatter!.minimumFractionDigits = 0
        chart!.leftAxis.labelFont = UIFont (name: "Helvetica Neue", size: 16)!
        chart!.leftAxis.axisLineColor = lightBlue
        chart!.pinchZoomEnabled = true
        chart!.rightAxis.enabled = false
        chart!.rightAxis.drawGridLinesEnabled = false
        chart!.xAxis.labelPosition = .Bottom
        chart!.xAxis.enabled = true
        chart!.xAxis.drawGridLinesEnabled = false
        chart!.xAxis.axisLineColor = lightBlue
        chart!.xAxis.labelTextColor = UIColor.whiteColor()
        chart!.xAxis.labelFont = UIFont (name: "Helvetica Neue", size: 16)!
        chart!.legend.enabled = false
        chart!.descriptionText = ""
        chart!.data = lineChartData
        chart!.maxVisibleValueCount = 3
    }
    
    func stripCents(currency: String) -> String {
        let stringLength = currency.characters.count
        let substringIndex = stringLength - 3
        return currency.substringToIndex(currency.startIndex.advancedBy(substringIndex))
    }
}


//Cash Flow Type
extension RewardViewController {
    func fillUpWithCashFlow(chart: LineChartView!) -> Int {
        transactionItemsActedUpon = realm.objects(Transaction).filter(actedUponPredicate).sorted("date", ascending: false)
        let lastTransaction = transactionItemsActedUpon[0].date as NSDate
        let transactionCount = transactionItemsActedUpon.count - 1
        let firstTransaction = transactionItemsActedUpon[transactionCount].date as NSDate
        
        var months = [String()]
        var unitsSold = [Double()]
        
        let transactionsDateDifference = NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: firstTransaction, toDate: lastTransaction, options: []).month
        let cashFlow : Double = 0.0
        if transactionsDateDifference >= 1 {
            var i = 2
            while i > -1 {
                let (cashFlow, beginDate) = getCashFlowMonthly(lastTransaction, monthsFrom: i)
                let dateFormatter = NSDateFormatter()
                //the "M/d/yy, H:mm" is put together from the Symbol Table
                dateFormatter.dateFormat = "M/d"
                let dayTimePeriodFormatter = NSDateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMM"
                let dateString = dayTimePeriodFormatter.stringFromDate(beginDate)
                unitsSold.append(Double(cashFlow))
                months.append(dateString)
                i -= 1
                setChart(chart, dataPoints: months, values: unitsSold)
            }
            return Int(cashFlow)
        }
        else {
            var i = 12
            var week = 1
            while i > -1 {
                let (cashFlow, endDate) = getCashFlow(lastTransaction, weeksFrom: i)
                let dateFormatter = NSDateFormatter()
                //the "M/d/yy, H:mm" is put together from the Symbol Table
                dateFormatter.dateFormat = "M/d"
                let endDateFormatted = dateFormatter.stringFromDate(endDate)
                
                unitsSold.append(Double(cashFlow))
                months.append("\(endDateFormatted )")
                i -= 1
                week += 1
                setChart(chart, dataPoints: months, values: unitsSold)
            }
            return Int(cashFlow)
        }
    }
    
    private func getCashFlowMonthly(date: NSDate, monthsFrom: Int) -> (cashFlow: Double, beginDate: NSDate) {
        var newDate = NSDate()
        var startDate = NSDate()
        var endDate = NSDate()
        
        if monthsFrom > 0 {
            newDate = dateByAddingMonths(monthsFrom * -1, date: date)!
            
            startDate = startOfMonth(newDate)!
            endDate = endOfMonth(newDate)!
        }
        else {
            startDate = startOfMonth(date)!
            endDate = endOfMonth(date)!
        }
        
        let chartHappyWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 1 ", startDate, endDate)
        let chartSadWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 2 ", startDate, endDate)
        let chartHappyWeek1Items = realm.objects(Transaction).filter(chartHappyWeek1)
        let chartSadWeek1Items = realm.objects(Transaction).filter(chartSadWeek1)
        
        var chartCashFlowWeek1Percentage : Double = 0.0
        for trans in chartHappyWeek1Items {
            chartCashFlowWeek1Percentage += trans.amount
        }
        for trans in chartSadWeek1Items {
            chartCashFlowWeek1Percentage += trans.amount
        }
        return (chartCashFlowWeek1Percentage, startDate)
    }
    
    private func getCashFlow(date: NSDate, weeksFrom: Int) -> (happyPerc: Double, endDate: NSDate) {
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -(weeksFrom * 7), toDate: date, options: [])!
        
        let components: NSDateComponents = NSDateComponents()
        components.setValue(6, forComponent: NSCalendarUnit.Day)
        
        let first: NSDate = firstDayOfWeek(startDate)
        let expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: first, options: NSCalendarOptions(rawValue: 0))
        
        let chartHappyWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 1 ", first, expirationDate!)
        let chartSadWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 2 ", first, expirationDate!)
        let chartHappyWeek1Items = realm.objects(Transaction).filter(chartHappyWeek1)
        let chartSadWeek1Items = realm.objects(Transaction).filter(chartSadWeek1)
        
        var chartCashFlowWeek1Percentage : Double = 0.0
        for trans in chartHappyWeek1Items {
            chartCashFlowWeek1Percentage += trans.amount
        }
        for trans in chartSadWeek1Items {
            chartCashFlowWeek1Percentage += trans.amount
        }
        return (chartCashFlowWeek1Percentage, expirationDate!)
    }


}


//Happy Percentage Type
extension RewardViewController {
    private func fillUpWithHappyPercentage() {
        print("Happy Percentage")
        let happyScoreViewed =  defaults.stringForKey("happyScoreViewed")
        let lastTransaction = transactionItemsActedUpon[0].date as NSDate
        let transactionCount = transactionItemsActedUpon.count - 1
        let firstTransaction = transactionItemsActedUpon[transactionCount].date as NSDate
        
        var months = [String()]
        var unitsSold = [Double()]
        
        let transactionsDateDifference = NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: firstTransaction, toDate: lastTransaction, options: []).month
        
        if happyScoreViewed == "0"  {
            defaults.setValue("1", forKey: "happyScoreViewed")
            defaults.synchronize()
        }
        
        if transactionsDateDifference >= 1 {
            var i = 2
            while i > -1 {
                let (happyPer, beginDate, _) = getHappyPercentageMonthly(lastTransaction, monthsFrom: i)
                let dateFormatter = NSDateFormatter()
                //the "M/d/yy, H:mm" is put together from the Symbol Table
                dateFormatter.dateFormat = "M/d"
                let dayTimePeriodFormatter = NSDateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMM"
                let dateString = dayTimePeriodFormatter.stringFromDate(beginDate)
                
                if happyPer >= 0 {
                    unitsSold.append(Double(happyPer * 100))
                    months.append(dateString)
                    if i == 0 {
                        let happyPercentage = Int(happyPer * 100)
                        happyRewardPercentage.text = "\(happyPercentage)%"
                    }
                }
                i -= 1
                setChart(self.chartView!, dataPoints: months, values: unitsSold)
            }
        }
        else {
            var i = 12
            var week = 1
            while i > -1 {
                let (happyPer, _, endDate) = getHappyPercentage(lastTransaction, weeksFrom: i)
                let dateFormatter = NSDateFormatter()
                //the "M/d/yy, H:mm" is put together from the Symbol Table
                dateFormatter.dateFormat = "M/d"
                let endDateFormatted = dateFormatter.stringFromDate(endDate)
                
                if happyPer >= 0 {
                    unitsSold.append(Double(happyPer * 100))
                    months.append("\(endDateFormatted )")
                    if i == 0 {
                        let happyPercentage = Int(happyPer * 100)
                        happyRewardPercentage.text = "\(happyPercentage)%"
                    }
                }
                i -= 1
                week += 1
                
                setChart(self.chartView!, dataPoints: months, values: unitsSold)
            }
        }
    }

    private func getHappyPercentageMonthly(date: NSDate, monthsFrom: Int) -> (happyPerc: Double, beginDate: NSDate, endDate: NSDate) {
        var newDate = NSDate()
        var startDate = NSDate()
        var endDate = NSDate()
        
        if monthsFrom > 0 {
            newDate = dateByAddingMonths(monthsFrom * -1, date: date)!
            
            startDate = startOfMonth(newDate)!
            endDate = endOfMonth(newDate)!
        }
        else {
            startDate = startOfMonth(date)!
            endDate = endOfMonth(date)!
        }
        
        let chartHappyWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 1 ", startDate, endDate)
        let chartSadWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 2 ", startDate, endDate)
        let chartHappyWeek1Items = realm.objects(Transaction).filter(chartHappyWeek1)
        let chartSadWeek1Items = realm.objects(Transaction).filter(chartSadWeek1)
        //let happySum = chartItems.sum("amount") as Int
        
        let chartHappyWeek1Percentage = Double(chartHappyWeek1Items.count)  / Double((chartHappyWeek1Items.count + chartSadWeek1Items.count)) as Double
        
        print("First = \(startDate) and last \(endDate)")
        print("Happy % \(chartHappyWeek1Percentage)")
        return (chartHappyWeek1Percentage, startDate, endDate)
    }
    
    private func getHappyPercentage(date: NSDate, weeksFrom: Int) -> (happyPerc: Double, beginDate: NSDate, endDate: NSDate) {
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -(weeksFrom * 7), toDate: date, options: [])!
        
        let components: NSDateComponents = NSDateComponents()
        components.setValue(6, forComponent: NSCalendarUnit.Day)
        
        let first: NSDate = firstDayOfWeek(startDate)
        let expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: first, options: NSCalendarOptions(rawValue: 0))
        
        //println("DATES: \(first), \(expirationDate)")
        let chartHappyWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 1 ", first, expirationDate!)
        let chartSadWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 2 ", first, expirationDate!)
        let chartHappyWeek1Items = realm.objects(Transaction).filter(chartHappyWeek1)
        let chartSadWeek1Items = realm.objects(Transaction).filter(chartSadWeek1)
        //let happySum = chartItems.sum("amount") as Int
        
        let chartHappyWeek1Percentage = Double(chartHappyWeek1Items.count)  / Double((chartHappyWeek1Items.count + chartSadWeek1Items.count)) as Double
        
        print("First = \(first) and last \(expirationDate)")
        print("Happy % \(chartHappyWeek1Percentage)")
        return (chartHappyWeek1Percentage, first, expirationDate!)
    }

}

// NSDate helpers
extension RewardViewController {
    func firstDayOfWeek(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([.Year, .Month, .WeekOfMonth], fromDate: date)
        dateComponents.weekday = 1
        return calendar.dateFromComponents(dateComponents)!
    }
    
    func startOfMonth(date: NSDate) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let currentDateComponents = calendar.components([.Year, .Month, .WeekOfMonth], fromDate: date)
        let startOfMonth = calendar.dateFromComponents(currentDateComponents)
        return startOfMonth
    }
    
    func dateByAddingMonths(monthsToAdd: Int, date: NSDate) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let months = NSDateComponents()
        months.month = monthsToAdd
        return calendar.dateByAddingComponents(months, toDate: date, options: [])
    }
    
    func endOfMonth(date: NSDate) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        if let plusOneMonthDate = dateByAddingMonths(1, date: date) {
            let plusOneMonthDateComponents = calendar.components([.Year, .Month], fromDate: plusOneMonthDate)
            
            let endOfMonth = calendar.dateFromComponents(plusOneMonthDateComponents)?.dateByAddingTimeInterval(-86402)
            
            return endOfMonth
        }
        return nil
    }
}