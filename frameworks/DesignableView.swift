//
//  DesignableView.swift
//  BladeKit
//
//  Original by Kristin
//  Migrated to BladeKit by Doug on 4/6/15.
//  Copyright (c) 2015 Blade. All rights reserved.
//
//  Base class for all IBDesignables.
//

import UIKit

open class DesignableView: UIView {
    
    open var view: UIView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    fileprivate func loadXib() {
        
        let bundle = Bundle(for: type(of: self))
        let xib = UINib(nibName: xibName(), bundle: bundle)
        
        // Assumes UIView is top level and only object in .xib file
        view = xib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        // confirm desired bounds based on if it was loaded from nib or code
        if bounds.isEmpty {
            frame = view.bounds
        } else {
            view.frame = bounds
        }
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Promote the background color used in the designable xib to the background color for the view itself
        // This allows the consumer of the designable to set the background color in their xib file
        self.backgroundColor = view.backgroundColor
        view.backgroundColor = UIColor.clear
        
        // Do any custom setup
        xibSetup()
        
        // Add view we just loaded from .xib to ourself
        addSubview(view)
    }
    
    // May must be overridden in subclass
    open func xibName() -> String {
        // default implementation
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
    
    // Override if you need a hook for additional setup after .xib is loaded
    open func xibSetup() {
    }
}
