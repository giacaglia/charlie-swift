//
//  showDetailViewController.swift
//  charlie
//
//  Created by Jim Caralis on 6/17/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import MapKit
import UIKit


class showDetailViewController: UIViewController {

    var transactionIndex:Int = 0
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!

    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    
    @IBOutlet weak var cardLabel: UILabel!
    
    
    @IBOutlet weak var accountLabel: UILabel!
    
    
    @IBOutlet weak var addressLabel: UILabel!
    
    
    @IBAction func pressCloseViewButton(sender:
        UIButton) {
            
            
            dismissViewControllerAnimated(false, completion: nil)
            
            
            
            
            
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        
    }
    

}




