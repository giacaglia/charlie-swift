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
    
    
    @IBOutlet weak var merchantLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var lastFourLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    let regionRadius: CLLocationDistance = 1000
   
    
    
    @IBOutlet weak var mapView: MKMapView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let account = realm.objects(Account).filter("_id = '\(transactionItems[transactionIndex]._account)'")
    
        accountNumberLabel.text = account[0].meta.number
        accountNameLabel.text = account[0].meta.name
        
        
        descriptionLabel.text = transactionItems[transactionIndex].name
        
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //format style. Browse online to get a format that fits your needs.
        var dateString = dateFormatter.stringFromDate(transactionItems[transactionIndex].date)
        dateLabel.text = dateString

       categoryLabel.text = transactionItems[transactionIndex].categories.categories
        
        addressLabel.text = "\(transactionItems[transactionIndex].meta.location.address) \n  \(transactionItems[transactionIndex].meta.location.city) \(transactionItems[transactionIndex].meta.location.state) \(transactionItems[transactionIndex].meta.location.zip)"
        
    
        
        var lat = transactionItems[transactionIndex].meta.location.coordinates.lat
        var lon = transactionItems[transactionIndex].meta.location.coordinates.lon
        
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
        
        mainVC.blurEffectView.hidden = true
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    

}

