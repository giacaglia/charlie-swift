//
//  BKInsetTextField.swift
//  BladeKit
//
//  Created by Doug on 4/6/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import UIKit


@IBDesignable open class InsetUITextField: UITextField {

    @IBInspectable var inset: CGFloat = 10
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset,dy: inset)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset ,dy: inset)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset,dy: inset)
    }
}
