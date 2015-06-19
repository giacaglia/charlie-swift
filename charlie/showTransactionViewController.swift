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
    
   
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var lastFourLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
   
    @IBOutlet weak var accountNameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    let regionRadius: CLLocationDistance = 1000
   
    
    
    @IBOutlet weak var mapView: MKMapView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        descriptionLabel.text = transactionItems[transactionIndex].name
        dateLabel.text = transactionItems[transactionIndex].date
        addressLabel.text = "\(transactionItems[transactionIndex].meta.location.address) \n  \(transactionItems[transactionIndex].meta.location.city), \(transactionItems[transactionIndex].meta.location.state), \(transactionItems[transactionIndex].meta.location.zip)"
        
        
        var lat = transactionItems[transactionIndex].meta.location.coordinates.lat
        var lon = transactionItems[transactionIndex].meta.location.coordinates.lon
        
        if lat > 0
        {
            mapView.hidden = false
            let initialLocation = CLLocation(latitude: lat, longitude: lon)
            centerMapOnLocation(initialLocation)
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

