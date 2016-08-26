//
//  HorizontalBarChartView.swift
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
import UIKit

/// BarChart with horizontal bar orientation. In this implementation, x- and y-axis are switched.
open class HorizontalBarChartView: BarChartView
{
    internal override func initialize()
    {
        super.initialize()
        
        _leftAxisTransformer = ChartTransformerHorizontalBarChart(viewPortHandler: _viewPortHandler)
        _rightAxisTransformer = ChartTransformerHorizontalBarChart(viewPortHandler: _viewPortHandler)
        
        renderer = HorizontalBarChartRenderer(delegate: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _leftYAxisRenderer = ChartYAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, yAxis: _leftAxis, transformer: _leftAxisTransformer)
        _rightYAxisRenderer = ChartYAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, yAxis: _rightAxis, transformer: _rightAxisTransformer)
        _xAxisRenderer = ChartXAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer, chart: self)
        
        _highlighter = HorizontalBarChartHighlighter(chart: self)
    }
    
    internal override func calculateOffsets()
    {
        var offsetLeft: CGFloat = 0.0,
        offsetRight: CGFloat = 0.0,
        offsetTop: CGFloat = 0.0,
        offsetBottom: CGFloat = 0.0
        
        // setup offsets for legend
        if (_legend !== nil && _legend.isEnabled)
        {
            if (_legend.position == .rightOfChart
                || _legend.position == .rightOfChartCenter)
            {
                offsetRight += min(_legend.neededWidth, _viewPortHandler.chartWidth * _legend.maxSizePercent) + _legend.xOffset * 2.0
            }
            else if (_legend.position == .leftOfChart
                || _legend.position == .leftOfChartCenter)
            {
                offsetLeft += min(_legend.neededWidth, _viewPortHandler.chartWidth * _legend.maxSizePercent) + _legend.xOffset * 2.0
            }
            else if (_legend.position == .belowChartLeft
                || _legend.position == .belowChartRight
                || _legend.position == .belowChartCenter)
            {
                let yOffset = _legend.textHeightMax * 2.0; // It's possible that we do not need this offset anymore as it is available through the extraOffsets
                offsetBottom += min(_legend.neededHeight + yOffset, _viewPortHandler.chartHeight * _legend.maxSizePercent)
            }
        }
        
        // offsets for y-labels
        if (_leftAxis.needsOffset)
        {
            offsetTop += _leftAxis.getRequiredHeightSpace()
        }
        
        if (_rightAxis.needsOffset)
        {
            offsetBottom += _rightAxis.getRequiredHeightSpace()
        }
        
        let xlabelwidth = _xAxis.labelWidth
        
        if (_xAxis.isEnabled)
        {
            // offsets for x-labels
            if (_xAxis.labelPosition == .bottom)
            {
                offsetLeft += xlabelwidth
            }
            else if (_xAxis.labelPosition == .top)
            {
                offsetRight += xlabelwidth
            }
            else if (_xAxis.labelPosition == .bothSided)
            {
                offsetLeft += xlabelwidth
                offsetRight += xlabelwidth
            }
        }
        
        offsetTop += self.extraTopOffset
        offsetRight += self.extraRightOffset
        offsetBottom += self.extraBottomOffset
        offsetLeft += self.extraLeftOffset
        
        let minOffset: CGFloat = 10.0
        
        _viewPortHandler.restrainViewPort(
            offsetLeft: max(minOffset, offsetLeft),
            offsetTop: max(minOffset, offsetTop),
            offsetRight: max(minOffset, offsetRight),
            offsetBottom: max(minOffset, offsetBottom))
        
        prepareOffsetMatrix()
        prepareValuePxMatrix()
    }
    
    internal override func prepareValuePxMatrix()
    {
        _rightAxisTransformer.prepareMatrixValuePx(chartXMin: _rightAxis.axisMinimum, deltaX: CGFloat(_rightAxis.axisRange), deltaY: _deltaX, chartYMin: _chartXMin)
        _leftAxisTransformer.prepareMatrixValuePx(chartXMin: _leftAxis.axisMinimum, deltaX: CGFloat(_leftAxis.axisRange), deltaY: _deltaX, chartYMin: _chartXMin)
    }

    internal override func calcModulus()
    {
        _xAxis.axisLabelModulus = Int(ceil((CGFloat(_data.xValCount) * _xAxis.labelHeight) / (_viewPortHandler.contentHeight * viewPortHandler.touchMatrix.d)))
        
        if (_xAxis.axisLabelModulus < 1)
        {
            _xAxis.axisLabelModulus = 1
        }
    }
    
    open override func getBarBounds(_ e: BarChartDataEntry) -> CGRect!
    {
        let set = _data.getDataSetForEntry(e) as! BarChartDataSet!
        
        if (set === nil)
        {
            return nil
        }
        
        let barspace = set.barSpace
        let y = CGFloat(e.value)
        let x = CGFloat(e.xIndex)
        
        let spaceHalf = barspace / 2.0
        let top = x - 0.5 + spaceHalf
        let bottom = x + 0.5 - spaceHalf
        let left = y >= 0.0 ? y : 0.0
        let right = y <= 0.0 ? y : 0.0
        
        var bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
        getTransformer(set.axisDependency).rectValueToPixel(&bounds)
        
        return bounds
    }
    
    open override func getPosition(_ e: ChartDataEntry, axis: ChartYAxis.AxisDependency) -> CGPoint
    {
        var vals = CGPoint(x: CGFloat(e.value), y: CGFloat(e.xIndex))
        
        getTransformer(axis).pointValueToPixel(&vals)
        
        return vals
    }

    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> ChartHighlight?
    {
        if (_dataNotSet || _data === nil)
        {
            print("Can't select by touch. No data set.", terminator: "\n")
            return nil
        }
        
        return _highlighter?.getHighlight(x: Double(pt.y), y: Double(pt.x))
    }
    
    open override var lowestVisibleXIndex: Int
    {
        let step = CGFloat(_data.dataSetCount)
        let div = (step <= 1.0) ? 1.0 : step + (_data as! BarChartData).groupSpace
        
        var pt = CGPoint(x: _viewPortHandler.contentLeft, y: _viewPortHandler.contentBottom)
        getTransformer(ChartYAxis.AxisDependency.left).pixelToValue(&pt)
        
        return Int(((pt.y <= 0.0) ? 0.0 : pt.y / div) + 1.0)
    }
    
    open override var highestVisibleXIndex: Int
    {
        let step = CGFloat(_data.dataSetCount)
        let div = (step <= 1.0) ? 1.0 : step + (_data as! BarChartData).groupSpace
        
        var pt = CGPoint(x: _viewPortHandler.contentLeft, y: _viewPortHandler.contentTop)
        getTransformer(ChartYAxis.AxisDependency.left).pixelToValue(&pt)
        
        return Int((pt.y >= CGFloat(chartXMax)) ? CGFloat(chartXMax) / div : (pt.y / div))
    }
}
