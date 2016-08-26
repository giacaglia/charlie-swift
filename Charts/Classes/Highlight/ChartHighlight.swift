//
//  ChartHighlight.swift
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

open class ChartHighlight: NSObject
{
    /// the x-index of the highlighted value
    fileprivate var _xIndex = Int(0)
    
    /// the index of the dataset the highlighted value is in
    fileprivate var _dataSetIndex = Int(0)
    
    /// index which value of a stacked bar entry is highlighted
    /// 
    /// **default**: -1
    fileprivate var _stackIndex = Int(-1)
    
    /// the range of the bar that is selected (only for stacked-barchart)
    fileprivate var _range: ChartRange?

    public override init()
    {
        super.init()
    }
    
    public init(xIndex x: Int, dataSetIndex: Int)
    {
        super.init()
        
        _xIndex = x
        _dataSetIndex = dataSetIndex
    }
    
    public init(xIndex x: Int, dataSetIndex: Int, stackIndex: Int)
    {
        super.init()
        
        _xIndex = x
        _dataSetIndex = dataSetIndex
        _stackIndex = stackIndex
    }
    
    /// Constructor, only used for stacked-barchart.
    ///
    /// - parameter x: the index of the highlighted value on the x-axis
    /// - parameter dataSet: the index of the DataSet the highlighted value belongs to
    /// - parameter stackIndex: references which value of a stacked-bar entry has been selected
    /// - parameter range: the range the selected stack-value is in
    public convenience init(xIndex x: Int, dataSetIndex: Int, stackIndex: Int, range: ChartRange)
    {
        self.init(xIndex: x, dataSetIndex: dataSetIndex, stackIndex: stackIndex)
        
        _range = range
    }

    open var dataSetIndex: Int { return _dataSetIndex; }
    open var xIndex: Int { return _xIndex; }
    open var stackIndex: Int { return _stackIndex; }
    
    /// - returns: the range of values the selected value of a stacked bar is in. (this is only relevant for stacked-barchart)
    open var range: ChartRange? { return _range }

    // MARK: NSObject
    
    open override var description: String
    {
        return "Highlight, xIndex: \(_xIndex), dataSetIndex: \(_dataSetIndex), stackIndex (only stacked barentry): \(_stackIndex)"
    }
    
    open override func isEqual(_ object: Any?) -> Bool
    {
        if (object == nil)
        {
            return false
        }
        
        if (!object!.isKind(of: type(of: self)))
        {
            return false
        }
        
        if (object!.xIndex != _xIndex)
        {
            return false
        }
        
        if (object!.dataSetIndex != _dataSetIndex)
        {
            return false
        }
        
        if (object!.stackIndex != _stackIndex)
        {
            return false
        }
        
        return true
    }
}

func ==(lhs: ChartHighlight, rhs: ChartHighlight) -> Bool
{
    if (lhs === rhs)
    {
        return true
    }
    
    if (!lhs.isKind(of: type(of: rhs)))
    {
        return false
    }
    
    if (lhs._xIndex != rhs._xIndex)
    {
        return false
    }
    
    if (lhs._dataSetIndex != rhs._dataSetIndex)
    {
        return false
    }
    
    if (lhs._stackIndex != rhs._stackIndex)
    {
        return false
    }
    
    return true
}
