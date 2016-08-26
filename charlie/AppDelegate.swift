//
//  AppDelegate.swift
//  charlie
//
//  Created by James Caralis on 6/5/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//


import Fabric
import Crashlytics
import UIKit
import Security
import RealmSwift

func RGB(_ red:CGFloat,green:CGFloat,blue:CGFloat) -> UIColor
         {return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0) }
let listRed    = UIColor(red: 245/255, green: 125/255, blue: 128/255, alpha: 1.0)
let lightRed   = UIColor(red: 247/255, green: 160/255, blue: 160/255, alpha: 1.0)
let listBlue   = UIColor(red: 142/255, green: 180/255, blue: 246/255, alpha: 1.0)
let lightBlue  = UIColor(red: 164/255, green: 202/255, blue: 247/255, alpha: 1.0)
let listGreen  = UIColor(red: 153/255, green: 219/255, blue: 103/255, alpha: 1.0)
let lightGreen = UIColor(red: 169/255, green: 232/255, blue: 121/255, alpha: 1.0)
let lightGray  = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
let mediumGray = UIColor(red: 154/255, green: 154/255, blue: 154/255, alpha: 1.0)
var cService = charlieService()
var filePath = Bundle.main.path(forResource: "plaid", ofType: "html")
let defaults = UserDefaults.standard
//let config = Realm.Configuration(encryptionKey: cHelper().getKey())


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: Any]?) -> Bool {
        // Override point for customization after application launch.
        //let cHelp = cHelper()        
        
        //filePath = cHelp.pathForBuggyWKWebView(filePath) // This is the reason of this entire thread!
        Fabric.with([Crashlytics()])

        //PRODCHANGE
        //Mixpanel.sharedInstanceWithToken("4bcfd424118b13447dd4cb200b123fda") //DEV
        Mixpanel.sharedInstance(withToken: "77a88d24eaf156359e9e0617338ed328") //prod
        
        Mixpanel.sharedInstance().identify(Mixpanel.sharedInstance().distinctId)
             
        
        let configRealm = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 2,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    migration.enumerate(User.className()) { oldObject, newObject in
                        // Nothing to do!
                        // Realm will automatically detect new properties and removed properties
                        // And will update the schema on disk automatically
                        newObject!["happy_flow"] = 0.0
                    }
                }
                if oldSchemaVersion < 2 {
                    migration.enumerate(Transaction.className()) { oldObject, newObject in
                        newObject!["user_category"] = String()
                    }
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = configRealm
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        try! Realm()

        charlieAnalytics.track("App Launched")
        
        var config = SwiftLoader.Config()
        config.size = 150
        config.spinnerLineWidth = 8.0
        config.spinnerColor = listBlue
        config.backgroundColor = UIColor(white: 1.0, alpha: 0.80)
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.5
        SwiftLoader.setConfig(config)        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         Mixpanel.sharedInstance().people.addPushDeviceToken(deviceToken)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
       
    }

}


extension UIButton {
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = self.bounds
        let hitTestEdgeInsets = UIEdgeInsetsMake(-22, -22, -22, -22)
        let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
}

