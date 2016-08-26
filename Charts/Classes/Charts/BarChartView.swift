//
//  BarChartView.swift
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

/// Chart that draws bars.
open class BarChartView: BarLineChartViewBase, BarChartRendererDelegate
{
    /// flag that enables or disables the highlighting arrow
    fileprivate var _drawHighlightArrowEnabled = false
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    fileprivate var _drawValueAboveBarEnabled = true

    /// if set to true, a grey area is darawn behind each bar that indicates the maximum value
    fileprivate var _drawBarShadowEnabled = false
    
    internal override func initialize()
    {
        super.initialize()
        
        renderer = BarChartRenderer(delegate: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _xAxisRenderer = ChartXAxisRendererBarChart(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer, chart: self)
        
        _highlighter = BarChartHighlighter(chart: self)
        
        _chartXMin = -0.5
    }
    
    internal override func calcMinMax()
    {
        super.calcMinMax()
        
        if (_data === nil)
        {
            return
        }
        
        let barData = _data as! BarChartData
        
        // increase deltax by 1 because the bars have a width of 1
        _deltaX += 0.5
        
        // extend xDelta to make space for multiple datasets (if ther are one)
        _deltaX *= CGFloat(_data.dataSetCount)
        
        let groupSpace = barData.groupSpace
        _deltaX += CGFloat(barData.xValCount) * groupSpace
        _chartXMax = Double(_deltaX) - _chartXMin
    }
    
    /// - returns: the Highlight object (contains x-index and DataSet index) of the selected value at the given touch point inside the BarChart.
    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> ChartHighlight?
    {
        if (_dataNotSet || _data === nil)
        {
            print("Can't select by touch. No data set.", terminator: "\n")
            return nil
        }
        
        return _highlighter?.getHighlight(x: Double(pt.x), y: Double(pt.y))
    }
        
    /// - returns: the bounding box of the specified Entry in the specified DataSet. Returns null if the Entry could not be found in the charts data.
    open func getBarBounds(_ e: BarChartDataEntry) -> CGRect!
    {
        let set = _data.getDataSetForEntry(e) as! BarChartDataSet!
        
        if (set === nil)
        {
            return nil
        }
        
        let barspace = set.barSpace
        let y = CGFloat(e.value)
        let x = CGFloat(e.xIndex)
        
        let barWidth: CGFloat = 0.5
        
        let spaceHalf = barspace / 2.0
        let left = x - barWidth + spaceHalf
        let right = x + barWidth - spaceHalf
        let top = y >= 0.0 ? y : 0.0
        let bottom = y <= 0.0 ? y : 0.0
        
        var bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
        getTransformer(set.axisDependency).rectValueToPixel(&bounds)
        
        return bounds
    }
    
    open override var lowestVisibleXIndex: Int
    {
        let step = CGFloat(_data.dataSetCount)
        let div = (step <= 1.0) ? 1.0 : step + (_data as! BarChartData).groupSpace
        
        var pt = CGPoint(x: _viewPortHandler.contentLeft, y: _viewPortHandler.contentBottom)
        getTransformer(ChartYAxis.AxisDependency.left).pixelToValue(&pt)
        
        return Int((pt.x <= CGFloat(chartXMin)) ? 0.0 : (pt.x / div) + 1.0)
    }

    open override var highestVisibleXIndex: Int
    {
        let step = CGFloat(_data.dataSetCount)
        let div = (step <= 1.0) ? 1.0 : step + (_data as! BarChartData).groupSpace
        
        var pt = CGPoint(x: _viewPortHandler.contentRight, y: _viewPortHandler.contentBottom)
        getTransformer(ChartYAxis.AxisDependency.left).pixelToValue(&pt)
        
        return Int((pt.x >= CGFloat(chartXMax)) ? CGFloat(chartXMax) / div : (pt.x / div))
    }

    // MARK: Accessors
    
    /// flag that enables or disables the highlighting arrow
    open var drawHighlightArrowEnabled: Bool
    {
        get { return _drawHighlightArrowEnabled; }
        set
        {
            _drawHighlightArrowEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    open var drawValueAboveBarEnabled: Bool
    {
        get { return _drawValueAboveBarEnabled; }
        set
        {
            _drawValueAboveBarEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    open var drawBarShadowEnabled: Bool
    {
        get { return _drawBarShadowEnabled; }
        set
        {
            _drawBarShadowEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// - returns: true if drawing the highlighting arrow is enabled, false if not
    open var isDrawHighlightArrowEnabled: Bool { return drawHighlightArrowEnabled; }
    
    /// - returns: true if drawing values above bars is enabled, false if not
    open var isDrawValueAboveBarEnabled: Bool { return drawValueAboveBarEnabled; }
    
    /// - returns: true if drawing shadows (maxvalue) for each bar is enabled, false if not
    open var isDrawBarShadowEnabled: Bool { return drawBarShadowEnabled; }
    
    // MARK: - BarChartRendererDelegate
    
    open func barChartRendererData(_ renderer: BarChartRenderer) -> BarChartData!
    {
        return _data as! BarChartData!
    }
    
    open func barChartRenderer(_ renderer: BarChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return getTransformer(which)
    }
    
    open func barChartRendererMaxVisibleValueCount(_ renderer: BarChartRenderer) -> Int
    {
        return maxVisibleValueCount
    }
    
    open func barChartDefaultRendererValueFormatter(_ renderer: BarChartRenderer) -> NumberFormatter!
    {
        return valueFormatter
    }
    
    open func barChartRendererChartYMax(_ renderer: BarChartRenderer) -> Double
    {
        return chartYMax
    }
    
    open func barChartRendererChartYMin(_ renderer: BarChartRenderer) -> Double
    {
        return chartYMin
    }
    
    open func barChartRendererChartXMax(_ renderer: BarChartRenderer) -> Double
    {
        return chartXMax
    }
    
    open func barChartRendererChartXMin(_ renderer: BarChartRenderer) -> Double
    {
        return chartXMin
    }
    
    open func barChartIsDrawHighlightArrowEnabled(_ renderer: BarChartRenderer) -> Bool
    {
        return drawHighlightArrowEnabled
    }
    
    open func barChartIsDrawValueAboveBarEnabled(_ renderer: BarChartRenderer) -> Bool
    {
        return drawValueAboveBarEnabled
    }
    
    open func barChartIsDrawBarShadowEnabled(_ renderer: BarChartRenderer) -> Bool
    {
        return drawBarShadowEnabled
    }
    
    open func barChartIsInverted(_ renderer: BarChartRenderer, axis: ChartYAxis.AxisDependency) -> Bool
    {
        return getAxis(axis).isInverted
    }
}
