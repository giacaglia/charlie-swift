//
//  UIImage+BladeKit.swift
//  BladeKit
//
//  Created by Doug on 4/14/15.
//  Copyright (c) 2015 BladeKit. All rights reserved.
//

import Foundation

public extension UIImage {
    public static func drawInitialsAsImage(_ initials: String, frame: CGRect, font: UIFont) -> UIImage {
        
        if frame.size.width < 2.0 || frame.size.height < 2.0 {
            // This is silly small, just return an empty image for now
            return UIImage()
        }
        
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0.0);
        
        UIColor.colorFromInitials(initials).set()
        
        // fill BG
        UIGraphicsGetCurrentContext()?.fill(frame)
        
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.white,
            NSBackgroundColorAttributeName: UIColor.clear
        ]
        // draw in center.
        (initials as NSString).draw(in: CGRect(x: frame.size.width/2 - (initials as NSString).size(attributes: textFontAttributes).width/2,
            y: frame.size.height/2 - (initials as NSString).size(attributes: textFontAttributes).height/2,
            width: frame.width,
            height: frame.height),
            withAttributes:textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage!;
    }
    
    public static func getImageWithColor(_ color: UIColor) -> UIImage {
        let size = CGSize(width: 1, height: 100)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
