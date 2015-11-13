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
    
   
    func getCashFlow() -> (Double)
    {
        //need to remove transfers as they shouldn't count
        //need to add ablilty to perform based on date being passed in
        //need to add ability to compare to previous month
       
        var cashFlowTotal: Double = 0
        let cashFlows = realm.objects(Transaction).filter("status > 0")
        for cashFlowItem in cashFlows
        {
            let convertedCF = cashFlowItem.amount * -1
            cashFlowTotal += convertedCF
            print("\(cashFlowItem.status): \(cashFlowItem.name) + \(cashFlowItem.amount)")
        }
        return cashFlowTotal
        
    }
    
   
    func getMoneySpent() -> (Double)
    {
        //need to remove transfers as they shouldn't count
        //need to add ablilty to perform based on date being passed in
        //need to add ability to compare to previous month
        
        var moneySpentTotal: Double = 0
        let cashFlows = realm.objects(Transaction).filter("status > 0 AND amount > 0")
        for cashFlowItem in cashFlows
        {
              moneySpentTotal += cashFlowItem.amount
              print("\(cashFlowItem.status): \(cashFlowItem.name) + \(cashFlowItem.amount)")
           
        }
        return moneySpentTotal
        
    }

    
    func getTypeSpent() -> (Double, Double, Double)
    {
        //need to remove transfers as they shouldn't count
        //need to add ablilty to perform based on date being passed in
        //need to add ability to compare to previous month
        
        var digitalSpentTotal: Double = 0
        var specialSpentTotal: Double = 0
        var placeSpentTotal: Double = 0
        
        let cashFlows = realm.objects(Transaction).filter("status > 0 and amount > 0")
        for cashFlowItem in cashFlows
        {
            if cashFlowItem.placeType == "digital"
            {
            digitalSpentTotal += cashFlowItem.amount
            print("Digital: \(cashFlowItem.status): \(cashFlowItem.name) + \(cashFlowItem.amount)")
            }
            
            if cashFlowItem.placeType == "special"
            {
                specialSpentTotal += cashFlowItem.amount
                print("Special: \(cashFlowItem.status): \(cashFlowItem.name) + \(cashFlowItem.amount)")
            }
            
            if cashFlowItem.placeType == "place"
            {
                placeSpentTotal += cashFlowItem.amount
                print("Place: \(cashFlowItem.status): \(cashFlowItem.name) + \(cashFlowItem.amount)")
            }
                
        }
        return (digitalSpentTotal, placeSpentTotal, specialSpentTotal)
        
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
        
        var transactionCount = 0
        
        for _ in users {
            let user_access_token  = keyChainStore.get("access_token")
            cService.updateAccount(user_access_token!, dayLength: dayLength) { (response) in
                if let accounts = response["accounts"] as? [NSDictionary] {
                    try! realm.write {
                        // Save one Venue object (and dependents) for each element of the array
                        for account in accounts {
                           
                            realm.create(Account.self, value: account, update: true)
                           
                            print("saved accounts")

                            
                            
                        }
                    }
                    
                    let transactions = response["transactions"] as! [NSDictionary]
                    // Save one Venue object (and dependents) for each element of the array
                    for transaction in transactions {
                        // println("saved")
                        try!   realm.write {
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
                                else if (transactionCount < 20)
                                {
                                    newTrans.status = 0
                                    transactionCount += 1
                                }
                                else
                                {
                                     newTrans.status = -1
                                }
                            
                                
                            }
                            else //doesn't have a cateogry
                            {
                                // set first twenty transations to status of 
                                
                                
                                if (dictAmount < 1)
                                {  newTrans.status = 86 }
                                else if (transactionCount < 20)
                                {
                                    newTrans.status = 0
                                    transactionCount += 1

                                }
                                else
                                {
                                    newTrans.status = -1
                                }
                                
                                
                            }
                            
                        }
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
        let regex2:NSRegularExpression = try! NSRegularExpression(pattern: "^[0-9]*", options: NSRegularExpressionOptions.CaseInsensitive)
        let modString = regex.stringByReplacingMatchesInString(name, options: [], range: NSMakeRange(0, stringlength), withTemplate: "")
        let stringlength2 = modString.characters.count
        let modString2 = regex2.stringByReplacingMatchesInString(modString, options: [], range: NSMakeRange(0, stringlength2), withTemplate: "")
        var trimmedStr = modString2.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if trimmedStr.characters.count == 0 {
            trimmedStr = "Missing Name"
        }
        return trimmedStr
    }
    
    
    //func pathForBuggyWKWebView(filePath: String?) -> String? {
    //    let fileMgr = NSFileManager.defaultManager()
    //    let tmpPath = NSTemporaryDirectory().stringByAppendingPathComponent("www")
    //    let error: NSErrorPointer = nil
    //    do {
    //        try fileMgr.createDirectoryAtPath(tmpPath, withIntermediateDirectories: true, attributes: nil)
    //    } catch let error1 as NSError {
    //        error.memory = error1
    //        print("Couldn't create www subdirectory. \(error)")
    //        return nil
    //    }
    //    let dstPath = tmpPath.stringByAppendingPathComponent(filePath!.lastPathComponent)
    //    if !fileMgr.fileExistsAtPath(dstPath) {
    //        do {
    //            try fileMgr.copyItemAtPath(filePath!, toPath: dstPath)
    //        } catch let error1 as NSError {
    //            error.memory = error1
    //            print("Couldn't copy file to /tmp/www. \(error)")
    //            return nil
    //        }
    //    }
    //    return dstPath
    //}
    //
    
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
    
}



extension NSDate {
    
    func startOfMonth() -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let currentDateComponents = calendar.components([.Year, .Month], fromDate: self)
        let startOfMonth = calendar.dateFromComponents(currentDateComponents)
        return startOfMonth
    }
    
    func dateByAddingMonths(monthsToAdd: Int) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let months = NSDateComponents()
        months.month = monthsToAdd
        return calendar.dateByAddingComponents(months, toDate: self, options: [])
    }
    
    func endOfMonth() -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        if let plusOneMonthDate = dateByAddingMonths(1) {
            let plusOneMonthDateComponents = calendar.components([.Year, .Month], fromDate: plusOneMonthDate)
            let endOfMonth = calendar.dateFromComponents(plusOneMonthDateComponents)?.dateByAddingTimeInterval(-1)
            return endOfMonth
        }
        return nil
    }
}