//
//  LineChartDataSet.swift
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
import UIKit

open class LineChartDataSet: LineRadarChartDataSet
{
    open var circleColors = [UIColor]()
    open var circleHoleColor = UIColor.white
    open var circleRadius = CGFloat(8.0)
    
    fileprivate var _cubicIntensity = CGFloat(0.2)
    
    open var lineDashPhase = CGFloat(0.0)
    open var lineDashLengths: [CGFloat]!
    
    /// if true, drawing circles is enabled
    open var drawCirclesEnabled = true
    
    /// if true, cubic lines are drawn instead of linear
    open var drawCubicEnabled = false
    
    open var drawCircleHoleEnabled = true
    
    public override init()
    {
        super.init()
        circleColors.append(UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
    }
    
    public override init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(yVals: yVals, label: label)
        circleColors.append(UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
    }

    /// intensity for cubic lines (min = 0.05, max = 1)
    /// 
    /// **default**: 0.2
    open var cubicIntensity: CGFloat
    {
        get
        {
            return _cubicIntensity
        }
        set
        {
            _cubicIntensity = newValue
            if (_cubicIntensity > 1.0)
            {
                _cubicIntensity = 1.0
            }
            if (_cubicIntensity < 0.05)
            {
                _cubicIntensity = 0.05
            }
        }
    }
    
    /// - returns: the color at the given index of the DataSet's circle-color array.
    /// Performs a IndexOutOfBounds check by modulus.
    public func getCircleColor(_ index: Int) -> UIColor?
    {
        var index = index
        let size = circleColors.count
        index = index % size
        if (index >= size)
        {
            return nil
        }
        return circleColors[index]
    }
    
    /// Sets the one and ONLY color that should be used for this DataSet.
    /// Internally, this recreates the colors array and adds the specified color.
    open func setCircleColor(_ color: UIColor)
    {
        circleColors.removeAll(keepingCapacity: false)
        circleColors.append(color)
    }
    
    /// resets the circle-colors array and creates a new one
    open func resetCircleColors(_ index: Int)
    {
        circleColors.removeAll(keepingCapacity: false)
    }
    
    open var isDrawCirclesEnabled: Bool { return drawCirclesEnabled; }
    
    open var isDrawCubicEnabled: Bool { return drawCubicEnabled; }
    
    open var isDrawCircleHoleEnabled: Bool { return drawCircleHoleEnabled; }
    
    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! LineChartDataSet
        copy.circleColors = circleColors
        copy.circleRadius = circleRadius
        copy.cubicIntensity = cubicIntensity
        copy.lineDashPhase = lineDashPhase
        copy.lineDashLengths = lineDashLengths
        copy.drawCirclesEnabled = drawCirclesEnabled
        copy.drawCubicEnabled = drawCubicEnabled
        return copy
    }
}
