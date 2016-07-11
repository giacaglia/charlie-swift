//
//  UIImage+BladeKit.swift
//  BladeKit
//
//  Created by Doug on 4/14/15.
//  Copyright (c) 2015 BladeKit. All rights reserved.
//

import Foundation

public extension UIImage {
    public static func drawInitialsAsImage(initials: String, frame: CGRect, font: UIFont) -> UIImage {
        
        if frame.size.width < 2.0 || frame.size.height < 2.0 {
            // This is silly small, just return an empty image for now
            return UIImage()
        }
        
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0.0);
        
        UIColor.colorFromInitials(initials).set()
        
        // fill BG
        CGContextFillRect(UIGraphicsGetCurrentContext(), frame)
        
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSBackgroundColorAttributeName: UIColor.clearColor()
        ]
        // draw in center.
        (initials as NSString).drawInRect(CGRectMake(frame.size.width/2 - (initials as NSString).sizeWithAttributes(textFontAttributes).width/2,
            frame.size.height/2 - (initials as NSString).sizeWithAttributes(textFontAttributes).height/2,
            frame.width,
            frame.height),
            withAttributes:textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    public static func getImageWithColor(color: UIColor) -> UIImage {
        let size = CGSizeMake(1, 100)
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
