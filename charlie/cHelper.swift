//
//  cHelper.swift
//  charlie
//
//  Created by James Caralis on 7/3/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import Foundation

class cHelper {

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