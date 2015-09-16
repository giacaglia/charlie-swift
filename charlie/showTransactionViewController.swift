//
//  showTransactionViewController.swift
//  charlie
//
//  Created by James Caralis on 6/18/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
import MapKit

class showTransactionViewController: UIViewController {

    var transactionIndex:Int = 0
    var mainVC:mainViewController!
    var transactionID:String = ""
    
    
    @IBOutlet weak var merchantLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var lastFourLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    let regionRadius: CLLocationDistance = 1000
    
    var transactionItems = realm.objects(Transaction)
   
    
    var sourceVC = "main"
    
    
    @IBOutlet weak var mapView: MKMapView!

    func willEnterForeground(notification: NSNotification!) {
        
        
        if let resultController = storyboard!.instantiateViewControllerWithIdentifier("passcodeViewController") as? passcodeViewController {
            
            presentViewController(resultController, animated: true, completion: { () -> Void in
                
                cHelp.removeSpashImageView(self.view)
                cHelp.removeSpashImageView(self.presentingViewController!.view)
                
            })
        }
        
       

        
    }
    
    
    func didEnterBackgroundNotification(notification: NSNotification)
    {
         cHelp.splashImageView(self.view)
    }
    


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackgroundNotification:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    
        
         var lat = 0.0
         var lon = 0.0

        let account = realm.objects(Account).filter("_id = '\(transactionItems[transactionIndex]._account)'")
        
        self.transactionItems = realm.objects(Transaction).filter("_id = '\(self.transactionID)'")
    
        accountNumberLabel.text = account[0].meta!.number
        accountNameLabel.text = account[0].meta!.name
        
        
        if sourceVC == "main"
        {
            descriptionLabel.text = "Was \(self.transactionItems[transactionIndex].name)\nworth it?"
        }
        else if sourceVC == "happy"
        {
            descriptionLabel.text = "\(self.transactionItems[transactionIndex].name)\nwas worth it"
        }
        else if sourceVC == "sad"
        {
            descriptionLabel.text = "\(self.transactionItems[transactionIndex].name)\nwas not worth it"
        }
        
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY" //format style. Browse online to get a format that fits your needs.
        var dateString = dateFormatter.stringFromDate(self.transactionItems[transactionIndex].date)
        dateLabel.text = dateString

       categoryLabel.text = self.transactionItems[transactionIndex].categories!.categories
        
        addressLabel.text = "\(self.transactionItems[transactionIndex].meta?.location!.address) \n  \(self.transactionItems[transactionIndex].meta?.location!.city) \(self.transactionItems[transactionIndex].meta?.location!.state) \(self.transactionItems[transactionIndex].meta?.location!.zip)"
        
    
        print(self.transactionItems[transactionIndex].ctype)
        lat = (self.transactionItems[transactionIndex].meta?.location!.coordinates!.lat)!
        lon = (self.transactionItems[transactionIndex].meta?.location!.coordinates!.lon)!
        
        if lat > 0
        {
            mapView.hidden = false
            let initialLocation = CLLocation(latitude: lat, longitude: lon)
            
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            centerMapOnLocation(initialLocation)
            var anotation = MKPointAnnotation()
            anotation.coordinate = location

            mapView.addAnnotation(anotation)
            
            
            
        }
        else
        {
            mapView.hidden = true
        }
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    
    @IBAction func closeButtonPress(sender: AnyObject) {
        
       
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    

}

