//
//  CharlieRealm.swift
//  charlie
//
//  Created by James Caralis on 6/8/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//


import RealmSwift

class User: Object {
    dynamic var email = ""
    dynamic var password = ""
    dynamic var pin = ""
    dynamic var access_token = ""
    
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
    dynamic var balance = Balance()
    dynamic var meta = Meta()
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}

class Meta: Object {
    dynamic var location = Location()
    dynamic var name = ""
}

class Balance: Object {
    dynamic var current:Double  = 0.0
    dynamic var available:Double = 0.0
}



class Transaction: Object {
    dynamic var _id = ""
    dynamic var _account = ""
    dynamic var amount:Double  = 0.0
    dynamic var pending = true
    dynamic var category_id = ""
    dynamic var date = ""
    dynamic var name = ""
    dynamic var status = 0
    dynamic var meta = Meta()
    
    
    override static func primaryKey() -> String? {
        return "_id"
        
    }
    
}

class Location: Object {
    dynamic var coordinates = Coordinates()
    dynamic var state = ""
    dynamic var city = ""
    dynamic var zip = ""
    dynamic var address = ""
    
}

class Coordinates: Object {
    
    dynamic var lat = 0.0
    dynamic var lon = 0.0
    
}




