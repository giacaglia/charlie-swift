//
//  ChartLegendRenderer.swift
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

open class ChartLegendRenderer: ChartRendererBase
{
    /// the legend object this renderer renders
    internal var _legend: ChartLegend!

    public init(viewPortHandler: ChartViewPortHandler, legend: ChartLegend?)
    {
        super.init(viewPortHandler: viewPortHandler)
        _legend = legend
    }

    /// Prepares the legend and calculates all needed forms, labels and colors.
    open func computeLegend(_ data: ChartData)
    {
        if (!_legend.isLegendCustom)
        {
            var labels = [String?]()
            var colors = [UIColor?]()
            
            // loop for building up the colors and labels used in the legend
            for (var i = 0, count = data.dataSetCount; i < count; i += 1)
            {
                let dataSet = data.getDataSetByIndex(i)!
                
                var clrs: [UIColor] = dataSet.colors
                let entryCount = dataSet.entryCount
                
                // if we have a barchart with stacked bars
                if (dataSet.isKind(of: BarChartDataSet.self) && (dataSet as! BarChartDataSet).isStacked)
                {
                    let bds = dataSet as! BarChartDataSet
                    var sLabels = bds.stackLabels
                    
                    for (var j = 0; j < clrs.count && j < bds.stackSize; j += 1)
                    {
                        labels.append(sLabels[j % sLabels.count])
                        colors.append(clrs[j])
                    }
                    
                    if (bds.label != nil)
                    {
                        // add the legend description label
                        colors.append(nil)
                        labels.append(bds.label)
                    }
                }
                else if (dataSet.isKind(of: PieChartDataSet.self))
                {
                    var xVals = data.xVals
                    let pds = dataSet as! PieChartDataSet
                    
                    for (var j = 0; j < clrs.count && j < entryCount && j < xVals.count; j += 1)
                    {
                        labels.append(xVals[j])
                        colors.append(clrs[j])
                    }
                    
                    if (pds.label != nil)
                    {
                        // add the legend description label
                        colors.append(nil)
                        labels.append(pds.label)
                    }
                }
                else
                { // all others
                    
                    for (var j = 0; j < clrs.count && j < entryCount; j += 1)
                    {
                        // if multiple colors are set for a DataSet, group them
                        if (j < clrs.count - 1 && j < entryCount - 1)
                        {
                            labels.append(nil)
                        }
                        else
                        { // add label to the last entry
                            labels.append(dataSet.label)
                        }
                        
                        colors.append(clrs[j])
                    }
                }
            }
            
            _legend.colors = colors + _legend._extraColors
            _legend.labels = labels + _legend._extraLabels
        }
        
        // calculate all dimensions of the legend
        _legend.calculateDimensions(labelFont: _legend.font, viewPortHandler: viewPortHandler)
    }
    
    open func renderLegend(context: CGContext?)
    {
        if (_legend === nil || !_legend.enabled)
        {
            return
        }
        
        let labelFont = _legend.font
        let labelTextColor = _legend.textColor
        let labelLineHeight = labelFont.lineHeight
        let formYOffset = labelLineHeight / 2.0

        var labels = _legend.labels
        var colors = _legend.colors
        
        let formSize = _legend.formSize
        let formToTextSpace = _legend.formToTextSpace
        let xEntrySpace = _legend.xEntrySpace
        let direction = _legend.direction

        // space between the entries
        let stackSpace = _legend.stackSpace

        let yoffset = _legend.yOffset
        let xoffset = _legend.xOffset
        
        let legendPosition = _legend.position
        
        switch (legendPosition)
        {
        case .belowChartLeft: fallthrough
        case .belowChartRight: fallthrough
        case .belowChartCenter:
            
            let contentWidth: CGFloat = viewPortHandler.contentWidth
            
            var originPosX: CGFloat
            
            if (legendPosition == .belowChartLeft)
            {
                originPosX = viewPortHandler.contentLeft + xoffset
                
                if (direction == .rightToLeft)
                {
                    originPosX += _legend.neededWidth
                }
            }
            else if (legendPosition == .belowChartRight)
            {
                originPosX = viewPortHandler.contentRight - xoffset
                
                if (direction == .leftToRight)
                {
                    originPosX -= _legend.neededWidth
                }
            }
            else // if (legendPosition == .BelowChartCenter)
            {
                originPosX = viewPortHandler.contentLeft + contentWidth / 2.0
            }
            
            var calculatedLineSizes = _legend.calculatedLineSizes
            var calculatedLabelSizes = _legend.calculatedLabelSizes
            var calculatedLabelBreakPoints = _legend.calculatedLabelBreakPoints
            
            var posX: CGFloat = originPosX
            var posY: CGFloat = viewPortHandler.chartHeight - yoffset - _legend.neededHeight
            
            var lineIndex: Int = 0
            
            for (var i = 0, count = labels.count; i < count; i += 1)
            {
                if (calculatedLabelBreakPoints[i])
                {
                    posX = originPosX
                    posY += labelLineHeight
                }
                
                if (posX == originPosX && legendPosition == .belowChartCenter)
                {
                    posX += (direction == .rightToLeft ? calculatedLineSizes[lineIndex].width : -calculatedLineSizes[lineIndex].width) / 2.0
                    lineIndex += 1
                }
                
                let drawingForm = colors[i] != nil
                let isStacked = labels[i] == nil; // grouped forms have null labels
                
                if (drawingForm)
                {
                    if (direction == .rightToLeft)
                    {
                        posX -= formSize
                    }
                    
                    drawForm(context, x: posX, y: posY + formYOffset, colorIndex: i, legend: _legend)
                    
                    if (direction == .leftToRight)
                    {
                        posX += formSize
                    }
                }
                
                if (!isStacked)
                {
                    if (drawingForm)
                    {
                        posX += direction == .rightToLeft ? -formToTextSpace : formToTextSpace
                    }
                    
                    if (direction == .rightToLeft)
                    {
                        posX -= calculatedLabelSizes[i].width
                    }
                    
                    drawLabel(context, x: posX, y: posY, label: labels[i]!, font: labelFont, textColor: labelTextColor)
                    
                    if (direction == .leftToRight)
                    {
                        posX += calculatedLabelSizes[i].width
                    }
                    
                    posX += direction == .rightToLeft ? -xEntrySpace : xEntrySpace
                }
                else
                {
                    posX += direction == .rightToLeft ? -stackSpace : stackSpace
                }
            }
            
            break
            
        case .piechartCenter: fallthrough
        case .rightOfChart: fallthrough
        case .rightOfChartCenter: fallthrough
        case .rightOfChartInside: fallthrough
        case .leftOfChart: fallthrough
        case .leftOfChartCenter: fallthrough
        case .leftOfChartInside:
            
            // contains the stacked legend size in pixels
            var stack = CGFloat(0.0)
            var wasStacked = false
            var posX: CGFloat = 0.0, posY: CGFloat = 0.0
            
            if (legendPosition == .piechartCenter)
            {
                posX = viewPortHandler.chartWidth / 2.0 + (direction == .leftToRight ? -_legend.textWidthMax / 2.0 : _legend.textWidthMax / 2.0)
                posY = viewPortHandler.chartHeight / 2.0 - _legend.neededHeight / 2.0 + _legend.yOffset
            }
            else
            {
                let isRightAligned = legendPosition == .rightOfChart ||
                    legendPosition == .rightOfChartCenter ||
                    legendPosition == .rightOfChartInside
                
                if (isRightAligned)
                {
                    posX = viewPortHandler.chartWidth - xoffset
                    if (direction == .leftToRight)
                    {
                        posX -= _legend.textWidthMax
                    }
                }
                else
                {
                    posX = xoffset
                    if (direction == .rightToLeft)
                    {
                        posX += _legend.textWidthMax
                    }
                }
                
                if (legendPosition == .rightOfChart ||
                    legendPosition == .leftOfChart)
                {
                    posY = viewPortHandler.contentTop + yoffset
                }
                else if (legendPosition == .rightOfChartCenter ||
                    legendPosition == .leftOfChartCenter)
                {
                    posY = viewPortHandler.chartHeight / 2.0 - _legend.neededHeight / 2.0
                }
                else /*if (legend.position == .RightOfChartInside ||
                    legend.position == .LeftOfChartInside)*/
                {
                    posY = viewPortHandler.contentTop + yoffset
                }
            }
            
            
            for (var i = 0; i <  labels.count; i++)
            {
                let drawingForm = colors[i] != nil
                var x = posX
                
                if (drawingForm)
                {
                    if (direction == .leftToRight)
                    {
                        x += stack
                    }
                    else
                    {
                        x -= formSize - stack
                    }
                    
                    drawForm(context, x: x, y: posY + formYOffset, colorIndex: i, legend: _legend)
                    
                    if (direction == .leftToRight)
                    {
                        x += formSize
                    }
                }
                
                if (labels[i] != nil)
                {
                    if (drawingForm && !wasStacked)
                    {
                        x += direction == .leftToRight ? formToTextSpace : -formToTextSpace
                    }
                    else if (wasStacked)
                    {
                        x = posX
                    }
                    
                    if (direction == .rightToLeft)
                    {
                        x -= (labels[i] as NSString!).size(attributes: [NSFontAttributeName: labelFont]).width
                    }
                    
                    if (!wasStacked)
                    {
                        drawLabel(context, x: x, y: posY, label: labels[i]!, font: labelFont, textColor: labelTextColor)
                    }
                    else
                    {
                        posY += labelLineHeight
                        drawLabel(context, x: x, y: posY, label: labels[i]!, font: labelFont, textColor: labelTextColor)
                    }
                    
                    // make a step down
                    posY += labelLineHeight
                    stack = 0.0
                }
                else
                {
                    stack += formSize + stackSpace
                    wasStacked = true
                }
            }
            
            break
        }
    }

    fileprivate var _formLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    /// Draws the Legend-form at the given position with the color at the given index.
    internal func drawForm(_ context: CGContext?, x: CGFloat, y: CGFloat, colorIndex: Int, legend: ChartLegend)
    {
        let formColor = legend.colors[colorIndex]
        
        if (formColor === nil || formColor == UIColor.clear)
        {
            return
        }
        
        let formsize = legend.formSize
        
        context?.saveGState()
        
        switch (legend.form)
        {
        case .circle:
            context?.setFillColor(formColor!.cgColor)
            context?.fillEllipse(in: CGRect(x: x, y: y - formsize / 2.0, width: formsize, height: formsize))
            break
        case .square:
            context?.setFillColor(formColor!.cgColor)
            context?.fill(CGRect(x: x, y: y - formsize / 2.0, width: formsize, height: formsize))
            break
        case .line:
            
            context?.setLineWidth(legend.formLineWidth)
            context?.setStrokeColor(formColor!.cgColor)
            
            _formLineSegmentsBuffer[0].x = x
            _formLineSegmentsBuffer[0].y = y
            _formLineSegmentsBuffer[1].x = x + formsize
            _formLineSegmentsBuffer[1].y = y
            CGContextStrokeLineSegments(context, _formLineSegmentsBuffer, 2)
            
            break
        }
        
        context?.restoreGState()
    }

    /// Draws the provided label at the given position.
    internal func drawLabel(_ context: CGContext?, x: CGFloat, y: CGFloat, label: String, font: UIFont, textColor: UIColor)
    {
        ChartUtils.drawText(context: context, text: label, point: CGPoint(x: x, y: y), align: .left, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor])
    }
}
