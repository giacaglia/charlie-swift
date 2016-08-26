//
//  LineChartView.swift
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

/// Chart that draws lines, surfaces, circles, ...
open class LineChartView: BarLineChartViewBase, LineChartRendererDelegate
{
    fileprivate var _fillFormatter: ChartFillFormatter!
    
    internal override func initialize()
    {
        super.initialize()
        
        renderer = LineChartRenderer(delegate: self, animator: _animator, viewPortHandler: _viewPortHandler)
        
        _fillFormatter = BarLineChartFillFormatter(chart: self)
    }
    
    internal override func calcMinMax()
    {
        super.calcMinMax()
        
        if (_deltaX == 0.0 && _data.yValCount > 0)
        {
            _deltaX = 1.0
        }
    }
    
    open var fillFormatter: ChartFillFormatter!
    {
        get
        {
            return _fillFormatter
        }
        set
        {
            if (newValue === nil)
            {
                _fillFormatter = BarLineChartFillFormatter(chart: self)
            }
            else
            {
                _fillFormatter = newValue
            }
        }
    }
    
    // MARK: - LineChartRendererDelegate
    
    open func lineChartRendererData(_ renderer: LineChartRenderer) -> LineChartData!
    {
        return _data as! LineChartData!
    }
    
    open func lineChartRenderer(_ renderer: LineChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return self.getTransformer(which)
    }
    
    open func lineChartRendererFillFormatter(_ renderer: LineChartRenderer) -> ChartFillFormatter
    {
        return self.fillFormatter
    }
    
    open func lineChartDefaultRendererValueFormatter(_ renderer: LineChartRenderer) -> NumberFormatter!
    {
        return self._defaultValueFormatter
    }
    
    open func lineChartRendererChartYMax(_ renderer: LineChartRenderer) -> Double
    {
        return self.chartYMax
    }
    
    open func lineChartRendererChartYMin(_ renderer: LineChartRenderer) -> Double
    {
        return self.chartYMin
    }
    
    open func lineChartRendererChartXMax(_ renderer: LineChartRenderer) -> Double
    {
        return self.chartXMax
    }
    
    open func lineChartRendererChartXMin(_ renderer: LineChartRenderer) -> Double
    {
        return self.chartXMin
    }
    
    open func lineChartRendererMaxVisibleValueCount(_ renderer: LineChartRenderer) -> Int
    {
        return self.maxVisibleValueCount
    }
}
