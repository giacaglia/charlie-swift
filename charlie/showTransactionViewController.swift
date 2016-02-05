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
    
    @IBOutlet weak var notWorthButton: UIButton!
    
    @IBOutlet weak var worthButton: UIButton!
  
    @IBOutlet weak var datePickerControl: UIDatePicker!
    
    @IBOutlet weak var datePickerView: UIView!
    
    var mainVC:mainViewController!
    var transaction : Transaction?
    var transactionIndex  = 0
    var sourceVC = "main"

    override func viewDidLoad() {
        super.viewDidLoad()
        
       datePickerView.hidden =  true
       
        
        let account = realm.objects(Account).filter("_id = '\(transaction!._account)'")

        
        if transaction?.amount < 0
        {
            
            notWorthButton.hidden = true
            worthButton.hidden =  true
        }
      
        accountNumberLabel.text = account[0].meta!.number
        accountNameLabel.text = account[0].meta!.name
        let trans = transaction!
        
        
//        print ("STATUS \(trans.status)")
//          print ("TYPE \(trans.ctype)")
//        print ("CATEGORY \(trans.categories?.id)")
        if sourceVC == "main" {
    
            
            if trans.amount < 0
            {
                let myString = "$\(trans.amount * -1) at \(trans.name)"
                let attString = NSMutableAttributedString(string: myString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(18.0)])
                //attString.addAttribute(NSForegroundColorAttributeName, value: listBlue, range: NSRange(location:4,length:(String(trans.amount).characters.count) + 1))
                
                descriptionLabel.attributedText = attString
                
            }
            else
            {
                let myString = "Was $\(trans.amount) at \(trans.name)\nworth it?"
                let attString = NSMutableAttributedString(string: myString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(18.0)])
                attString.addAttribute(NSForegroundColorAttributeName, value: listBlue, range: NSRange(location:4,length:(String(trans.amount).characters.count) + 1))

                descriptionLabel.attributedText = attString
            }
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
        
        if trans.ctype == 86
        {
            categoryLabel.text = "Don't Count"
        }
        else if trans.ctype == 1
        {
            categoryLabel.text = "Expenses - Bills"
        }
        else if trans.ctype == 2
        {
            categoryLabel.text = "Expenses - Spending"
        }
        else if trans.ctype == 3
        {
            categoryLabel.text = "Savings"
        }
        else
        {
            categoryLabel.text = ""
        }

        
        
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
    
   
   
    
    @IBAction func changeTypeButtonPressed(sender: UIButton) {
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Change Type", preferredStyle: .ActionSheet)
        
        // 2
        let billsAction = UIAlertAction(title: "Expenses - Bills", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            try! realm.write {
                self.transaction!.ctype = 1
                self.categoryLabel.text = "Expenses - Bills"
            }
           
        })
//        let image = UIImage(named: "blue_bills")
//        billsAction.setValue(image, forKey: "image")
//        
       
        
        
        let spendingAction = UIAlertAction(title: "Expenses - Spending", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            try! realm.write {
                self.transaction!.ctype = 2
                self.categoryLabel.text = "Expenses - Spending"
            }
            
        })
        
        let incomeAction = UIAlertAction(title: "Income", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            try! realm.write {
                self.transaction!.ctype = 3
                self.categoryLabel.text = "Income"
            }
            
        })
        
        
        let savingAction = UIAlertAction(title: "Savings", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            try! realm.write {
                self.transaction!.ctype = 3
                self.categoryLabel.text = "Savings"
            }
            
        })
        
       
        let dcAction = UIAlertAction(title: "Don't Count", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            try! realm.write {
                self.transaction!.ctype = 86
                self.categoryLabel.text = "Don't Count"
            }
            
        })
        
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
           
        })
        
        // 4
        optionMenu.addAction(billsAction)
        optionMenu.addAction(spendingAction)
        optionMenu.addAction(incomeAction)
        optionMenu.addAction(savingAction)
        optionMenu.addAction(dcAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
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
    
    @IBAction func showDatePickerButton(sender: UIButton) {
        
        datePickerView.hidden = false
        mapView.hidden = true
        datePickerControl.date = (transaction?.date)!
        
    }
    
    
    
    
    @IBAction func saveDateButton(sender: UIButton) {
        
      
            datePickerView.hidden = true
            mapView.hidden = false
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd, YYYY"
            let strDate = dateFormatter.stringFromDate(datePickerControl.date)
        
            dateLabel.text = strDate
            
            try! realm.write {
                self.transaction!.date = self.datePickerControl.date
            }
       
         if let vc = mainVC {
            
            //vc.transactionsTable.reloadData()
            vc.loadTransactionTable()
        
        }
      
        
    }
    
    @IBAction func closeButtonPress(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion:nil)
        //self.presentingViewController?.dismissViewControllerAnimated(true, completion:nil)
    }

}
