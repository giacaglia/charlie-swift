//
//  cHelper.swift
//  charlie
//
//  Created by James Caralis on 7/3/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import Foundation

class cHelper {
    
    
    
    
    
    func addUpdateResetAccount(type:Int, access_token:String, callback: Int->())
    {
        
        
       
    let access_token = access_token
        
        
      let users = realm.objects(User)
        
       for user in users
       {
            cService.updateAccount(user.access_token)
                {
                    (response) in
                    
                    let accounts = response["accounts"] as! [NSDictionary]
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
                            
                            //println(dictName)
                            
                            //convert string to date before insert
                            var dictDate = transaction.valueForKey("date") as? String
                            transaction.setValue(self.convertDate(dictDate!), forKey: "date")
                            
                            
                            //add category
                            if let category_id = transaction.valueForKey("category_id") as? String
                            {
                                let predicate = NSPredicate(format: "id = %@", category_id)
                                var categoryToAdd = realm.objects(Category).filter(predicate)
                                var newTrans =  realm.create(Transaction.self, value: transaction, update: true)
                                newTrans.categories = categoryToAdd[0]
                                if category_id == "21008000" || category_id == "21007001"
                                {
                                    newTrans.status = 99
                                }
                                else
                                {
                                    if type == 99
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
                    
                    
                    
                    transactionItems = realm.objects(Transaction).filter(inboxPredicate)
                    callback(transactions.count)
                    
                    
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
    
    return modString2
    
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

}