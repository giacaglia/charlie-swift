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
    
    
    func set(_ value:String, key:String) -> Bool {
        if let data = value.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let keychainQuery:[String:AnyObject] = [kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: self.service as AnyObject,
                kSecAttrAccount as String: key as AnyObject,
                kSecValueData as String: data as AnyObject]
            
            SecItemDelete(keychainQuery as CFDictionary)
            
            let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
            
            if status != noErr {
                print("Failed to save data with status code: \(status)")
            }
            return status == noErr
        }
        
        return false
    }
    
    
    func get(_ key:String) -> String? {
        let keychainQuery:[String:AnyObject] = [kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service as AnyObject,
            kSecAttrAccount as String: key as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne]
        var dataTypeRef : AnyObject?
        
        let status: OSStatus = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
        
        var data: String?
        
        if (status == errSecSuccess) {
            let retrievedData = dataTypeRef as! Data
            // Convert the data retrieved from the keychain into a string
            data = NSString(data: retrievedData, encoding: String.Encoding.utf8.rawValue) as? String
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        return data
    }
    
    func delete(_ value:String, key:String) -> Bool {
        if let data = value.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let keychainQuery:[String:AnyObject] = [kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: self.service as AnyObject,
                kSecAttrAccount as String: key as AnyObject,
                kSecValueData as String: data as AnyObject]
            
            let status: OSStatus = SecItemDelete(keychainQuery as CFDictionary)
            
            if status != noErr {
                print("Failed to delete data with status code: \(status)")
            }
            return status == noErr
        }
        return false
    }
}
