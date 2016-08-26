//
//  ChartTransformer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 6/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

/// Transformer class that contains all matrices and is responsible for transforming values into pixels on the screen and backwards.
open class ChartTransformer: NSObject
{
    /// matrix to map the values to the screen pixels
    internal var _matrixValueToPx = CGAffineTransform.identity

    /// matrix for handling the different offsets of the chart
    internal var _matrixOffset = CGAffineTransform.identity

    internal var _viewPortHandler: ChartViewPortHandler

    public init(viewPortHandler: ChartViewPortHandler)
    {
        _viewPortHandler = viewPortHandler
    }

    /// Prepares the matrix that transforms values to pixels. Calculates the scale factors from the charts size and offsets.
    open func prepareMatrixValuePx(chartXMin: Double, deltaX: CGFloat, deltaY: CGFloat, chartYMin: Double)
    {
        let scaleX = (_viewPortHandler.contentWidth / deltaX)
        let scaleY = (_viewPortHandler.contentHeight / deltaY)

        // setup all matrices
        _matrixValueToPx = CGAffineTransform.identity
        _matrixValueToPx = _matrixValueToPx.scaledBy(x: scaleX, y: -scaleY)
        _matrixValueToPx = _matrixValueToPx.translatedBy(x: CGFloat(-chartXMin), y: CGFloat(-chartYMin))
    }

    /// Prepares the matrix that contains all offsets.
    open func prepareMatrixOffset(_ inverted: Bool)
    {
        if (!inverted)
        {
            _matrixOffset = CGAffineTransform(translationX: _viewPortHandler.offsetLeft, y: _viewPortHandler.chartHeight - _viewPortHandler.offsetBottom)
        }
        else
        {
            _matrixOffset = CGAffineTransform(scaleX: 1.0, y: -1.0)
            _matrixOffset = _matrixOffset.translatedBy(x: _viewPortHandler.offsetLeft, y: -_viewPortHandler.offsetTop)
        }
    }
    
    /// Transforms an arraylist of Entry into a double array containing the x and y values transformed with all matrices for the SCATTERCHART.
    open func generateTransformedValuesScatter(_ entries: [ChartDataEntry], phaseY: CGFloat) -> [CGPoint]
    {
        var valuePoints = [CGPoint]()
        valuePoints.reserveCapacity(entries.count)

        for (j in 0 ..< entries.count)
        {
            let e = entries[j]
            valuePoints.append(CGPoint(x: CGFloat(e.xIndex), y: CGFloat(e.value) * phaseY))
        }

        pointValuesToPixel(&valuePoints)

        return valuePoints
    }
    
    /// Transforms an arraylist of Entry into a double array containing the x and y values transformed with all matrices for the BUBBLECHART.
    open func generateTransformedValuesBubble(_ entries: [ChartDataEntry], phaseX: CGFloat, phaseY: CGFloat, from: Int, to: Int) -> [CGPoint]
    {
        let count = to - from
        
        var valuePoints = [CGPoint]()
        valuePoints.reserveCapacity(count)
        
        for (j in 0 ..< count)
        {
            let e = entries[j + from]
            valuePoints.append(CGPoint(x: CGFloat(e.xIndex - from) * phaseX + CGFloat(from), y: CGFloat(e.value) * phaseY))
        }
        
        pointValuesToPixel(&valuePoints)
        
        return valuePoints
    }

    /// Transforms an arraylist of Entry into a double array containing the x and y values transformed with all matrices for the LINECHART.
    open func generateTransformedValuesLine(_ entries: [ChartDataEntry], phaseX: CGFloat, phaseY: CGFloat, from: Int, to: Int) -> [CGPoint]
    {
        let count = Int(ceil(CGFloat(to - from) * phaseX))
        
        var valuePoints = [CGPoint]()
        valuePoints.reserveCapacity(count)

        for (j in 0 ..< count)
        {
            let e = entries[j + from]
            valuePoints.append(CGPoint(x: CGFloat(e.xIndex), y: CGFloat(e.value) * phaseY))
        }

        pointValuesToPixel(&valuePoints)

        return valuePoints
    }
    
    /// Transforms an arraylist of Entry into a double array containing the x and y values transformed with all matrices for the CANDLESTICKCHART.
    open func generateTransformedValuesCandle(_ entries: [CandleChartDataEntry], phaseY: CGFloat) -> [CGPoint]
    {
        var valuePoints = [CGPoint]()
        valuePoints.reserveCapacity(entries.count)
        
        for (j in 0 ..< entries.count)
        {
            let e = entries[j]
            valuePoints.append(CGPoint(x: CGFloat(e.xIndex), y: CGFloat(e.high) * phaseY))
        }
        
        pointValuesToPixel(&valuePoints)
        
        return valuePoints
    }
    
    /// Transforms an arraylist of Entry into a double array containing the x and y values transformed with all matrices for the BARCHART.
    open func generateTransformedValuesBarChart(_ entries: [BarChartDataEntry], dataSet: Int, barData: BarChartData, phaseY: CGFloat) -> [CGPoint]
    {
        var valuePoints = [CGPoint]()
        valuePoints.reserveCapacity(entries.count)

        let setCount = barData.dataSetCount
        let space = barData.groupSpace

        for (j in 0 ..< entries.count)
        {
            let e = entries[j]

            // calculate the x-position, depending on datasetcount
            let x = CGFloat(e.xIndex + (e.xIndex * (setCount - 1)) + dataSet) + space * CGFloat(e.xIndex) + space / 2.0
            let y = e.value
            
            valuePoints.append(CGPoint(x: x, y: CGFloat(y) * phaseY))
        }

        pointValuesToPixel(&valuePoints)

        return valuePoints
    }
    
    /// Transforms an arraylist of Entry into a double array containing the x and y values transformed with all matrices for the BARCHART.
    open func generateTransformedValuesHorizontalBarChart(_ entries: [ChartDataEntry], dataSet: Int, barData: BarChartData, phaseY: CGFloat) -> [CGPoint]
    {
        var valuePoints = [CGPoint]()
        valuePoints.reserveCapacity(entries.count)
        
        let setCount = barData.dataSetCount
        let space = barData.groupSpace
        
        for (j in 0 ..< entries.count)
        {
            let e = entries[j]

            // calculate the x-position, depending on datasetcount
            let x = CGFloat(e.xIndex + (e.xIndex * (setCount - 1)) + dataSet) + space * CGFloat(e.xIndex) + space / 2.0
            let y = e.value
            
            valuePoints.append(CGPoint(x: CGFloat(y) * phaseY, y: x))
        }

        pointValuesToPixel(&valuePoints)

        return valuePoints
    }

    /// Transform an array of points with all matrices.
    // VERY IMPORTANT: Keep matrix order "value-touch-offset" when transforming.
    open func pointValuesToPixel(_ pts: inout [CGPoint])
    {
        let trans = valueToPixelMatrix
        for (var i = 0, count = pts.count; i < count; i += 1)
        {
            pts[i] = pts[i].applying(trans)
        }
    }
    
    open func pointValueToPixel(_ point: inout CGPoint)
    {
        point = point.applying(valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices.
    open func rectValueToPixel(_ r: inout CGRect)
    {
        r = r.applying(valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices with potential animation phases.
    open func rectValueToPixel(_ r: inout CGRect, phaseY: CGFloat)
    {
        // multiply the height of the rect with the phase
        if (r.origin.y > 0.0)
        {
            r.origin.y *= phaseY
        }
        else
        {
            var bottom = r.origin.y + r.size.height
            bottom *= phaseY
            r.size.height = bottom - r.origin.y
        }

        r = r.applying(valueToPixelMatrix)
    }
    
    /// Transform a rectangle with all matrices with potential animation phases.
    open func rectValueToPixelHorizontal(_ r: inout CGRect, phaseY: CGFloat)
    {
        // multiply the height of the rect with the phase
        if (r.origin.x > 0.0)
        {
            r.origin.x *= phaseY
        }
        else
        {
            var right = r.origin.x + r.size.width
            right *= phaseY
            r.size.width = right - r.origin.x
        }
        
        r = r.applying(valueToPixelMatrix)
    }

    /// transforms multiple rects with all matrices
    open func rectValuesToPixel(_ rects: inout [CGRect])
    {
        let trans = valueToPixelMatrix
        
        for (i in 0 ..< rects.count)
        {
            rects[i] = rects[i].applying(trans)
        }
    }
    
    /// Transforms the given array of touch points (pixels) into values on the chart.
    open func pixelsToValue(_ pixels: inout [CGPoint])
    {
        let trans = pixelToValueMatrix
        
        for (i in 0 ..< pixels.count)
        {
            pixels[i] = pixels[i].applying(trans)
        }
    }
    
    /// Transforms the given touch point (pixels) into a value on the chart.
    open func pixelToValue(_ pixel: inout CGPoint)
    {
        pixel = pixel.applying(pixel ToValueMatrix)
    }
    
    /// - returns: the x and y values in the chart at the given touch point
    /// (encapsulated in a PointD). This method transforms pixel coordinates to
    /// coordinates / values in the chart.
    open func getValueByTouchPoint(_ point: CGPoint) -> CGPoint
    {
        return point.applying(pixelToValueMatrix)
    }
    
    open var valueToPixelMatrix: CGAffineTransform
    {
        return
            _matrixValueToPx.concatenating(_viewPortHandler.touchMatrix
                ).concatenating(_matrixOffset
        )
    }
    
    open var pixelToValueMatrix: CGAffineTransform
    {
        return valueToPixelMatrix.inverted()
    }
}
