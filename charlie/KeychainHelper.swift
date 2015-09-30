//
//  KeychainHelper.swift
//  Luna
//
//  Created by Alex Grinman on 7/9/15.
//  Copyright (c) 2015 Blade LLC. All rights reserved.
//

import Foundation

internal let CHARLIE_KEYCHAIN_SERVICE = "CharlieKeychainService"

class KeychainHelper {
    
    var service:String
    
    init(service:String = CHARLIE_KEYCHAIN_SERVICE) {
        self.service = service
    }
    
    
    func set(value:String, key:String) -> Bool {
        if let data = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let keychainQuery:[String:AnyObject] = [kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: self.service,
                kSecAttrAccount as String: key,
                kSecValueData as String: data]
            
            SecItemDelete(keychainQuery as CFDictionaryRef)
            
            let status: OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
            
            if status != noErr {
                print("Failed to save data with status code: \(status)")
            }
            return status == noErr
        }
        
        return false
    }
    
    
    func get(key:String) -> String? {
        let keychainQuery:[String:AnyObject] = [kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne]
        var dataTypeRef : AnyObject?
        
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        
        var data: String?
        
        if (status == errSecSuccess) {
            let retrievedData = dataTypeRef as! NSData
            // Convert the data retrieved from the keychain into a string
            data = NSString(data: retrievedData, encoding: NSUTF8StringEncoding) as? String
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        return data
    }
    
    func delete(value:String, key:String) -> Bool {
        if let data = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let keychainQuery:[String:AnyObject] = [kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: self.service,
                kSecAttrAccount as String: key,
                kSecValueData as String: data]
            
            let status: OSStatus = SecItemDelete(keychainQuery as CFDictionaryRef)
            
            if status != noErr {
                print("Failed to delete data with status code: \(status)")
            }
            return status == noErr
        }
        return false
    }
}