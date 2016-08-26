//
//  ChartAxisBase.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit

open class ChartAxisBase: ChartComponentBase
{
    open var labelFont = UIFont.systemFont(ofSize: 10.0)
    open var labelTextColor = UIColor.black
    
    open var axisLineColor = UIColor.gray
    open var axisLineWidth = CGFloat(0.5)
    open var axisLineDashPhase = CGFloat(0.0)
    open var axisLineDashLengths: [CGFloat]!
    
    open var gridColor = UIColor.gray.withAlphaComponent(0.9)
    open var gridLineWidth = CGFloat(0.5)
    open var gridLineDashPhase = CGFloat(0.0)
    open var gridLineDashLengths: [CGFloat]!
    
    open var drawGridLinesEnabled = true
    open var drawAxisLineEnabled = true
    
    /// flag that indicates of the labels of this axis should be drawn or not
    open var drawLabelsEnabled = true
    
    /// Sets the used x-axis offset for the labels on this axis.
    /// **default**: 5.0
    open var xOffset = CGFloat(5.0)
    
    /// Sets the used y-axis offset for the labels on this axis.
    /// **default**: 5.0 (or 0.0 on ChartYAxis)
    open var yOffset = CGFloat(5.0)
    
    /// array of limitlines that can be set for the axis
    fileprivate var _limitLines = [ChartLimitLine]()
    
    /// Are the LimitLines drawn behind the data or in front of the data?
    /// 
    /// **default**: false
    open var drawLimitLinesBehindDataEnabled = false

    public override init()
    {
        super.init()
    }
    
    open func getLongestLabel() -> String
    {
        fatalError("getLongestLabel() cannot be called on ChartAxisBase")
    }
    
    open var isDrawGridLinesEnabled: Bool { return drawGridLinesEnabled; }
    
    open var isDrawAxisLineEnabled: Bool { return drawAxisLineEnabled; }
    
    open var isDrawLabelsEnabled: Bool { return drawLabelsEnabled; }
    
    /// Are the LimitLines drawn behind the data or in front of the data?
    /// 
    /// **default**: false
    open var isDrawLimitLinesBehindDataEnabled: Bool { return drawLimitLinesBehindDataEnabled; }
    
    /// Adds a new ChartLimitLine to this axis.
    open func addLimitLine(_ line: ChartLimitLine)
    {
        _limitLines.append(line)
    }
    
    /// Removes the specified ChartLimitLine from the axis.
    open func removeLimitLine(_ line: ChartLimitLine)
    {
        for (i in 0 ..< _limitLines.count)
        {
            if (_limitLines[i] === line)
            {
                _limitLines.remove(at: i)
                return
            }
        }
    }
    
    /// Removes all LimitLines from the axis.
    open func removeAllLimitLines()
    {
        _limitLines.removeAll(keepingCapacity: false)
    }
    
    /// - returns: the LimitLines of this axis.
    open var limitLines : [ChartLimitLine]
        {
            return _limitLines
    }
}
