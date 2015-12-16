//
//  filterCell.swift
//  charlie
//
//  Created by James Caralis on 12/7/15.
//  Copyright © 2015 James Caralis. All rights reserved.
//

import Foundation

class FilterCell : UICollectionViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
   
    func changeState(selected selected: Bool) {
        if selected {
            monthLabel.font = UIFont(name: "Montserrat-Bold", size: 17.0)
        }
        else {
            monthLabel.font = UIFont(name: "Montserrat-Light", size: 17.0)
        }
    }
    
}