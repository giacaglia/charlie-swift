//
//  UIViewController+BladeKit.swift
//  BladeKit
//
//  Created by Doug on 4/9/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import UIKit

public extension UIViewController {
    public func showGenericAlertError(title: String, message: String, dismissTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: dismissTitle, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        }))
        self.presentViewController(alert, animated: true, completion: { () -> Void in
        })
    }
}
