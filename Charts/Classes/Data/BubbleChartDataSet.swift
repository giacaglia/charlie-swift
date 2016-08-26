//
//  BubbleChartDataSet.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics
import UIKit

open class BubbleChartDataSet: BarLineScatterCandleChartDataSet
{
    internal var _xMax = Double(0.0)
    internal var _xMin = Double(0.0)
    internal var _maxSize = CGFloat(0.0)

    open var xMin: Double { return _xMin }
    open var xMax: Double { return _xMax }
    open var maxSize: CGFloat { return _maxSize }
    
    open func setColor(_ color: UIColor, alpha: CGFloat)
    {
        super.setColor(color.withAlphaComponent(alpha))
    }
    
    internal override func calcMinMax(start: Int, end: Int)
    {
        if (yVals.count == 0)
        {
            return
        }
        
        let entries = yVals as! [BubbleChartDataEntry]
    
        // need chart width to guess this properly
        
        var endValue : Int
        
        if end == 0
        {
            endValue = entries.count - 1
        }
        else
        {
            endValue = end
        }
        
        _lastStart = start
        _lastEnd = end
        
        _yMin = yMin(entries[start])
        _yMax = yMax(entries[start])
        
        for (var i = start; i <= endValue; i += 1)
        {
            let entry = entries[i]

            let ymin = yMin(entry)
            let ymax = yMax(entry)
            
            if (ymin < _yMin)
            {
                _yMin = ymin
            }
            
            if (ymax > _yMax)
            {
                _yMax = ymax
            }
            
            let xmin = xMin(entry)
            let xmax = xMax(entry)
            
            if (xmin < _xMin)
            {
                _xMin = xmin
            }
            
            if (xmax > _xMax)
            {
                _xMax = xmax
            }

            let size = largestSize(entry)
            
            if (size > _maxSize)
            {
                _maxSize = size
            }
        }
    }
    
    /// Sets/gets the width of the circle that surrounds the bubble when highlighted
    open var highlightCircleWidth: CGFloat = 2.5
    
    fileprivate func yMin(_ entry: BubbleChartDataEntry) -> Double
    {
        return entry.value
    }
    
    fileprivate func yMax(_ entry: BubbleChartDataEntry) -> Double
    {
        return entry.value
    }
    
    fileprivate func xMin(_ entry: BubbleChartDataEntry) -> Double
    {
        return Double(entry.xIndex)
    }
    
    fileprivate func xMax(_ entry: BubbleChartDataEntry) -> Double
    {
        return Double(entry.xIndex)
    }
    
    fileprivate func largestSize(_ entry: BubbleChartDataEntry) -> CGFloat
    {
        return entry.size
    }
}
