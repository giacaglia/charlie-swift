//
//  ScatterChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

open class ScatterChartDataSet: LineScatterCandleChartDataSet
{
    @objc
    public enum ScatterShape: Int
    {
        case cross
        case triangle
        case circle
        case square
        case custom
    }
    
    open var scatterShapeSize = CGFloat(15.0)
    open var scatterShape = ScatterShape.square
    open var customScatterShape: CGPath?

    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! ScatterChartDataSet
        copy.scatterShapeSize = scatterShapeSize
        copy.scatterShape = scatterShape
        copy.customScatterShape = customScatterShape
        return copy
    }
}
