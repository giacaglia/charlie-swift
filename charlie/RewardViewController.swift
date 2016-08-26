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
    var typeOfView : RewardType = .happyFlowType
    enum RewardType  {
       case happyFlowType, cashFlowType, tripLocationsType
    }
    
    override func viewDidLoad() {
        charlieAnalytics.track("Show Reward")
        
         self.title = "Your Happy Flow"
        
        if transactionItemsActedUpon.count == 0{
            chartView.isHidden = true
            return
        }
        chartView.isHidden = false
        
        if typeOfView == .happyFlowType {
            fillUpWithHappyPercentage()
        }
        else {
            let cashFlow = fillUpWithCashFlow(self.chartView!)
            happyRewardPercentage.text = "$\(cashFlow)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = lightBlue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
    }
    
    @IBAction func closePressed(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    
    fileprivate func setChart(_ chart: LineChartView!, dataPoints: [String], values: [Double]) {
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
        chart!.leftAxis.labelTextColor = UIColor.white
        chart!.leftAxis.labelCount = 4
        chart!.leftAxis.axisLineWidth = 10
        chart!.leftAxis.valueFormatter = NumberFormatter()
        chart!.leftAxis.valueFormatter!.minimumFractionDigits = 0
        chart!.leftAxis.labelFont = UIFont (name: "Helvetica Neue", size: 16)!
        chart!.leftAxis.axisLineColor = lightBlue
        chart!.pinchZoomEnabled = true
        chart!.rightAxis.enabled = false
        chart!.rightAxis.drawGridLinesEnabled = false
        chart!.xAxis.labelPosition = .bottom
        chart!.xAxis.enabled = true
        chart!.xAxis.drawGridLinesEnabled = false
        chart!.xAxis.axisLineColor = lightBlue
        chart!.xAxis.labelTextColor = UIColor.white
        chart!.xAxis.labelFont = UIFont (name: "Helvetica Neue", size: 16)!
        chart!.legend.enabled = false
        chart!.descriptionText = ""
        chart!.data = lineChartData
        chart!.maxVisibleValueCount = 3
    }
    
    func stripCents(_ currency: String) -> String {
        let stringLength = currency.characters.count
        let substringIndex = stringLength - 3
        return currency.substring(to: currency.characters.index(currency.startIndex, offsetBy: substringIndex))
    }
}


//Cash Flow Type
extension RewardViewController {
    func fillUpWithCashFlow(_ chart: LineChartView!) -> Int {
        transactionItemsActedUpon = realm.objects(Transaction).filter(actedUponPredicate).sorted("date", ascending: false)
        let lastTransaction = transactionItemsActedUpon[0].date as Date
        let transactionCount = transactionItemsActedUpon.count - 1
        let firstTransaction = transactionItemsActedUpon[transactionCount].date as Date
        
        var months = [String()]
        var unitsSold = [Double()]
        
        let transactionsDateDifference = NSCalendar.current.components(Calendar.monthSymbols, from: firstTransaction, to: lastTransaction, options: []).month
        let cashFlow : Double = 0.0
        if transactionsDateDifference >= 1 {
            var i = 2
            while i > -1 {
                let (cashFlow, beginDate) = getCashFlowMonthly(lastTransaction, monthsFrom: i)
                let dateFormatter = DateFormatter()
                //the "M/d/yy, H:mm" is put together from the Symbol Table
                dateFormatter.dateFormat = "M/d"
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMM"
                let dateString = dayTimePeriodFormatter.string(from: beginDate)
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
                let dateFormatter = DateFormatter()
                //the "M/d/yy, H:mm" is put together from the Symbol Table
                dateFormatter.dateFormat = "M/d"
                let endDateFormatted = dateFormatter.string(from: endDate)
                
                unitsSold.append(Double(cashFlow))
                months.append("\(endDateFormatted )")
                i -= 1
                week += 1
                setChart(chart, dataPoints: months, values: unitsSold)
            }
            return Int(cashFlow)
        }
    }
    
    fileprivate func getCashFlowMonthly(_ date: Date, monthsFrom: Int) -> (cashFlow: Double, beginDate: Date) {
        var newDate = Date()
        var startDate = Date()
        var endDate = Date()
        
        if monthsFrom > 0 {
            newDate = dateByAddingMonths(monthsFrom * -1, date: date)!
            
            startDate = startOfMonth(newDate)!
            endDate = endOfMonth(newDate)!
        }
        else {
            startDate = startOfMonth(date)!
            endDate = endOfMonth(date)!
        }
        
        let chartHappyWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 1 ", startDate as CVarArg, endDate as CVarArg)
        let chartSadWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 2 ", startDate as CVarArg, endDate as CVarArg)
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
    
    fileprivate func getCashFlow(_ date: Date, weeksFrom: Int) -> (happyPerc: Double, endDate: Date) {
        let startDate = NSCalendar.current.date(byAdding: .firstWeekday, value: -(weeksFrom * 7), to: date, options: [])!
        
        let components: DateComponents = DateComponents()
        (components as NSDateComponents).setValue(6, forComponent: Calendar.firstWeekday)
        
        let first: Date = firstDayOfWeek(startDate)
        let expirationDate = NSCalendar.current.date(byAdding: components, to: first, options: Calendar(identifier: 0))
        
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
    fileprivate func fillUpWithHappyPercentage() {
        print("Happy Percentage")
        let happyScoreViewed =  defaults.string(forKey: "happyScoreViewed")
        let lastTransaction = transactionItemsActedUpon[0].date as Date
        let transactionCount = transactionItemsActedUpon.count - 1
        let firstTransaction = transactionItemsActedUpon[transactionCount].date as Date
        
        var months = [String()]
        var unitsSold = [Double()]
        
        let transactionsDateDifference = NSCalendar.current.components(Calendar.monthSymbols, from: firstTransaction, to: lastTransaction, options: []).month
        
        if happyScoreViewed == "0"  {
            defaults.setValue("1", forKey: "happyScoreViewed")
            defaults.synchronize()
        }
        
        if transactionsDateDifference >= 1 {
            var i = 2
            while i > -1 {
                let (happyPer, beginDate, _) = getHappyPercentageMonthly(lastTransaction, monthsFrom: i)
                let dateFormatter = DateFormatter()
                //the "M/d/yy, H:mm" is put together from the Symbol Table
                dateFormatter.dateFormat = "M/d"
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMM"
                let dateString = dayTimePeriodFormatter.string(from: beginDate)
                
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
                let dateFormatter = DateFormatter()
                //the "M/d/yy, H:mm" is put together from the Symbol Table
                dateFormatter.dateFormat = "M/d"
                let endDateFormatted = dateFormatter.string(from: endDate)
                
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

    fileprivate func getHappyPercentageMonthly(_ date: Date, monthsFrom: Int) -> (happyPerc: Double, beginDate: Date, endDate: Date) {
        var newDate = Date()
        var startDate = Date()
        var endDate = Date()
        
        if monthsFrom > 0 {
            newDate = dateByAddingMonths(monthsFrom * -1, date: date)!
            
            startDate = startOfMonth(newDate)!
            endDate = endOfMonth(newDate)!
        }
        else {
            startDate = startOfMonth(date)!
            endDate = endOfMonth(date)!
        }
        
        let chartHappyWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 1 ", startDate as CVarArg, endDate as CVarArg)
        let chartSadWeek1 = NSPredicate(format: "date between {%@,%@} AND status = 2 ", startDate as CVarArg, endDate as CVarArg)
        let chartHappyWeek1Items = realm.objects(Transaction).filter(chartHappyWeek1)
        let chartSadWeek1Items = realm.objects(Transaction).filter(chartSadWeek1)
        //let happySum = chartItems.sum("amount") as Int
        
        let chartHappyWeek1Percentage = Double(chartHappyWeek1Items.count)  / Double((chartHappyWeek1Items.count + chartSadWeek1Items.count)) as Double
        
        print("First = \(startDate) and last \(endDate)")
        print("Happy % \(chartHappyWeek1Percentage)")
        return (chartHappyWeek1Percentage, startDate, endDate)
    }
    
    fileprivate func getHappyPercentage(_ date: Date, weeksFrom: Int) -> (happyPerc: Double, beginDate: Date, endDate: Date) {
        let startDate = NSCalendar.current.date(byAdding: .firstWeekday, value: -(weeksFrom * 7), to: date, options: [])!
        
        let components: DateComponents = DateComponents()
        (components as NSDateComponents).setValue(6, forComponent: Calendar.firstWeekday)
        
        let first: Date = firstDayOfWeek(startDate)
        let expirationDate = NSCalendar.current.date(byAdding: components, to: first, options: Calendar(identifier: 0))
        
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
    func firstDayOfWeek(_ date: Date) -> Date {
        let calendar = NSCalendar.current
        let dateComponents = (calendar as NSCalendar).components([.year, .monthSymbols, .weekOfMonth], from: date)
        dateComponents.weekday = 1
        return calendar.date(from: dateComponents)!
    }
    
    func startOfMonth(_ date: Date) -> Date? {
        let calendar = NSCalendar.current
        let currentDateComponents = (calendar as NSCalendar).components([.year, .monthSymbols, .weekOfMonth], from: date)
        let startOfMonth = calendar.date(from: currentDateComponents)
        return startOfMonth
    }
    
    func dateByAddingMonths(_ monthsToAdd: Int, date: Date) -> Date? {
        let calendar = NSCalendar.current
        var months = DateComponents()
        months.month = monthsToAdd
        return (calendar as NSCalendar).date(byAdding: months, to: date, options: [])
    }
    
    func endOfMonth(_ date: Date) -> Date? {
        let calendar = NSCalendar.current
        if let plusOneMonthDate = dateByAddingMonths(1, date: date) {
            let plusOneMonthDateComponents = (calendar as NSCalendar).components([.year, .monthSymbols], from: plusOneMonthDate)
            
            let endOfMonth = calendar.date(from: plusOneMonthDateComponents)?.addingTimeInterval(-86402)
            
            return endOfMonth
        }
        return nil
    }
}
