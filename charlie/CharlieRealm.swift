//
//  CharlieRealm.swift
//  charlie
//
//  Created by James Caralis on 6/8/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//


import RealmSwift
import Foundation

class User: Object {
    dynamic var email = ""
    dynamic var password = ""
    dynamic var pin = ""
    dynamic var access_token = ""
    dynamic var happy_flow : Double = 0
    override static func primaryKey() -> String? {
        return "email"
    }
    
}


class Account: Object {
    dynamic var _id = ""
    dynamic var _item = ""
    dynamic var _user = ""
    dynamic var institution_type = ""
    dynamic var type = ""
    dynamic var balance = Balance?()
    dynamic var meta = Meta?()
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}

class Meta: Object {
    dynamic var location = Location?()
    dynamic var name = ""
    //dynamic var limit = 0
    dynamic var number = ""
}

class Balance: Object {
    let current = RealmOptional<Double>()
    let avaliable = RealmOptional<Double>()
    //dynamic var picture: NSData? = nil
}




class Transaction: Object {
    dynamic var _id = ""
    dynamic var _account = ""
    dynamic var amount:Double  = 0.0
    dynamic var pending = true
    dynamic var categories = Category?()
    dynamic var placeType = ""
    dynamic var date =  NSDate()
    dynamic var name = ""
    dynamic var status = -1
    dynamic var meta = Meta?()
    dynamic var ctype = 0
    dynamic var note = ""
    dynamic var user_category = String()
    
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
    
    override static func primaryKey() -> String? {
        return "_id"
        
    }
}



class Category: Object {
    dynamic var id = ""
    dynamic var type = ""
    dynamic var categories = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}




class Location: Object {
    dynamic var coordinates = Coordinates?()
    dynamic var state = ""
    dynamic var city = ""
    dynamic var zip = ""
    dynamic var address = ""
    
}

class Coordinates: Object {
    
    dynamic var lat = 0.0
    dynamic var lon = 0.0
    
}




