//
//  RadarChartRenderer.swift
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

open class RadarChartRenderer: LineScatterCandleRadarChartRenderer
{
    internal weak var _chart: RadarChartView!

    public init(chart: RadarChartView, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        _chart = chart
    }
    
    open override func drawData(context: CGContext?)
    {
        if (_chart !== nil)
        {
            let radarData = _chart.data
            
            if (radarData != nil)
            {
                for set in radarData!.dataSets as! [RadarChartDataSet]
                {
                    if set.isVisible && set.entryCount > 0
                    {
                        drawDataSet(context: context, dataSet: set)
                    }
                }
            }
        }
    }
    
    internal func drawDataSet(context: CGContext?, dataSet: RadarChartDataSet)
    {
        context?.saveGState()
        
        let sliceangle = _chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = _chart.factor
        
        let center = _chart.centerOffsets
        var entries = dataSet.yVals
        let path = CGMutablePath()
        var hasMovedToPoint = false
        
        for (j in 0 ..< entries.count)
        {
            let e = entries[j]
            
            let p = ChartUtils.getPosition(center: center, dist: CGFloat(e.value - _chart.chartYMin) * factor, angle: sliceangle * CGFloat(j) + _chart.rotationAngle)
            
            if (p.x.isNaN)
            {
                continue
            }
            
            if (!hasMovedToPoint)
            {
                CGPathMoveToPoint(path, nil, p.x, p.y)
                hasMovedToPoint = true
            }
            else
            {
                CGPathAddLineToPoint(path, nil, p.x, p.y)
            }
        }
        
        path.closeSubpath()
        
        // draw filled
        if (dataSet.isDrawFilledEnabled)
        {
            context.setFillColor(dataSet.colorAt(0).cgColor)
            context?.setAlpha(dataSet.fillAlpha)
            
            context?.beginPath()
            context?.addPath(path)
            context?.fillPath()
        }
        
        // draw the line (only if filled is disabled or alpha is below 255)
        if (!dataSet.isDrawFilledEnabled || dataSet.fillAlpha < 1.0)
        {
            context.setStrokeColor(dataSet.colorAt(0).cgColor)
            context?.setLineWidth(dataSet.lineWidth)
            context?.setAlpha(1.0)
            
            context?.beginPath()
            context?.addPath(path)
            context?.strokePath()
        }
        
        context?.restoreGState()
    }
    
    open override func drawValues(context: CGContext?)
    {
        if (_chart.data === nil)
        {
            return
        }
        
        let data = _chart.data!
        
        let defaultValueFormatter = _chart.valueFormatter
        
        let sliceangle = _chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = _chart.factor
        
        let center = _chart.centerOffsets
        
        let yoffset = CGFloat(5.0)
        
        for (var i = 0, count = data.dataSetCount; i < count; i += 1)
        {
            let dataSet = data.getDataSetByIndex(i) as! RadarChartDataSet
            
            if !dataSet.isDrawValuesEnabled || dataSet.entryCount == 0
            {
                continue
            }
            
            var entries = dataSet.yVals
            
            for (var j = 0; j < entries.count; j += 1)
            {
                let e = entries[j]
                
                let p = ChartUtils.getPosition(center: center, dist: CGFloat(e.value) * factor, angle: sliceangle * CGFloat(j) + _chart.rotationAngle)
                
                let valueFont = dataSet.valueFont
                let valueTextColor = dataSet.valueTextColor
                
                var formatter = dataSet.valueFormatter
                if (formatter === nil)
                {
                    formatter = defaultValueFormatter
                }
                
                ChartUtils.drawText(context: context, text: formatter!.string(from: e.value)!, point: CGPoint(x: p.x, y: p.y - yoffset - valueFont.lineHeight), align: .center, attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: valueTextColor])
            }
        }
    }
    
    open override func drawExtras(context: CGContext?)
    {
        drawWeb(context: context)
    }
    
    fileprivate var _webLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    internal func drawWeb(context: CGContext?)
    {
        let sliceangle = _chart.sliceAngle
        
        context?.saveGState()
        
        // calculate the factor that is needed for transforming the value to
        // pixels
        let factor = _chart.factor
        let rotationangle = _chart.rotationAngle
        
        let center = _chart.centerOffsets
        
        // draw the web lines that come from the center
        context?.setLineWidth(_chart.webLineWidth)
        context?.setStrokeColor(_chart.webColor.cgColor)
        context?.setAlpha(_chart.webAlpha)
        
        for (var i = 0, xValCount = _chart.data!.xValCount; i < xValCount; i += 1)
        {
            let p = ChartUtils.getPosition(center: center, dist: CGFloat(_chart.yRange) * factor, angle: sliceangle * CGFloat(i) + rotationangle)
            
            _webLineSegmentsBuffer[0].x = center.x
            _webLineSegmentsBuffer[0].y = center.y
            _webLineSegmentsBuffer[1].x = p.x
            _webLineSegmentsBuffer[1].y = p.y
            
            CGContextStrokeLineSegments(context, _webLineSegmentsBuffer, 2)
        }
        
        // draw the inner-web
        context?.setLineWidth(_chart.innerWebLineWidth)
        context?.setStrokeColor(_chart.innerWebColor.cgColor)
        context?.setAlpha(_chart.webAlpha)
        
        let labelCount = _chart.yAxis.entryCount
        
        for (j in 0 ..< labelCount)
        {
            for (var i = 0, xValCount = _chart.data!.xValCount; i < xValCount; i += 1)
            {
                let r = CGFloat(_chart.yAxis.entries[j] - _chart.chartYMin) * factor

                let p1 = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(i) + rotationangle)
                let p2 = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(i + 1) + rotationangle)
                
                _webLineSegmentsBuffer[0].x = p1.x
                _webLineSegmentsBuffer[0].y = p1.y
                _webLineSegmentsBuffer[1].x = p2.x
                _webLineSegmentsBuffer[1].y = p2.y
                
                CGContextStrokeLineSegments(context, _webLineSegmentsBuffer, 2)
            }
        }
        
        context?.restoreGState()
    }
    
    fileprivate var _highlightPtsBuffer = [CGPoint](repeating: CGPoint(), count: 4)

    open override func drawHighlighted(context: CGContext?, indices: [ChartHighlight])
    {
        if (_chart.data === nil)
        {
            return
        }
        
        let data = _chart.data as! RadarChartData
        
        context?.saveGState()
        context?.setLineWidth(data.highlightLineWidth)
        if (data.highlightLineDashLengths != nil)
        {
            CGContextSetLineDash(context, data.highlightLineDashPhase, data.highlightLineDashLengths!, data.highlightLineDashLengths!.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        let sliceangle = _chart.sliceAngle
        let factor = _chart.factor
        
        let center = _chart.centerOffsets
        
        for (i in 0 ..< indices.count)
        {
            let set = _chart.data?.getDataSetByIndex(indices[i].dataSetIndex) as! RadarChartDataSet!
            
            if (set === nil || !set.isHighlightEnabled)
            {
                continue
            }
            
            context.setStrokeColor(set.highlightColor.cgColor)
            
            // get the index to highlight
            let xIndex = indices[i].xIndex
            
            let e = set.entryForXIndex(xIndex)
            if (e === nil || e!.xIndex != xIndex)
            {
                continue
            }
            
            let j = set.entryIndex(entry: e!, isEqual: true)
            let y = (e!.value - _chart.chartYMin)
            
            if (y.isNaN)
            {
                continue
            }
            
            let p = ChartUtils.getPosition(center: center, dist: CGFloat(y) * factor,
                angle: sliceangle * CGFloat(j) + _chart.rotationAngle)
            
            _highlightPtsBuffer[0] = CGPoint(x: p.x, y: 0.0)
            _highlightPtsBuffer[1] = CGPoint(x: p.x, y: viewPortHandler.chartHeight)
            _highlightPtsBuffer[2] = CGPoint(x: 0.0, y: p.y)
            _highlightPtsBuffer[3] = CGPoint(x: viewPortHandler.chartWidth, y: p.y)
            
            // draw the lines
            drawHighlightLines(context: context, points: _highlightPtsBuffer,
                horizontal: set.isHorizontalHighlightIndicatorEnabled, vertical: set.isVerticalHighlightIndicatorEnabled)
        }
        
        context?.restoreGState()
    }
}
