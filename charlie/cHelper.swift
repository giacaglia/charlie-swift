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
    
    
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    
    
    
    
    
    
    
    
    
    
    func addUpdateResetAccount(type:Int, dayLength:Int, callback: Int->())
    {
        
      let users = realm.objects(User)
        
       for user in users
       {
        
        let user_access_token  = keyChainStore.get("access_token")
        cService.updateAccount(user_access_token!, dayLength: dayLength)
                {
                    (response) in
                
               
                    
                
                  if let accounts = response["accounts"] as? [NSDictionary]
                  {
                        realm.write {
                            // Save one Venue object (and dependents) for each element of the array
                            for account in accounts {
                                realm.create(Account.self, value: account, update: true)
                                //println("saved accounts")
                            }
                        }
                        
                        
                        var transactions = response["transactions"] as! [NSDictionary]
                        // Save one Venue object (and dependents) for each element of the array
                        for transaction in transactions {
                           // println("saved")
                            realm.write {
                                //clean up name
                                var dictName = transaction.valueForKey("name") as? String
                                transaction.setValue(self.cleanName(dictName!), forKey: "name")
                                //convert string to date before insert
                                var dictDate = transaction.valueForKey("date") as? String
                                transaction.setValue(self.convertDate(dictDate!), forKey: "date")
                                //check for deposits and remove
                                var dictAmount = transaction.valueForKey("amount") as? Double
                                //add category
                                if let category_id = transaction.valueForKey("category_id") as? String
                                {
                                    let predicate = NSPredicate(format: "id = %@", category_id)
                                    var categoryToAdd = realm.objects(Category).filter(predicate)
                                    var newTrans =  realm.create(Transaction.self, value: transaction, update: true)
                                    newTrans.categories = categoryToAdd[0]
                                   
                                    
                                    if (category_id == "21008000" || category_id == "21007001" || dictAmount < 0)
                                    {
                                        newTrans.status = 86 //sets status to ignore from totals
                                    }
                                    else
                                    {
                                        if type == 99 //if type passed to this function is 99 then user wants to reset the data
                                        {
                                            newTrans.status = 0
                                        }
                                    }
                                }
                                else
                                {
                                    var newTrans =  realm.create(Transaction.self, value: transaction, update: true)
                                    if type == 99
                                    {
                                        newTrans.status = 0
                                    }
                                    
                                }
                                
                            }
                        }
                        let transactions_count = transactions.count
                        callback(transactions_count)
                    }
                    else
                    {
                       callback(0)
                    }
        
        
            }
        }
    }


    
    
    func getSettings(callback: Bool->())
    {
        
        
        let container = CKContainer.defaultContainer()
        let publicData = container.publicCloudDatabase
        
        let query = CKQuery(recordType: "Settings", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        publicData.performQuery(query, inZoneWithID: nil) { results, error in
            if error == nil { // There is no error
                
                if let client_id = results[0]["client_id"] as? String,
                    client_secret = results[0]["client_secret"] as? String
                {
                    keyChainStore.set(client_id, key: "client_id")
                    keyChainStore.set(client_secret, key: "client_secret")
                    callback(true)
                }
                
                
            }
            else {
                println(error)
                callback(false)
            }
            
        }
        
    }
    
    
    
    
func formatCurrency(currency: Double) -> String
{
    let formatter = NSNumberFormatter()
    formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    var numberFromField = currency
    return formatter.stringFromNumber(numberFromField)!
}


func convertDate(date:String) -> NSDate
{
    var dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.dateFromString(date)!
}


func cleanName(name:String) -> String{
    
    var stringlength = count(name)
    
    var ierror: NSError?
    var regex:NSRegularExpression = NSRegularExpression(pattern: ".*\\*", options: NSRegularExpressionOptions.CaseInsensitive, error: &ierror)!
    
    var regex2:NSRegularExpression = NSRegularExpression(pattern: "^[0-9]*", options: NSRegularExpressionOptions.CaseInsensitive, error: &ierror)!
    
    var modString = regex.stringByReplacingMatchesInString(name, options: nil, range: NSMakeRange(0, stringlength), withTemplate: "")
    
    var stringlength2 = count(modString)
    
    var modString2 = regex2.stringByReplacingMatchesInString(modString, options: nil, range: NSMakeRange(0, stringlength2), withTemplate: "")
    
    var trimmedStr = modString2.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    
    return trimmedStr
    
}


func pathForBuggyWKWebView(filePath: String?) -> String? {
    let fileMgr = NSFileManager.defaultManager()
    let tmpPath = NSTemporaryDirectory().stringByAppendingPathComponent("www")
    var error: NSErrorPointer = nil
    if !fileMgr.createDirectoryAtPath(tmpPath, withIntermediateDirectories: true, attributes: nil, error: error) {
        println("Couldn't create www subdirectory. \(error)")
        return nil
    }
    let dstPath = tmpPath.stringByAppendingPathComponent(filePath!.lastPathComponent)
    if !fileMgr.fileExistsAtPath(dstPath) {
        if !fileMgr.copyItemAtPath(filePath!, toPath: dstPath, error: error) {
            println("Couldn't copy file to /tmp/www. \(error)")
            return nil
        }
    }
    return dstPath
}
    
    
    func isiCloudAvalaible() -> Bool
    {
        
        
        let fileManager = NSFileManager.defaultManager()
        let cloudURL = fileManager.ubiquityIdentityToken
        if (cloudURL != nil)
        {
               return true
        }
        else
        {
            return false
        }
        
        
    }

    func removeSpashImageView(view:UIView)
    {
        
        for subview in view.subviews
        {
            if subview.tag == 86
            {
                subview.removeFromSuperview()
            }
        }
        
        
    }
    
    func splashImageView(view:UIView) {
    
        
        var imageView = UIImageView(frame: view.frame)
        var image = UIImage(named: "iTunesArtwork")
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.image = image
        imageView.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleWidth
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
        let currentDateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth, fromDate: self)
        let startOfMonth = calendar.dateFromComponents(currentDateComponents)
        
        return startOfMonth
    }
    
    func dateByAddingMonths(monthsToAdd: Int) -> NSDate? {
        
        let calendar = NSCalendar.currentCalendar()
        let months = NSDateComponents()
        months.month = monthsToAdd
        
        return calendar.dateByAddingComponents(months, toDate: self, options: nil)
    }
    
    func endOfMonth() -> NSDate? {
        
        let calendar = NSCalendar.currentCalendar()
        if let plusOneMonthDate = dateByAddingMonths(1) {
            let plusOneMonthDateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth, fromDate: plusOneMonthDate)
            
            let endOfMonth = calendar.dateFromComponents(plusOneMonthDateComponents)?.dateByAddingTimeInterval(-1)
            
            return endOfMonth
        }
        
        return nil
    }
}