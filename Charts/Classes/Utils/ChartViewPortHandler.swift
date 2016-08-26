//
//  ChartViewPortHandler.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 27/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

open class ChartViewPortHandler: NSObject
{
    /// matrix used for touch events
    fileprivate var _touchMatrix = CGAffineTransform.identity
    
    /// this rectangle defines the area in which graph values can be drawn
    fileprivate var _contentRect = CGRect()
    
    fileprivate var _chartWidth = CGFloat(0.0)
    fileprivate var _chartHeight = CGFloat(0.0)
    
    /// minimum scale value on the y-axis
    fileprivate var _minScaleY = CGFloat(1.0)
    
    /// minimum scale value on the x-axis
    fileprivate var _minScaleX = CGFloat(1.0)
    
    /// maximum scale value on the x-axis
    fileprivate var _maxScaleX = CGFloat.greatestFiniteMagnitude
    
    /// contains the current scale factor of the x-axis
    fileprivate var _scaleX = CGFloat(1.0)
    
    /// contains the current scale factor of the y-axis
    fileprivate var _scaleY = CGFloat(1.0)
    
    /// offset that allows the chart to be dragged over its bounds on the x-axis
    fileprivate var _transOffsetX = CGFloat(0.0)
    
    /// offset that allows the chart to be dragged over its bounds on the x-axis
    fileprivate var _transOffsetY = CGFloat(0.0)
    
    public override init()
    {
    }
    
    public init(width: CGFloat, height: CGFloat)
    {
        super.init()
        
        setChartDimens(width: width, height: height)
    }
    
    open func setChartDimens(width: CGFloat, height: CGFloat)
    {
        let offsetLeft = self.offsetLeft
        let offsetTop = self.offsetTop
        let offsetRight = self.offsetRight
        let offsetBottom = self.offsetBottom
        
        _chartHeight = height
        _chartWidth = width
        
        restrainViewPort(offsetLeft: offsetLeft, offsetTop: offsetTop, offsetRight: offsetRight, offsetBottom: offsetBottom)
    }
    
    open var hasChartDimens: Bool
    {
        if (_chartHeight > 0.0 && _chartWidth > 0.0)
        {
            return true
        }
        else
        {
            return false
        }
    }

    open func restrainViewPort(offsetLeft: CGFloat, offsetTop: CGFloat, offsetRight: CGFloat, offsetBottom: CGFloat)
    {
        _contentRect.origin.x = offsetLeft
        _contentRect.origin.y = offsetTop
        _contentRect.size.width = _chartWidth - offsetLeft - offsetRight
        _contentRect.size.height = _chartHeight - offsetBottom - offsetTop
    }
    
    open var offsetLeft: CGFloat
    {
        return _contentRect.origin.x
    }
    
    open var offsetRight: CGFloat
    {
        return _chartWidth - _contentRect.size.width - _contentRect.origin.x
    }
    
    open var offsetTop: CGFloat
    {
        return _contentRect.origin.y
    }
    
    open var offsetBottom: CGFloat
    {
        return _chartHeight - _contentRect.size.height - _contentRect.origin.y
    }
    
    open var contentTop: CGFloat
    {
        return _contentRect.origin.y
    }
    
    open var contentLeft: CGFloat
    {
        return _contentRect.origin.x
    }
    
    open var contentRight: CGFloat
    {
        return _contentRect.origin.x + _contentRect.size.width
    }
    
    open var contentBottom: CGFloat
    {
        return _contentRect.origin.y + _contentRect.size.height
    }
    
    open var contentWidth: CGFloat
    {
        return _contentRect.size.width
    }
    
    open var contentHeight: CGFloat
    {
        return _contentRect.size.height
    }
    
    open var contentRect: CGRect { return _contentRect; }
    
    open var contentCenter: CGPoint
    {
        return CGPoint(x: _contentRect.origin.x + _contentRect.size.width / 2.0, y: _contentRect.origin.y + _contentRect.size.height / 2.0)
    }
    
    open var chartHeight: CGFloat { return _chartHeight; }
    
    open var chartWidth: CGFloat { return _chartWidth; }

    // MARK: - Scaling/Panning etc.
    
    /// Zooms around the specified center
    open func zoom(scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        var matrix = _touchMatrix.translatedBy(x: x, y: y)
        matrix = matrix.scaledBy(x: scaleX, y: scaleY)
        matrix = matrix.translatedBy(x: -x, y: -y)
        return matrix
    }
    
    /// Zooms in by 1.4, x and y are the coordinates (in pixels) of the zoom center.
    open func zoomIn(x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        return zoom(scaleX: 1.4, scaleY: 1.4, x: x, y: y)
    }
    
    /// Zooms out by 0.7, x and y are the coordinates (in pixels) of the zoom center.
    open func zoomOut(x: CGFloat, y: CGFloat) -> CGAffineTransform
    {
        return zoom(scaleX: 0.7, scaleY: 0.7, x: x, y: y)
    }
    
    /// Resets all zooming and dragging and makes the chart fit exactly it's bounds.
    open func fitScreen() -> CGAffineTransform
    {
        _minScaleX = 1.0
        _minScaleY = 1.0

        return CGAffineTransform.identity
    }
    
    /// Centers the viewport around the specified position (x-index and y-value) in the chart.
    open func centerViewPort(pt: CGPoint, chart: ChartViewBase)
    {
        let translateX = pt.x - offsetLeft
        let translateY = pt.y - offsetTop
        
        let matrix = _touchMatrix.concatenating(CGAffineTransform(translationX: -translateX, y: -translateY))
        
        refresh(newMatrix: matrix, chart: chart, invalidate: true)
    }
    
    /// call this method to refresh the graph with a given matrix
    open func refresh(newMatrix: CGAffineTransform, chart: ChartViewBase, invalidate: Bool) -> CGAffineTransform
    {
        _touchMatrix = newMatrix
        
        // make sure scale and translation are within their bounds
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
        
        chart.setNeedsDisplay()
        
        return _touchMatrix
    }
    
    /// limits the maximum scale and X translation of the given matrix
    fileprivate func limitTransAndScale(matrix: inout CGAffineTransform, content: CGRect?)
    {
        // min scale-x is 1, max is the max CGFloat
        _scaleX = min(max(_minScaleX, matrix.a), _maxScaleX)
        
        // min scale-y is 1
        _scaleY = max(_minScaleY, matrix.d)
        
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        if (content != nil)
        {
            width = content!.width
            height = content!.height
        }
        
        let maxTransX = -width * (_scaleX - 1.0)
        let newTransX = min(max(matrix.tx, maxTransX - _transOffsetX), _transOffsetX)
        
        let maxTransY = height * (_scaleY - 1.0)
        let newTransY = max(min(matrix.ty, maxTransY + _transOffsetY), -_transOffsetY)
        
        matrix.tx = newTransX
        matrix.a = _scaleX
        matrix.ty = newTransY
        matrix.d = _scaleY
    }
    
    open func setMinimumScaleX(_ xScale: CGFloat)
    {
        var newValue = xScale
        
        if (newValue < 1.0)
        {
            newValue = 1.0
        }
        
        _minScaleX = newValue
        
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
    }
    
    open func setMaximumScaleX(_ xScale: CGFloat)
    {
        _maxScaleX = xScale
        
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
    }
    
    open func setMinMaxScaleX(minScaleX: CGFloat, maxScaleX: CGFloat)
    {
        var newMin = minScaleX
        
        if (newMin < 1.0)
        {
            newMin = 1.0
        }
        
        _minScaleX = newMin
        _maxScaleX = maxScaleX
        
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
    }
    
    open func setMinimumScaleY(_ yScale: CGFloat)
    {
        var newValue = yScale
        
        if (newValue < 1.0)
        {
            newValue = 1.0
        }
        
        _minScaleY = newValue
        
        limitTransAndScale(matrix: &_touchMatrix, content: _contentRect)
    }
    
    open var touchMatrix: CGAffineTransform
    {
        return _touchMatrix
    }
    
    // MARK: - Boundaries Check
    
    open func isInBoundsX(_ x: CGFloat) -> Bool
    {
        if (isInBoundsLeft(x) && isInBoundsRight(x))
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    open func isInBoundsY(_ y: CGFloat) -> Bool
    {
        if (isInBoundsTop(y) && isInBoundsBottom(y))
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    open func isInBounds(x: CGFloat, y: CGFloat) -> Bool
    {
        if (isInBoundsX(x) && isInBoundsY(y))
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    open func isInBoundsLeft(_ x: CGFloat) -> Bool
    {
        return _contentRect.origin.x <= x ? true : false
    }
    
    open func isInBoundsRight(_ x: CGFloat) -> Bool
    {
        let normalizedX = CGFloat(Int(x * 100.0)) / 100.0
        return (_contentRect.origin.x + _contentRect.size.width) >= normalizedX ? true : false
    }
    
    open func isInBoundsTop(_ y: CGFloat) -> Bool
    {
        return _contentRect.origin.y <= y ? true : false
    }
    
    open func isInBoundsBottom(_ y: CGFloat) -> Bool
    {
        let normalizedY = CGFloat(Int(y * 100.0)) / 100.0
        return (_contentRect.origin.y + _contentRect.size.height) >= normalizedY ? true : false
    }
    
    /// - returns: the current x-scale factor
    open var scaleX: CGFloat
    {
        return _scaleX
    }
    
    /// - returns: the current y-scale factor
    open var scaleY: CGFloat
    {
        return _scaleY
    }
    
    /// if the chart is fully zoomed out, return true
    open var isFullyZoomedOut: Bool
    {
        if (isFullyZoomedOutX && isFullyZoomedOutY)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    /// - returns: true if the chart is fully zoomed out on it's y-axis (vertical).
    open var isFullyZoomedOutY: Bool
    {
        if (_scaleY > _minScaleY || _minScaleY > 1.0)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    /// - returns: true if the chart is fully zoomed out on it's x-axis (horizontal).
    open var isFullyZoomedOutX: Bool
    {
        if (_scaleX > _minScaleX || _minScaleX > 1.0)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    /// Set an offset in pixels that allows the user to drag the chart over it's bounds on the x-axis.
    open func setDragOffsetX(_ offset: CGFloat)
    {
        _transOffsetX = offset
    }
    
    /// Set an offset in pixels that allows the user to drag the chart over it's bounds on the y-axis.
    open func setDragOffsetY(_ offset: CGFloat)
    {
        _transOffsetY = offset
    }
    
    /// - returns: true if both drag offsets (x and y) are zero or smaller.
    open var hasNoDragOffset: Bool
    {
        return _transOffsetX <= 0.0 && _transOffsetY <= 0.0 ? true : false
    }
    
    open var canZoomOutMoreX: Bool
    {
        return (_scaleX > _minScaleX)
    }
    
    open var canZoomInMoreX: Bool
    {
        return (_scaleX < _maxScaleX)
    }
}
