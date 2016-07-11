//
//  BKInsetTextField.swift
//  BladeKit
//
//  Created by Doug on 4/6/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//

import UIKit


@IBDesignable public class InsetUITextField: UITextField {

    @IBInspectable var inset: CGFloat = 10
    
    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds,inset,inset)
    }
    
    override public func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds,inset ,inset)
    }
    
    override public func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds,inset,inset)
    }
}
