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
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var mainVC:mainViewController!
    var transaction : Transaction?
    var transactionIndex  = 0
    var sourceVC = "main"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var transactionItems = realm.objects(Transaction)
        guard let usedTransaction = transaction else {
            return
        }
        let account = realm.objects(Account).filter("_id = '\(transactionItems[0]._account)'")
        transactionItems = realm.objects(Transaction).filter("_id = '\(usedTransaction._id)'")
        
        accountNumberLabel.text = account[0].meta!.number
        accountNameLabel.text = account[0].meta!.name
        let trans = transactionItems[0]
        if sourceVC == "main" {
            let myString = "Was $\(trans.amount) at \(trans.name)\nworth it?"
            let attString = NSMutableAttributedString(string: myString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(18.0)])
            attString.addAttribute(NSForegroundColorAttributeName, value: listBlue, range: NSRange(location:4,length:(String(trans.amount).characters.count) + 1))

            descriptionLabel.attributedText = attString
        }
        else if sourceVC == "happy" {
            descriptionLabel.text = "\(trans.name)\nwas worth it"
        }
        else if sourceVC == "sad" {
            descriptionLabel.text = "\(trans.name)\nwas not worth it"
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY"
        dateLabel.text = dateFormatter.stringFromDate(trans.date)

        categoryLabel.text = String()
        categoryLabel.text = trans.user_category
        
        // Fix name: Terrible name
        if let categories = trans.categories {
            typeLabel.text = categories.categories
        }
        else {
            typeLabel.text = String()
        }
        
        guard let location = trans.meta?.location else {
            mapView.hidden = true
            return
        }
        
        addressLabel.text = "\(location.address) \n  \(location.city) \(location.state) \(location.zip)"
        
        guard let coordinates = trans.meta?.location!.coordinates else {
            mapView.hidden = true
            return
        }
        
        mapView.hidden = false
        let initialLocation = CLLocation(latitude: coordinates.lat, longitude: coordinates.lon)
        centerMapOnLocation(initialLocation)
        let anotation = MKPointAnnotation()
        anotation.coordinate = CLLocationCoordinate2D(latitude: coordinates.lat, longitude: coordinates.lon)
        mapView.addAnnotation(anotation)
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func notWorth(sender: AnyObject) {
        if let vc = mainVC {
            self.navigationController!.popViewControllerAnimated(true)
            //no completion for pop -  need better solution later
            vc.swipeCellAtIndex(self.transactionIndex, toLeft: true)
            
        }
        else {
            try! realm.write {
                self.transaction!.status = 2
            }
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func worth(sender: AnyObject) {
        if let vc = mainVC {
            
            self.navigationController!.popViewControllerAnimated(true)
             //no completion for pop -  need better solution later
            vc.swipeCellAtIndex(self.transactionIndex, toLeft: false)
        }
        else {
            try! realm.write {
                self.transaction!.status = 1
            }
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func closeButtonPress(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion:nil)
        //self.presentingViewController?.dismissViewControllerAnimated(true, completion:nil)
    }

}
