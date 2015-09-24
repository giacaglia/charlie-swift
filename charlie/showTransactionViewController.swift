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
    
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var transactionIndex:Int = 0
    var mainVC:mainViewController!
    var transactionID:String = ""
    let regionRadius: CLLocationDistance = 1000
    var transactionItems = realm.objects(Transaction)
    var sourceVC = "main"
    
    func willEnterForeground(notification: NSNotification!) {
        if let resultController = storyboard!.instantiateViewControllerWithIdentifier("passcodeViewController") as? passcodeViewController {
            presentViewController(resultController, animated: true, completion: { () -> Void in
                cHelp.removeSpashImageView(self.view)
                cHelp.removeSpashImageView(self.presentingViewController!.view)
            })
        }
    }
    
    func didEnterBackgroundNotification(notification: NSNotification) {
        cHelp.splashImageView(self.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackgroundNotification:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    
        let account = realm.objects(Account).filter("_id = '\(transactionItems[transactionIndex]._account)'")
        
        self.transactionItems = realm.objects(Transaction).filter("_id = '\(self.transactionID)'")
        
        accountNumberLabel.text = account[0].meta!.number
        accountNameLabel.text = account[0].meta!.name
        if sourceVC == "main" {
            descriptionLabel.text = "Was \(self.transactionItems[transactionIndex].name)\nworth it?"
        }
        else if sourceVC == "happy" {
            descriptionLabel.text = "\(self.transactionItems[transactionIndex].name)\nwas worth it"
        }
        else if sourceVC == "sad" {
            descriptionLabel.text = "\(self.transactionItems[transactionIndex].name)\nwas not worth it"
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY" //format style. Browse online to get a format that fits your needs.
        let dateString = dateFormatter.stringFromDate(self.transactionItems[transactionIndex].date)
        dateLabel.text = dateString
        categoryLabel.text = self.transactionItems[transactionIndex].categories!.categories
        guard let location = self.transactionItems[transactionIndex].meta?.location else {
            mapView.hidden = true
            return
        }
        
        addressLabel.text = "\(location.address) \n  \(location.city) \(location.state) \(location.zip)"
        
        
        guard let coordinates = self.transactionItems[transactionIndex].meta?.location!.coordinates else {
            mapView.hidden = true
            return
        }
        let lat = coordinates.lat
        let lon = coordinates.lon
    
        mapView.hidden = false
        let initialLocation = CLLocation(latitude: lat, longitude: lon)
        centerMapOnLocation(initialLocation)
        let anotation = MKPointAnnotation()
        anotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        mapView.addAnnotation(anotation)
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
