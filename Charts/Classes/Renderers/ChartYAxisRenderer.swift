//
//  ChartYAxisRenderer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
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

open class ChartYAxisRenderer: ChartAxisRendererBase
{
    internal var _yAxis: ChartYAxis!
    
    public init(viewPortHandler: ChartViewPortHandler, yAxis: ChartYAxis, transformer: ChartTransformer!)
    {
        super.init(viewPortHandler: viewPortHandler, transformer: transformer)
        
        _yAxis = yAxis
    }
    
    /// Computes the axis values.
    public func computeAxis(yMin: Double, yMax: Double)
    {
        var yMin = yMin, yMax = yMax
        // calculate the starting and entry point of the y-labels (depending on
        // zoom / contentrect bounds)
        if (viewPortHandler.contentWidth > 10.0 && !viewPortHandler.isFullyZoomedOutY)
        {
            let p1 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            let p2 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            
            if (!_yAxis.isInverted)
            {
                yMin = Double(p2.y)
                yMax = Double(p1.y)
            }
            else
            {
                yMin = Double(p1.y)
                yMax = Double(p2.y)
            }
        }
        
        computeAxisValues(min: yMin, max: yMax)
    }
    
    /// Sets up the y-axis labels. Computes the desired number of labels between
    /// the two given extremes. Unlike the papareXLabels() method, this method
    /// needs to be called upon every refresh of the view.
    internal func computeAxisValues(min: Double, max: Double)
    {
        let yMin = min
        let yMax = max
        
        let labelCount = _yAxis.labelCount
        let range = abs(yMax - yMin)
    
        if (labelCount == 0 || range <= 0)
        {
            _yAxis.entries = [Double]()
            return
        }
        
        let rawInterval = range / Double(labelCount)
        var interval = ChartUtils.roundToNextSignificant(number: Double(rawInterval))
        let intervalMagnitude = pow(10.0, round(log10(interval)))
        let intervalSigDigit = (interval / intervalMagnitude)
        if (intervalSigDigit > 5)
        {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or 90
            interval = floor(10.0 * intervalMagnitude)
        }
        
        // force label count
        if _yAxis.isForceLabelsEnabled
        {
            let step = Double(range) / Double(labelCount - 1)
            
            if _yAxis.entries.count < labelCount
            {
                // Ensure stops contains at least numStops elements.
                _yAxis.entries.removeAll(keepingCapacity: true)
            }
            else
            {
                _yAxis.entries = [Double]()
                _yAxis.entries.reserveCapacity(labelCount)
            }
            
            var v = yMin
            
            for (i in 0 ..< labelCount)
            {
                _yAxis.entries.append(v)
                v += step
            }
            
        }
        else
        {
            // no forced count
            
        // if the labels should only show min and max
        if (_yAxis.isShowOnlyMinMaxEnabled)
        {
            _yAxis.entries = [yMin, yMax]
        }
        else
        {
            let first = ceil(Double(yMin) / interval) * interval
            let last = ChartUtils.nextUp(floor(Double(yMax) / interval) * interval)
            
            var f: Double
            var i: Int
            var n = 0
            for (f = first; f <= last; f += interval)
            {
                n += 1
            }
            
            if (_yAxis.entries.count < n)
            {
                // Ensure stops contains at least numStops elements.
                _yAxis.entries = [Double](repeating: 0.0, count: n)
            }
            else if (_yAxis.entries.count > n)
            {
                _yAxis.entries.removeSubrange(n..<_yAxis.entries.count)
            }
            
            for (f = first, i = 0; i < n; f += interval, ++i)
            {
                _yAxis.entries[i] = Double(f)
            }
        }
    }
    }
    
    /// draws the y-axis labels to the screen
    open override func renderAxisLabels(context: CGContext?)
    {
        if (!_yAxis.isEnabled || !_yAxis.isDrawLabelsEnabled)
        {
            return
        }
        
        let xoffset = _yAxis.xOffset
        let yoffset = _yAxis.labelFont.lineHeight / 2.5 + _yAxis.yOffset
        
        let dependency = _yAxis.axisDependency
        let labelPosition = _yAxis.labelPosition
        
        var xPos = CGFloat(0.0)
        
        var textAlign: NSTextAlignment
        
        if (dependency == .left)
        {
            if (labelPosition == .outsideChart)
            {
                textAlign = .right
                xPos = viewPortHandler.offsetLeft - xoffset
            }
            else
            {
                textAlign = .left
                xPos = viewPortHandler.offsetLeft + xoffset
            }
            
        }
        else
        {
            if (labelPosition == .outsideChart)
            {
                textAlign = .left
                xPos = viewPortHandler.contentRight + xoffset
            }
            else
            {
                textAlign = .right
                xPos = viewPortHandler.contentRight - xoffset
            }
        }
        
        drawYLabels(context: context, fixedPosition: xPos, offset: yoffset - _yAxis.labelFont.lineHeight, textAlign: textAlign)
    }
    
    fileprivate var _axisLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderAxisLine(context: CGContext?)
    {
        if (!_yAxis.isEnabled || !_yAxis.drawAxisLineEnabled)
        {
            return
        }
        
        context?.saveGState()
        
        context.setStrokeColor(_yAxis.axisLineColor.cgColor)
        context?.setLineWidth(_yAxis.axisLineWidth)
        if (_yAxis.axisLineDashLengths != nil)
        {
            CGContextSetLineDash(context, _yAxis.axisLineDashPhase, _yAxis.axisLineDashLengths, _yAxis.axisLineDashLengths.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        if (_yAxis.axisDependency == .left)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2)
        }
        else
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2)
        }
        
        context?.restoreGState()
    }
    
    /// draws the y-labels on the specified x-position
    internal func drawYLabels(context: CGContext?, fixedPosition: CGFloat, offset: CGFloat, textAlign: NSTextAlignment)
    {
        let labelFont = _yAxis.labelFont
        let labelTextColor = _yAxis.labelTextColor
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var pt = CGPoint()
        
        for (i in 0 ..< _yAxis.entryCount)
        {
            let text = _yAxis.getFormattedLabel(i)
            
            if (!_yAxis.isDrawTopYLabelEntryEnabled && i >= _yAxis.entryCount - 1)
            {
                break
            }
            
            pt.x = 0
            pt.y = CGFloat(_yAxis.entries[i])
            pt = pt.applying(valueToPixelMatrix)
            
            pt.x = fixedPosition
            pt.y += offset
            
            ChartUtils.drawText(context: context, text: text, point: pt, align: textAlign, attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor])
        }
    }
    
    fileprivate var _gridLineBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderGridLines(context: CGContext?)
    {
        if (!_yAxis.isDrawGridLinesEnabled || !_yAxis.isEnabled)
        {
            return
        }
        
        context?.saveGState()
        
        context.setStrokeColor(_yAxis.gridColor.cgColor)
        context?.setLineWidth(_yAxis.gridLineWidth)
        if (_yAxis.gridLineDashLengths != nil)
        {
            CGContextSetLineDash(context, _yAxis.gridLineDashPhase, _yAxis.gridLineDashLengths, _yAxis.gridLineDashLengths.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        // draw the horizontal grid
        for (var i = 0, count = _yAxis.entryCount; i < count; i += 1)
        {
            position.x = 0.0
            position.y = CGFloat(_yAxis.entries[i])
            position = position.applying(valueToPixelMatrix)
        
            _gridLineBuffer[0].x = viewPortHandler.contentLeft
            _gridLineBuffer[0].y = position.y
            _gridLineBuffer[1].x = viewPortHandler.contentRight
            _gridLineBuffer[1].y = position.y
            CGContextStrokeLineSegments(context, _gridLineBuffer, 2)
        }
        
        context?.restoreGState()
    }
    
    fileprivate var _limitLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderLimitLines(context: CGContext?)
    {
        var limitLines = _yAxis.limitLines
        
        if (limitLines.count == 0)
        {
            return
        }
        
        context?.saveGState()
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for (i in 0 ..< limitLines.count)
        {
            let l = limitLines[i]
            
            position.x = 0.0
            position.y = CGFloat(l.limit)
            position = position.applying(trans)
            
            _limitLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _limitLineSegmentsBuffer[0].y = position.y
            _limitLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _limitLineSegmentsBuffer[1].y = position.y
            
            context?.setStrokeColor(l.lineColor.cgColor)
            context?.setLineWidth(l.lineWidth)
            if (l.lineDashLengths != nil)
            {
                CGContextSetLineDash(context, l.lineDashPhase, l.lineDashLengths!, l.lineDashLengths!.count)
            }
            else
            {
                CGContextSetLineDash(context, 0.0, nil, 0)
            }
            
            CGContextStrokeLineSegments(context, _limitLineSegmentsBuffer, 2)
            
            let label = l.label
            
            // if drawing the limit-value label is enabled
            if (label.characters.count > 0)
            {
                let labelLineHeight = l.valueFont.lineHeight
                
                let add = CGFloat(4.0)
                let xOffset: CGFloat = add
                let yOffset: CGFloat = l.lineWidth + labelLineHeight
                
                if (l.labelPosition == .rightTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentRight - xOffset,
                            y: position.y - yOffset),
                        align: .right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .rightBottom)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentRight - xOffset,
                            y: position.y + yOffset - labelLineHeight),
                        align: .right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .leftTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentLeft + xOffset,
                            y: position.y - yOffset),
                        align: .left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentLeft + xOffset,
                            y: position.y + yOffset - labelLineHeight),
                        align: .left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
            }
        }
        
        context?.restoreGState()
    }
}
