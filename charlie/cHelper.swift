//
//  cHelper.swift
//  charlie
//
//  Created by James Caralis on 7/3/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import Foundation
import RealmSwift
import CloudKit

class cHelper {
    func dateByAddingMonths(monthsToAdd: Int, date: NSDate) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let months = NSDateComponents()
        months.month = monthsToAdd
        return calendar.dateByAddingComponents(months, toDate: date, options: [])
    }
    
    func getIncome(startDate startDate: NSDate, endDate: NSDate) -> Double {
        let incomePredicate = NSPredicate(format: "status = 86 and date >= %@ and date <= %@", startDate, endDate)

        let incomeTransactions = realm.objects(Transaction).filter(incomePredicate)
        var totalAmount = 0.0
        for trans in incomeTransactions {
            totalAmount += trans.amount
            print("INCOME: \(trans.status) - \(trans.categories?.categories) \(trans.name) - \(trans.amount)")
        }
        return totalAmount * -1
    }
    
    func getSpending(startDate startDate: NSDate, endDate: NSDate) -> Double {
        let incomePredicate = NSPredicate(format: "status < 5 and date >= %@ and date <= %@", startDate, endDate)
        let incomeTransactions = realm.objects(Transaction).filter(incomePredicate)
        
        var totalAmount = 0.0
        for trans in incomeTransactions {
            totalAmount += trans.amount
        }
        return totalAmount
    }
    
    
    func getHappyPercentageCompare(startMonth: NSDate, isCurrentMonth:Bool) -> (happyPerc: Double, happyComperePerc: Double) {
        var today = NSDate()
        var compareEndLastMonth = NSDate()
        var compareEndLastMonthTemp = NSDate()

        
        if isCurrentMonth {
            //if current month then compare month to day else month to month
            today = startMonth
            compareEndLastMonth = dateByAddingMonths(-1, date: today)!
        }
        else {
            today = startMonth.endOfMonth()!
            compareEndLastMonthTemp = (dateByAddingMonths(-1, date: today))!
            compareEndLastMonth = compareEndLastMonthTemp.endOfMonth()!
        }
        
        let beginingThisMonth = today.startOfMonth()
        let beginingLastMonth = dateByAddingMonths(-1, date: beginingThisMonth!)! as NSDate
       
        let currentHappyMonthPrediate = NSPredicate(format: "date between {%@,%@} AND status = 1", beginingThisMonth!, today)
        let currentSadMonthPrediate = NSPredicate(format: "date between {%@,%@} AND status = 2 ", beginingThisMonth!, today)
        let lastHappyMonthPrediate = NSPredicate(format: "date between {%@,%@} AND status = 1", beginingLastMonth, compareEndLastMonth)
        let lastSadMonthPrediate = NSPredicate(format: "date between {%@,%@} AND status = 2 ", beginingLastMonth, compareEndLastMonth)
        
        let currentHappyMonth = realm.objects(Transaction).filter(currentHappyMonthPrediate)
        let currentSadMonth = realm.objects(Transaction).filter(currentSadMonthPrediate)
        let lastHappyMonth = realm.objects(Transaction).filter(lastHappyMonthPrediate)
        let lastSadMonth = realm.objects(Transaction).filter(lastSadMonthPrediate)
        
        let currentHappyMonthPercentage = Double(currentHappyMonth.count)  / Double((currentHappyMonth.count + currentSadMonth.count)) as Double
        let lastHappyMonthPercentage = Double(lastHappyMonth.count)  / Double((lastHappyMonth.count + lastSadMonth.count)) as Double
       
        let happyFlowChange = ((currentHappyMonthPercentage - lastHappyMonthPercentage) / lastHappyMonthPercentage) * 100
        
        
       return (currentHappyMonthPercentage * 100, happyFlowChange)
        
        
 
    }
    
    
    
    
    
    
    func getHappyFlow() -> Double {
        let happyTrans = realm.objects(Transaction).filter("status = 1")
        let sadTrans = realm.objects(Transaction).filter("status = 2")
        let totalTransactions =  Double(sadTrans.count + happyTrans.count)
        if totalTransactions == 0 {
            return 0
        }
        let happyFlow = Double(happyTrans.count)/totalTransactions as Double

        return happyFlow * 100
    }
    
    func getCashFlow(startMonth: NSDate, isCurrentMonth:Bool) -> (cashFlowTotal: Double, Double, Double, Double, Double, Double) {
        var cashFlowTotal: Double = 0
        let cashFlows = realm.objects(Transaction).sorted("date", ascending: true)
        var cashFlows1Predicate: NSPredicate = NSPredicate()
        var cashFlows2Predicate: NSPredicate = NSPredicate()
        var cashFlows1 = realm.objects(Transaction)
        var cashFlows2 = realm.objects(Transaction)
        var cashFlowTotal2: Double = 0
        if cashFlows.count == 0 {
           return (0, 0, 0, 0, 0, 0)
        }
        let oldestDate = cashFlows[0].date
        var today:NSDate = NSDate()
        var compareEndLastMonth:NSDate = NSDate()
        var compareEndLastMonthTemp:NSDate = NSDate()
        
        var moneySpent1:Double = 0
        var moneySpent2:Double = 0
        var income1:Double = 0
        var income2:Double = 0
        
        
        if isCurrentMonth //if current month then compare month to day else month to month
        {
            today = startMonth
            compareEndLastMonth = dateByAddingMonths(-1, date: today)!
        }
        else
        {
            today = startMonth.endOfMonth()!
            compareEndLastMonthTemp = (dateByAddingMonths(-1, date: today))!
            compareEndLastMonth = compareEndLastMonthTemp.endOfMonth()!
        }
        
        let beginingThisMonth = today.startOfMonth()
        let beginingLastMonth = dateByAddingMonths(-1, date: beginingThisMonth!)! as NSDate
        
    
        
        cashFlows1Predicate = NSPredicate(format:"date >= %@ and date <= %@ ", beginingThisMonth!, today)
        

        
        cashFlows1 = realm.objects(Transaction).filter(cashFlows1Predicate)
        
        if beginingLastMonth.compare(oldestDate) == .OrderedDescending
        {
            cashFlows2Predicate = NSPredicate(format: "date >= %@ and date <= %@", beginingLastMonth, compareEndLastMonth)
            cashFlows2 = realm.objects(Transaction).filter(cashFlows2Predicate)
            if cashFlows2.count > 0
            {
                for cashFlowItem in cashFlows2
                {
                    let convertedCF = cashFlowItem.amount * -1
                    cashFlowTotal2 += convertedCF
                
                    if cashFlowItem.amount > 0
                    {
                        moneySpent2 += cashFlowItem.amount
                    }
                    
                    if cashFlowItem.amount < -10
                    {
                        income2 += cashFlowItem.amount
                        print("INCOME: \(cashFlowItem.name) - \(income2)")
                    }
                }
            }
        }
  
        for cashFlowItem in cashFlows1
        {
            
            let convertedCF = cashFlowItem.amount * -1
            cashFlowTotal += convertedCF
        
            if cashFlowItem.amount > 0
            {
               moneySpent1 += cashFlowItem.amount
            }

            if cashFlowItem.amount < -10 //get rid of small savings transfers keep the change...
            {
                income1 += cashFlowItem.amount
            }
        }
    
        let moneySpentChange = ((moneySpent1 - moneySpent2) / moneySpent2) * 100
        let cashFlowChange = ((cashFlowTotal - cashFlowTotal2) / cashFlowTotal2) * 100
        let incomeChange = (((income1 * -1) -  (income2 * -1)) / (income2 * -1)) * 100
        
        return (cashFlowTotal, cashFlowChange * -1, moneySpent1, moneySpentChange, income1 * -1, incomeChange)
    }
    
    private func getMapLocationToTransactions() -> [String: [Transaction]] {
//        let today = NSDate()
//        let beginingThisMonth = startOfMonth(today)
//        let cityMostSpentPredicate:NSPredicate = NSPredicate(format: "status > 0 and status < 5 and date >= %@", beginingThisMonth!)
        let transactions = realm.objects(Transaction).filter(NSPredicate(format: "status > 0 and status < 5"))
        var mapCity : [String: [Transaction]] = [String: [Transaction]]()
        for trans in transactions {
            if let location = trans.meta?.location {
                let city = location.city
                if !city.isEmpty {
                    if mapCity.keys.contains(city) {
                        mapCity[city]?.append(trans)
                    }
                    else {
                        mapCity[city] = [trans]
                    }
                }
            }
        }
        return mapCity
    }
    
    func getCityMostSpentMoney() -> String {
        let locationToTransactions = getMapLocationToTransactions()
        if locationToTransactions.keys.count == 0 {
            return ""
        }
        var maxCity = locationToTransactions.keys.first
        for city in locationToTransactions.keys {
            if locationToTransactions[city]?.count  > locationToTransactions[maxCity!]?.count {
                maxCity = city
            }
        }
        return maxCity!
    }

    func getMostHappyCity() -> String {
        let locationToTransactions = getMapLocationToTransactions()
        if locationToTransactions.keys.count == 0 {
            return ""
        }
        var mostHappy = locationToTransactions.keys.first
        for city in locationToTransactions.keys {
            let transactions = locationToTransactions[city]
            let happyFlow = getHappyFlowForTransactions(transactions!)
            if happyFlow > getHappyFlowForTransactions(locationToTransactions[city]!) {
                mostHappy = city
            }
        }
        return mostHappy!
    }
    
    private func getHappyFlowForTransactions(transactions : [Transaction]) -> Double {
        let happyTrans = transactions.filter { (trans) -> Bool in
            return trans.status == 1
        }
        let sadTrans = transactions.filter { (trans) -> Bool in
            return trans.status == 2
        }

        let totalTransactions =  Double(sadTrans.count + happyTrans.count)
        if totalTransactions == 0 {
            return 0
        }
        let happyFlow = Double(happyTrans.count)/totalTransactions as Double
        
        return happyFlow * 100
    }
    
    
//    (digitalHappyFlow, digitalSpentPercentage, specialHappyFlow, specialSpentPercentage, placeHappyFlow, placeSpentPercentage)
    func getTypeSpent() -> (digitalHappyFlow: Double, digitalSpentPercentage: Double, specialHappyFlow:    Double, specialSpentPercentage: Double, placeHappyFlow: Double, placeSpentPercentage: Double) {
        //need to remove transfers as they shouldn't count
        
        //if data available is less than 35 days old than get current least popular placeTyle
        //else get least popular placeType for current month and least popular placeType for last month and calculate increase or decrease of least popular placeType
        
        //need to add ability to compare to previous month
        var digitalSpentTotal: Double = 0
        var digitalHappyTotal: Double = 0
        var digitalSadTotal: Double = 0
        
        var specialSpentTotal: Double = 0
        var specialHappyTotal: Double = 0
        var specialSadTotal: Double = 0
        
        var placeSpentTotal: Double = 0
        var placeHappyTotal:Double = 0
        var placeSadTotal: Double = 0
        
//        let beginingThisMonth = startOfMonth(NSDate())
//        let typeSpentPredicate = NSPredicate(format: "status > 0 and status < 5 and date >= %@", beginingThisMonth!)
        let typeSpentPredicate =  NSPredicate(format: "status > 0 and status < 5")
        
        let cashFlows = realm.objects(Transaction).filter(typeSpentPredicate)
        for cashFlowItem in cashFlows
        {
            if cashFlowItem.placeType == "digital"
            {
                digitalSpentTotal += cashFlowItem.amount
                if cashFlowItem.status == 1
                {
                    digitalHappyTotal += 1
                
                }
                if cashFlowItem.status == 2
                {
                    digitalSadTotal += 1
                        
                }
            //print("Digital: \(cashFlowItem.status): \(cashFlowItem.name) + \(cashFlowItem.amount)")
            }
            if cashFlowItem.placeType == "special"
            {
                print("Special: \(cashFlowItem.status): \(cashFlowItem.name) + \(cashFlowItem.amount)")
                
                specialSpentTotal += cashFlowItem.amount
                if cashFlowItem.status == 1
                {
                     specialHappyTotal += 1
                }
                if cashFlowItem.status == 2
                {
                    specialSadTotal += 1
                }
               
            }
            
            if cashFlowItem.placeType == "place"
            {
                placeSpentTotal += cashFlowItem.amount
                if cashFlowItem.status == 1
                {
                    placeHappyTotal += 1
                }
                if cashFlowItem.status == 2
                {
                    placeSadTotal += 1
                }
               // print("Place: \(cashFlowItem.status): \(cashFlowItem.name) + \(cashFlowItem.amount)")
            }
        }
        
        let digitalHappyFlow = Double(digitalHappyTotal) / Double((digitalHappyTotal + digitalSadTotal)) * 100 as Double
        let digitalSpentPercentage = digitalSpentTotal/(specialSpentTotal + digitalSpentTotal + placeSpentTotal) * 100 as Double
        
        let specialHappyFlow = Double(specialHappyTotal) / Double((specialHappyTotal + specialSadTotal)) * 100 as Double
        let specialSpentPercentage = specialSpentTotal/(specialSpentTotal + digitalSpentTotal + placeSpentTotal) * 100 as Double
        
        let placeHappyFlow = Double(placeHappyTotal) / Double((placeHappyTotal + placeSadTotal)) * 100 as Double
        let placeSpentPercentage = placeSpentTotal/(specialSpentTotal + digitalSpentTotal + placeSpentTotal) * 100 as Double

        return (digitalHappyFlow, digitalSpentPercentage, specialHappyFlow, specialSpentPercentage, placeHappyFlow, placeSpentPercentage)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func addUpdateResetAccount(type:Int, dayLength:Int, callback: Int->()) {
        let users = realm.objects(User)
        
        for _ in users {
            let user_access_token  = keyChainStore.get("access_token")
            cService.updateAccount(user_access_token!, dayLength: dayLength) { (response) in
                if let accounts = response["accounts"] as? [NSDictionary] {
                    try! realm.write {
                        // Save one Venue object (and dependents) for each element of the array
                        for account in accounts {
                            realm.create(Account.self, value: account, update: true)
                        }
                    }
                    
                    let transactions = response["transactions"] as! [NSDictionary]
                    // Save one Venue object (and dependents) for each element of the array
                    for transaction in transactions {
                        try! realm.write {
                            //get placeType
                            let placeTypeO = transaction.valueForKey("type")
                            let placeType = placeTypeO!.valueForKey("primary")
                            
                            transaction.setValue(placeType, forKeyPath: "placeType")
                            //clean up name
                            let dictName = transaction.valueForKey("name") as? String
                            transaction.setValue(self.cleanName(dictName!), forKey: "name")
                            //convert string to date before insert
                            let dictDate = transaction.valueForKey("date") as? String
                            transaction.setValue(self.convertDate(dictDate!), forKey: "date")
                            //check for deposits and remove
                            let dictAmount = transaction.valueForKey("amount") as? Double
                            //add category
                            
                            let newTrans =  realm.create(Transaction.self, value: transaction, update: true)
                            
                            //add category
                            if let category_id = transaction.valueForKey("category_id") as? String {
                                let predicate = NSPredicate(format: "id = %@", category_id)
                                let categoryToAdd = realm.objects(Category).filter(predicate)
                                newTrans.categories = categoryToAdd[0]
                                
                                //if category is one we don't want to count or amount is too small or negative
                                if (category_id == "21008000" || category_id == "21007001" || dictAmount < 1) {
                                    newTrans.status = 86 //sets status to ignore from totals
                                }
                                
                                
                            }
                            else //doesn't have a cateogry
                            {
                                // set first twenty transations to status of
                                if (dictAmount < 1)
                                {  newTrans.status = 86 }
                            }
                        }
                    }
                    
                    if realm.objects(Transaction).filter("status = 0").count == 0 && realm.objects(Transaction).filter("status = 1 or status = 2 ").count == 0
                    {
                        let nextUp = realm.objects(Transaction).filter("date >= %@ and date <= %@ and status = -1", NSDate().startOfMonth()!, NSDate()).sorted("date", ascending: false)
                        
                        
                        
                        let numItemsToLoad = 20
                        var loadCount = 0
                        realm.beginWrite()
                        for item in nextUp
                        {
                            if loadCount < numItemsToLoad {
                                let trans = item
                                trans.status = 0
                                loadCount += 1
                            }
                        }
                        try! realm.commitWrite()
                        
                    }
                    
                    let transactions_count = transactions.count
                    callback(transactions_count)
                }
                else {
                    callback(0)
                }
            }
        }
    }
    
    func getSettings(callback: Bool->()) {
        let container = CKContainer.defaultContainer()
        let publicData = container.publicCloudDatabase
        let query = CKQuery(recordType: "Settings", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        publicData.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil { // There is no error
                for result in results! {
                    if let client_id = result["client_id"] as? String,
                        let client_secret = result["client_secret"] as? String {
                        keyChainStore.set(client_id, key: "client_id")
                        keyChainStore.set(client_secret, key: "client_secret")
                        callback(true)
                    }
                }
            }
            else {
                print(error)
                callback(false)
            }
        }
    }
    
    func formatCurrency(currency: Double) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let numberFromField = currency
        return formatter.stringFromNumber(numberFromField)!
    }
    
    func convertDate(date:String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.dateFromString(date)!
    }
    
    func convertDateGroup(date:NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        return formatter.stringFromDate(date)
    }
    
    func cleanName(name:String) -> String{
        let stringlength = name.characters.count
        // var ierror: NSError?
        let regex:NSRegularExpression = try! NSRegularExpression(pattern: ".*\\*", options: NSRegularExpressionOptions.CaseInsensitive)
        let regex3:NSRegularExpression = try! NSRegularExpression(pattern: "^[0-9]*", options: NSRegularExpressionOptions.CaseInsensitive)
        let regex2:NSRegularExpression = try! NSRegularExpression(pattern: "P.*TERMINAL ", options: NSRegularExpressionOptions.CaseInsensitive)
        
        let modString = regex.stringByReplacingMatchesInString(name, options: [], range: NSMakeRange(0, stringlength), withTemplate: "")
        let stringlength2 = modString.characters.count
        
        
        let modString2 = regex2.stringByReplacingMatchesInString(modString, options: [], range: NSMakeRange(0, stringlength2), withTemplate: "")
        let stringlength3 = modString2.characters.count
        
        
        
        let modString3 = regex3.stringByReplacingMatchesInString(modString2, options: [], range: NSMakeRange(0, stringlength3), withTemplate: "")
        
        
        var trimmedStr = modString3.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if trimmedStr.characters.count == 0 {
            trimmedStr = "Missing Name"
        }
        return trimmedStr
    }
    
    func isiCloudAvalaible() -> Bool {
        let fileManager = NSFileManager.defaultManager()
        let cloudURL = fileManager.ubiquityIdentityToken
        if (cloudURL != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    func removeSpashImageView(view:UIView) {
        for subview in view.subviews {
            if subview.tag == 86 {
                subview.removeFromSuperview()
            }
        }
    }
    
    func splashImageView(view:UIView) {
        let imageView = UIImageView(frame: view.frame)
        let image = UIImage(named: "iTunesArtwork")
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.image = image
        imageView.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleWidth]
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.tag = 86
        view.addSubview(imageView)
    }
    
    func getKey() -> NSData {
        // Identifier for our keychain entry - should be unique for your application
        let keychainIdentifier = "io.Realm.EncryptionExampleKey"
        let keychainIdentifierData = keychainIdentifier.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        // First check in the keychain for an existing key
        var query: [NSString: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData,
            kSecAttrKeySizeInBits: 512,
            kSecReturnData: true
        ]

        // To avoid Swift optimization bug, should use withUnsafeMutablePointer() function to retrieve the keychain item
        // See also: http://stackoverflow.com/questions/24145838/querying-ios-keychain-using-swift/27721328#27721328
        var dataTypeRef: AnyObject?
        var status = withUnsafeMutablePointer(&dataTypeRef) { SecItemCopyMatching(query, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            return dataTypeRef as! NSData
        }
        
        // No pre-existing key from this application, so generate a new one
        let keyData = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64, UnsafeMutablePointer<UInt8>(keyData.mutableBytes))
        assert(result == 0, "Failed to get random bytes")
        
        // Store the key in the keychain
        query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData,
            kSecAttrKeySizeInBits: 512,
            kSecValueData: keyData
        ]
        
        status = SecItemAdd(query, nil)
        assert(status == errSecSuccess, "Failed to insert the new key in the keychain")
        
        return keyData
    }
    
    func getFirstSwipedTransaction() -> NSDate {
        let transactions = realm.objects(Transaction).filter(NSPredicate(format: "status > 0 and status < 5"))
        if (transactions.count == 0) {
            return NSDate()
        }
        var firstSwipedTrans = transactions.first
        for trans in transactions {
            if trans.date.compare((firstSwipedTrans?.date)!) == .OrderedAscending {
                firstSwipedTrans = trans
            }
        }
        return firstSwipedTrans!.date
    }
}



