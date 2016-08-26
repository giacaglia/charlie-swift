//
//  CandleChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
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

open class CandleChartDataSet: LineScatterCandleChartDataSet
{
    /// the width of the candle-shadow-line in pixels. 
    /// 
    /// **default**: 3.0
    open var shadowWidth = CGFloat(1.5)

    /// the space between the candle entries
    /// 
    /// **default**: 0.1 (10%)
    fileprivate var _bodySpace = CGFloat(0.1)
    
    /// the color of the shadow line
    open var shadowColor: UIColor?
    
    /// use candle color for the shadow
    open var shadowColorSameAsCandle = false
    
    /// color for open <= close
    open var decreasingColor: UIColor?
    
    /// color for open > close
    open var increasingColor: UIColor?
    
    /// Are decreasing values drawn as filled?
    open var decreasingFilled = false
    
    /// Are increasing values drawn as filled?
    open var increasingFilled = true
    
    public override init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(yVals: yVals, label: label)
    }
    
    internal override func calcMinMax(start: Int, end: Int)
    {
        if (yVals.count == 0)
        {
            return
        }
        
        var entries = yVals as! [CandleChartDataEntry]
        
        var endValue : Int
        
        if end == 0 || end >= entries.count
        {
            endValue = entries.count - 1
        }
        else
        {
            endValue = end
        }
        
        _lastStart = start
        _lastEnd = end
        
        _yMin = entries[start].low
        _yMax = entries[start].high
        
        for (var i = start + 1; i <= endValue; i += 1)
        {
            let e = entries[i]
            
            if (e.low < _yMin)
            {
                _yMin = e.low
            }
            
            if (e.high > _yMax)
            {
                _yMax = e.high
            }
        }
    }

    /// the space that is left out on the left and right side of each candle,
    /// **default**: 0.1 (10%), max 0.45, min 0.0
    open var bodySpace: CGFloat
    {
        set
        {
            if (newValue < 0.0)
            {
                _bodySpace = 0.0
            }
            else if (newValue > 0.45)
            {
                _bodySpace = 0.45
            }
            else
            {
                _bodySpace = newValue
            }
        }
        get
        {
            return _bodySpace
        }
    }
    
    /// Is the shadow color same as the candle color?
    open var isShadowColorSameAsCandle: Bool { return shadowColorSameAsCandle }
    
    /// Are increasing values drawn as filled?
    open var isIncreasingFilled: Bool { return increasingFilled; }
    
    /// Are decreasing values drawn as filled?
    open var isDecreasingFilled: Bool { return decreasingFilled; }
}
