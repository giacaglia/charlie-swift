//
//  ChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class ChartDataSet: NSObject
{
    open var colors = [UIColor]()
    internal var _yVals: [ChartDataEntry]!
    internal var _yMax = Double(0.0)
    internal var _yMin = Double(0.0)
    internal var _yValueSum = Double(0.0)
    
    /// the last start value used for calcMinMax
    internal var _lastStart: Int = 0
    
    /// the last end value used for calcMinMax
    internal var _lastEnd: Int = 0
    
    open var label: String? = "DataSet"
    open var visible = true
    open var drawValuesEnabled = true
    
    /// the color used for the value-text
    open var valueTextColor: UIColor = UIColor.black
    
    /// the font for the value-text labels
    open var valueFont: UIFont = UIFont.systemFont(ofSize: 7.0)
    
    /// the formatter used to customly format the values
    open var valueFormatter: NumberFormatter?
    
    /// the axis this DataSet should be plotted against.
    open var axisDependency = ChartYAxis.AxisDependency.left

    open var yVals: [ChartDataEntry] { return _yVals }
    open var yValueSum: Double { return _yValueSum }
    open var yMin: Double { return _yMin }
    open var yMax: Double { return _yMax }
    
    /// if true, value highlighting is enabled
    open var highlightEnabled = true
    
    /// - returns: true if value highlighting is enabled for this dataset
    open var isHighlightEnabled: Bool { return highlightEnabled }
    
    public override init()
    {
        super.init()
    }
    
    public init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init()
        
        self.label = label
        _yVals = yVals == nil ? [ChartDataEntry]() : yVals
        
        // default color
        colors.append(UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        
        self.calcMinMax(start: _lastStart, end: _lastEnd)
        self.calcYValueSum()
    }
    
    public convenience init(yVals: [ChartDataEntry]?)
    {
        self.init(yVals: yVals, label: "DataSet")
    }
    
    /// Use this method to tell the data set that the underlying data has changed
    open func notifyDataSetChanged()
    {
        calcMinMax(start: _lastStart, end: _lastEnd)
        calcYValueSum()
    }
    
    internal func calcMinMax(start : Int, end: Int)
    {
        let yValCount = _yVals.count
        
        if yValCount == 0
        {
            return
        }
        
        var endValue : Int
        
        if end == 0 || end >= yValCount
        {
            endValue = yValCount - 1
        }
        else
        {
            endValue = end
        }
        
        _lastStart = start
        _lastEnd = endValue
        
        _yMin = DBL_MAX
        _yMax = -DBL_MAX
        
        for (var i = start; i <= endValue; i += 1)
        {
            let e = _yVals[i]
            
            if (!e.value.isNaN)
            {
                if (e.value < _yMin)
                {
                    _yMin = e.value
                }
                if (e.value > _yMax)
                {
                    _yMax = e.value
                }
            }
        }
        
        if (_yMin == DBL_MAX)
        {
            _yMin = 0.0
            _yMax = 0.0
        }
    }
    
    fileprivate func calcYValueSum()
    {
        _yValueSum = 0
        
        for i in 0 ..< _yVals.count
        {
            _yValueSum += fabs(_yVals[i].value)
        }
    }
    
    open var entryCount: Int { return _yVals!.count; }
    
    open func yValForXIndex(_ x: Int) -> Double
    {
        let e = self.entryForXIndex(x)
        
        if (e !== nil && e!.xIndex == x) { return e!.value }
        else { return Double.nan }
    }
    
    /// - returns: the first Entry object found at the given xIndex with binary search.
    /// If the no Entry at the specifed x-index is found, this method returns the Entry at the closest x-index. 
    /// nil if no Entry object at that index.
    open func entryForXIndex(_ x: Int) -> ChartDataEntry?
    {
        let index = self.entryIndex(xIndex: x)
        if (index > -1)
        {
            return _yVals[index]
        }
        return nil
    }
    
    open func entriesForXIndex(_ x: Int) -> [ChartDataEntry]
    {
        var entries = [ChartDataEntry]()
        
        var low = 0
        var high = _yVals.count - 1
        
        while (low <= high)
        {
            var m = Int((high + low) / 2)
            var entry = _yVals[m]
            
            if (x == entry.xIndex)
            {
                while (m > 0 && _yVals[m - 1].xIndex == x)
                {
                    m -= 1
                }
                
                high = _yVals.count
                for (; m < high; m += 1)
                {
                    entry = _yVals[m]
                    if (entry.xIndex == x)
                    {
                        entries.append(entry)
                    }
                    else
                    {
                        break
                    }
                }
            }
            
            if (x > _yVals[m].xIndex)
            {
                low = m + 1
            }
            else
            {
                high = m - 1
            }
        }
        
        return entries
    }
    
    open func entryIndex(xIndex x: Int) -> Int
    {
        var low = 0
        var high = _yVals.count - 1
        var closest = -1
        
        while (low <= high)
        {
            var m = (high + low) / 2
            let entry = _yVals[m]
            
            if (x == entry.xIndex)
            {
                while (m > 0 && _yVals[m - 1].xIndex == x)
                {
                    m -= 1
                }
                
                return m
            }
            
            if (x > entry.xIndex)
            {
                low = m + 1
            }
            else
            {
                high = m - 1
            }
            
            closest = m
        }
        
        return closest
    }
    
    open func entryIndex(entry e: ChartDataEntry, isEqual: Bool) -> Int
    {
        if (isEqual)
        {
            for (i in 0 ..< _yVals.count)
            {
                if (_yVals[i].isEqual(e))
                {
                    return i
                }
            }
        }
        else
        {
            for (i in 0 ..< _yVals.count)
            {
                if (_yVals[i] === e)
                {
                    return i
                }
            }
        }
        
        return -1
    }
    
    /// - returns: the number of entries this DataSet holds.
    open var valueCount: Int { return _yVals.count; }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to the end of the list.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    open func addEntry(_ e: ChartDataEntry)
    {
        let val = e.value
        
        if (_yVals == nil)
        {
            _yVals = [ChartDataEntry]()
        }
        
        if (_yVals.count == 0)
        {
            _yMax = val
            _yMin = val
        }
        else
        {
            if (_yMax < val)
            {
                _yMax = val
            }
            if (_yMin > val)
            {
                _yMin = val
            }
        }
        
        _yValueSum += val
        
        _yVals.append(e)
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to their appropriate index respective to it's x-index.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    open func addEntryOrdered(_ e: ChartDataEntry)
    {
        let val = e.value
        
        if (_yVals == nil)
        {
            _yVals = [ChartDataEntry]()
        }
        
        if (_yVals.count == 0)
        {
            _yMax = val
            _yMin = val
        }
        else
        {
            if (_yMax < val)
            {
                _yMax = val
            }
            if (_yMin > val)
            {
                _yMin = val
            }
        }
        
        _yValueSum += val
        
        if _yVals.last?.xIndex > e.xIndex
        {
            var closestIndex = entryIndex(xIndex: e.xIndex)
            if _yVals[closestIndex].xIndex < e.xIndex
            {
                closestIndex += 1
            }
            _yVals.insert(e, at: closestIndex)
            return;
        }
        
        _yVals.append(e)
    }
    
    open func removeEntry(_ entry: ChartDataEntry) -> Bool
    {
        var removed = false
        
        for (i in 0 ..< _yVals.count)
        {
            if (_yVals[i] === entry)
            {
                _yVals.remove(at: i)
                removed = true
                break
            }
        }
        
        if (removed)
        {
            _yValueSum -= entry.value
            calcMinMax(start: _lastStart, end: _lastEnd)
        }
        
        return removed
    }
    
    open func removeEntry(xIndex: Int) -> Bool
    {
        let index = self.entryIndex(xIndex: xIndex)
        if (index > -1)
        {
            let e = _yVals.remove(at: index)
            
            _yValueSum -= e.value
            calcMinMax(start: _lastStart, end: _lastEnd)
            
            return true
        }
        
        return false
    }
    
    open func resetColors()
    {
        colors.removeAll(keepingCapacity: false)
    }
    
    open func addColor(_ color: UIColor)
    {
        colors.append(color)
    }
    
    open func setColor(_ color: UIColor)
    {
        colors.removeAll(keepingCapacity: false)
        colors.append(color)
    }
    
    public func colorAt(_ index: Int) -> UIColor
    {
        var index = index
        if (index < 0)
        {
            index = 0
        }
        return colors[index % colors.count]
    }
    
    open var isVisible: Bool
    {
        return visible
    }
    
    open var isDrawValuesEnabled: Bool
    {
        return drawValuesEnabled
    }
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: true if contains the entry, false if not.
    open func contains(_ e: ChartDataEntry) -> Bool
    {
        for entry in _yVals
        {
            if (entry.isEqual(e))
            {
                return true
            }
        }
        
        return false
    }
    
    /// Removes all values from this DataSet and recalculates min and max value.
    open func clear()
    {
        _yVals.removeAll(keepingCapacity: true)
        _lastStart = 0
        _lastEnd = 0
        notifyDataSetChanged()
    }

    // MARK: NSObject
    
    open override var description: String
    {
        return String(format: "ChartDataSet, label: %@, %i entries", arguments: [self.label ?? "", _yVals.count])
    }
    
    open override var debugDescription: String
    {
        var desc = description + ":"
        
        for (i in 0 ..< _yVals.count)
        {
            desc += "\n" + _yVals[i].description
        }
        
        return desc
    }
    
    // MARK: NSCopying
    
    open func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = ChartDataSet()
        copy.colors = colors
        copy._yVals = _yVals
        copy._yMax = _yMax
        copy._yMin = _yMin
        copy._yValueSum = _yValueSum
        copy._lastStart = _lastStart
        copy._lastEnd = _lastEnd
        copy.label = label
        return copy
    }
}


