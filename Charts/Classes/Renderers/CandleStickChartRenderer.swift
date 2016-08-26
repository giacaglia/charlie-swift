//
//  CandleStickChartRenderer.swift
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

@objc
public protocol CandleStickChartRendererDelegate
{
    func candleStickChartRendererCandleData(_ renderer: CandleStickChartRenderer) -> CandleChartData!
    func candleStickChartRenderer(_ renderer: CandleStickChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    func candleStickChartDefaultRendererValueFormatter(_ renderer: CandleStickChartRenderer) -> NumberFormatter!
    func candleStickChartRendererChartYMax(_ renderer: CandleStickChartRenderer) -> Double
    func candleStickChartRendererChartYMin(_ renderer: CandleStickChartRenderer) -> Double
    func candleStickChartRendererChartXMax(_ renderer: CandleStickChartRenderer) -> Double
    func candleStickChartRendererChartXMin(_ renderer: CandleStickChartRenderer) -> Double
    func candleStickChartRendererMaxVisibleValueCount(_ renderer: CandleStickChartRenderer) -> Int
}

open class CandleStickChartRenderer: LineScatterCandleRadarChartRenderer
{
    open weak var delegate: CandleStickChartRendererDelegate?
    
    public init(delegate: CandleStickChartRendererDelegate?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.delegate = delegate
    }
    
    open override func drawData(context: CGContext?)
    {
        let candleData = delegate!.candleStickChartRendererCandleData(self)

        for set in candleData?.dataSets as! [CandleChartDataSet]
        {
            if set.isVisible && set.entryCount > 0
            {
                drawDataSet(context: context, dataSet: set)
            }
        }
    }
    
    fileprivate var _shadowPoints = [CGPoint](repeating: CGPoint(), count: 2)
    fileprivate var _bodyRect = CGRect()
    fileprivate var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    internal func drawDataSet(context: CGContext?, dataSet: CandleChartDataSet)
    {
        let trans = delegate!.candleStickChartRenderer(self, transformerForAxis: dataSet.axisDependency)
        
        let phaseX = _animator.phaseX
        let phaseY = _animator.phaseY
        let bodySpace = dataSet.bodySpace
        
        var entries = dataSet.yVals as! [CandleChartDataEntry]
        
        let minx = max(_minX, 0)
        let maxx = min(_maxX + 1, entries.count)
        
        context?.saveGState()
        
        context?.setLineWidth(dataSet.shadowWidth)
        
        for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); j < count; j += 1)
        {
            // get the entry
            let e = entries[j]
            
            if (e.xIndex < _minX || e.xIndex > _maxX)
            {
                continue
            }
            
            // calculate the shadow
            
            _shadowPoints[0].x = CGFloat(e.xIndex)
            _shadowPoints[0].y = CGFloat(e.high) * phaseY
            _shadowPoints[1].x = CGFloat(e.xIndex)
            _shadowPoints[1].y = CGFloat(e.low) * phaseY
            
            trans.pointValuesToPixel(&_shadowPoints)
            
            // draw the shadow
            
            var shadowColor: UIColor! = nil
            if (dataSet.shadowColorSameAsCandle)
            {
                if (e.open > e.close)
                {
                    shadowColor = dataSet.decreasingColor ?? dataSet.colorAt(j)
                }
                else if (e.open < e.close)
                {
                    shadowColor = dataSet.increasingColor ?? dataSet.colorAt(j)
                }
            }
            
            if (shadowColor === nil)
            {
                shadowColor = dataSet.shadowColor ?? dataSet.colorAt(j);
            }
            
            context?.setStrokeColor(shadowColor.cgColor)
            CGContextStrokeLineSegments(context, _shadowPoints, 2)
            
            // calculate the body
            
            _bodyRect.origin.x = CGFloat(e.xIndex) - 0.5 + bodySpace
            _bodyRect.origin.y = CGFloat(e.close) * phaseY
            _bodyRect.size.width = (CGFloat(e.xIndex) + 0.5 - bodySpace) - _bodyRect.origin.x
            _bodyRect.size.height = (CGFloat(e.open) * phaseY) - _bodyRect.origin.y
            
            trans.rectValueToPixel(&_bodyRect)
            
            // draw body differently for increasing and decreasing entry
            
            if (e.open > e.close)
            {
                let color = dataSet.decreasingColor ?? dataSet.colorAt(j)
                
                if (dataSet.isDecreasingFilled)
                {
                    context.setFillColor(color.cgColor)
                    context?.fill(_bodyRect)
                }
                else
                {
                    context.setStrokeColor(color.cgColor)
                    context?.stroke(_bodyRect)
                }
            }
            else if (e.open < e.close)
            {
                let color = dataSet.increasingColor ?? dataSet.colorAt(j)
                
                if (dataSet.isIncreasingFilled)
                {
                    context.setFillColor(color.cgColor)
                    context?.fill(_bodyRect)
                }
                else
                {
                    context.setStrokeColor(color.cgColor)
                    context?.stroke(_bodyRect)
                }
            }
            else
            {
                context?.setStrokeColor(shadowColor.cgColor)
                context?.stroke(_bodyRect)
            }
        }
        
        context?.restoreGState()
    }
    
    open override func drawValues(context: CGContext?)
    {
        let candleData = delegate!.candleStickChartRendererCandleData(self)
        if (candleData === nil)
        {
            return
        }
        
        let defaultValueFormatter = delegate!.candleStickChartDefaultRendererValueFormatter(self)
        
        // if values are drawn
        if ((candleData?.yValCount)! < Int(ceil(CGFloat(delegate!.candleStickChartRendererMaxVisibleValueCount(self)) * viewPortHandler.scaleX)))
        {
            var dataSets = candleData?.dataSets
            
            for (var i = 0; i <  (dataSets?.count)!; i++)
            {
                let dataSet = dataSets?[i]
                
                if !(dataSet?.isDrawValuesEnabled)! || dataSet?.entryCount == 0
                {
                    continue
                }
                
                let valueFont = dataSet?.valueFont
                let valueTextColor = dataSet?.valueTextColor
                
                var formatter = dataSet.valueFormatter
                if (formatter === nil)
                {
                    formatter = defaultValueFormatter
                }
                
                let trans = delegate!.candleStickChartRenderer(self, transformerForAxis: (dataSet?.axisDependency)!)
                
                var entries = dataSet?.yVals as! [CandleChartDataEntry]
                
                let minx = max(_minX, 0)
                let maxx = min(_maxX + 1, entries.count)
                
                var positions = trans.generateTransformedValuesCandle(entries, phaseY: _animator.phaseY)
                
                let lineHeight = valueFont?.lineHeight
                let yOffset: CGFloat = lineHeight + 5.0
                
                for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * _animator.phaseX + CGFloat(minx))); j < count; j += 1)
                {
                    let x = positions[j].x
                    let y = positions[j].y
                    
                    if (!viewPortHandler.isInBoundsRight(x))
                    {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(x) || !viewPortHandler.isInBoundsY(y))
                    {
                        continue
                    }
                    
                    let val = entries[j].high
                    
                    ChartUtils.drawText(context: context, text: formatter!.string(from: val)!, point: CGPoint(x: x, y: y - yOffset), align: .center, attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: valueTextColor])
                }
            }
        }
    }
    
    open override func drawExtras(context: CGContext?)
    {
    }
    
    fileprivate var _highlightPtsBuffer = [CGPoint](repeating: CGPoint(), count: 4)
    open override func drawHighlighted(context: CGContext?, indices: [ChartHighlight])
    {
        let candleData = delegate!.candleStickChartRendererCandleData(self)
        if (candleData === nil)
        {
            return
        }
        
        for (i in 0 ..< indices.count)
        {
            let xIndex = indices[i].xIndex; // get the x-position
            
            let set = candleData?.getDataSetByIndex(indices[i].dataSetIndex) as! CandleChartDataSet!
            
            if (set === nil || !set.isHighlightEnabled)
            {
                continue
            }
            
            let e = set.entryForXIndex(xIndex) as! CandleChartDataEntry!
            
            if (e === nil || e.xIndex != xIndex)
            {
                continue
            }
            
            let trans = delegate!.candleStickChartRenderer(self, transformerForAxis: set.axisDependency)
            
            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            if (set.highlightLineDashLengths != nil)
            {
                CGContextSetLineDash(context, set.highlightLineDashPhase, set.highlightLineDashLengths!, set.highlightLineDashLengths!.count)
            }
            else
            {
                CGContextSetLineDash(context, 0.0, nil, 0)
            }
            
            let low = CGFloat(e.low) * _animator.phaseY
            let high = CGFloat(e.high) * _animator.phaseY
            let y = (low + high) / 2.0
            
            _highlightPtsBuffer[0] = CGPoint(x: CGFloat(xIndex), y: CGFloat(delegate!.candleStickChartRendererChartYMax(self)))
            _highlightPtsBuffer[1] = CGPoint(x: CGFloat(xIndex), y: CGFloat(delegate!.candleStickChartRendererChartYMin(self)))
            _highlightPtsBuffer[2] = CGPoint(x: CGFloat(delegate!.candleStickChartRendererChartXMin(self)), y: y)
            _highlightPtsBuffer[3] = CGPoint(x: CGFloat(delegate!.candleStickChartRendererChartXMax(self)), y: y)
            
            trans.pointValuesToPixel(&_highlightPtsBuffer)
            
            // draw the lines
            drawHighlightLines(context: context, points: _highlightPtsBuffer,
                horizontal: set.isHorizontalHighlightIndicatorEnabled, vertical: set.isVerticalHighlightIndicatorEnabled)
        }
    }
}
