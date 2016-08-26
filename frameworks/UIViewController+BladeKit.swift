//
//  UIViewController+BladeKit.swift
//  BladeKit
//
//  Created by Doug on 4/9/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import UIKit

public extension UIViewController {
    public func showGenericAlertError(_ title: String, message: String, dismissTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: dismissTitle, style: UIAlertActionStyle.default, handler: { (action) -> Void in
        }))
        self.present(alert, animated: true, completion: { () -> Void in
        })
    }
}
