//
//  CombinedChartData.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation

open class CombinedChartData: BarLineScatterCandleChartData
{
    fileprivate var _lineData: LineChartData!
    fileprivate var _barData: BarChartData!
    fileprivate var _scatterData: ScatterChartData!
    fileprivate var _candleData: CandleChartData!
    fileprivate var _bubbleData: BubbleChartData!
    
    public override init()
    {
        super.init()
    }
    
    public override init(xVals: [String?]?, dataSets: [ChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }
    
    public override init(xVals: [NSObject]?, dataSets: [ChartDataSet]?)
    {
        super.init(xVals: xVals, dataSets: dataSets)
    }
    
    open var lineData: LineChartData!
    {
        get
        {
            return _lineData
        }
        set
        {
            _lineData = newValue
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet)
            }
            
            checkIsLegal(newValue.dataSets)
            
            calcMinMax(start: _lastStart, end: _lastEnd)
            calcYValueSum()
            calcYValueCount()
            
            calcXValAverageLength()
        }
    }
    
    open var barData: BarChartData!
    {
        get
        {
            return _barData
        }
        set
        {
            _barData = newValue
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet)
            }
            
            checkIsLegal(newValue.dataSets)
            
            calcMinMax(start: _lastStart, end: _lastEnd)
            calcYValueSum()
            calcYValueCount()
            
            calcXValAverageLength()
        }
    }
    
    open var scatterData: ScatterChartData!
    {
        get
        {
            return _scatterData
        }
        set
        {
            _scatterData = newValue
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet)
            }
            
            checkIsLegal(newValue.dataSets)
            
            calcMinMax(start: _lastStart, end: _lastEnd)
            calcYValueSum()
            calcYValueCount()
        
            calcXValAverageLength()
        }
    }
    
    open var candleData: CandleChartData!
    {
        get
        {
            return _candleData
        }
        set
        {
            _candleData = newValue
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet)
            }
            
            checkIsLegal(newValue.dataSets)
            
            calcMinMax(start: _lastStart, end: _lastEnd)
            calcYValueSum()
            calcYValueCount()
            
            calcXValAverageLength()
        }
    }
    
    open var bubbleData: BubbleChartData!
    {
        get
        {
            return _bubbleData
        }
        set
        {
            _bubbleData = newValue
            for dataSet in newValue.dataSets
            {
                _dataSets.append(dataSet)
            }
            
            checkIsLegal(newValue.dataSets)
            
            calcMinMax(start: _lastStart, end: _lastEnd)
            calcYValueSum()
            calcYValueCount()
            
            calcXValAverageLength()
        }
    }
    
    open override func notifyDataChanged()
    {
        if (_lineData !== nil)
        {
            _lineData.notifyDataChanged()
        }
        if (_barData !== nil)
        {
            _barData.notifyDataChanged()
        }
        if (_scatterData !== nil)
        {
            _scatterData.notifyDataChanged()
        }
        if (_candleData !== nil)
        {
            _candleData.notifyDataChanged()
        }
        if (_bubbleData !== nil)
        {
            _bubbleData.notifyDataChanged()
        }
    }
}
