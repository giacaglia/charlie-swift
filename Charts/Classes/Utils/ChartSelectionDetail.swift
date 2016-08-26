//
//  ChartSelectionDetail.swift
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

open class ChartSelectionDetail: NSObject
{
    fileprivate var _value = Double(0)
    fileprivate var _dataSetIndex = Int(0)
    fileprivate var _dataSet: ChartDataSet!
    
    public override init()
    {
        super.init()
    }
    
    public init(value: Double, dataSetIndex: Int, dataSet: ChartDataSet)
    {
        super.init()
        
        _value = value
        _dataSetIndex = dataSetIndex
        _dataSet = dataSet
    }
    
    open var value: Double
    {
        return _value
    }
    
    open var dataSetIndex: Int
    {
        return _dataSetIndex
    }
    
    open var dataSet: ChartDataSet?
    {
        return _dataSet
    }
    
    // MARK: NSObject
    
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
        
        if (object!.value != _value)
        {
            return false
        }
        
        if (object!.dataSetIndex != _dataSetIndex)
        {
            return false
        }
        
        if (object!.dataSet !== _dataSet)
        {
            return false
        }
        
        return true
    }
}

public func ==(lhs: ChartSelectionDetail, rhs: ChartSelectionDetail) -> Bool
{
    if (lhs === rhs)
    {
        return true
    }
    
    if (!lhs.isKind(of: type(of: rhs)))
    {
        return false
    }
    
    if (lhs.value != rhs.value)
    {
        return false
    }
    
    if (lhs.dataSetIndex != rhs.dataSetIndex)
    {
        return false
    }
    
    if (lhs.dataSet !== rhs.dataSet)
    {
        return false
    }
    
    return true
}
