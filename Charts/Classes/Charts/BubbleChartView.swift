//
//  BubbleChartView.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

open class BubbleChartView: BarLineChartViewBase, BubbleChartRendererDelegate
{
    open override func initialize()
    {
        super.initialize()
        
        renderer = BubbleChartRenderer(delegate: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    open override func calcMinMax()
    {
        super.calcMinMax()
        
        if (_deltaX == 0.0 && _data.yValCount > 0)
        {
            _deltaX = 1.0
        }
        
        _chartXMin = -0.5
        _chartXMax = Double(_data.xVals.count) - 0.5
        
        if renderer as? BubbleChartRenderer !== nil,
            let sets = _data.dataSets as? [BubbleChartDataSet]
        {
            for set in sets {
                
                let xmin = set.xMin
                let xmax = set.xMax
                
                if (xmin < _chartXMin)
                {
                    _chartXMin = xmin
                }
                
                if (xmax > _chartXMax)
                {
                    _chartXMax = xmax
                }
            }
        }
        
        _deltaX = CGFloat(abs(_chartXMax - _chartXMin))
    }

    // MARK: - BubbleChartRendererDelegate
    
    open func bubbleChartRendererData(_ renderer: BubbleChartRenderer) -> BubbleChartData!
    {
        return _data as! BubbleChartData!
    }
    
    open func bubbleChartRenderer(_ renderer: BubbleChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return getTransformer(which)
    }
    
    open func bubbleChartDefaultRendererValueFormatter(_ renderer: BubbleChartRenderer) -> NumberFormatter!
    {
        return self._defaultValueFormatter
    }
    
    open func bubbleChartRendererChartYMax(_ renderer: BubbleChartRenderer) -> Double
    {
        return self.chartYMax
    }
    
    open func bubbleChartRendererChartYMin(_ renderer: BubbleChartRenderer) -> Double
    {
        return self.chartYMin
    }
    
    open func bubbleChartRendererChartXMax(_ renderer: BubbleChartRenderer) -> Double
    {
        return self.chartXMax
    }
    
    open func bubbleChartRendererChartXMin(_ renderer: BubbleChartRenderer) -> Double
    {
        return self.chartXMin
    }
    
    open func bubbleChartRendererMaxVisibleValueCount(_ renderer: BubbleChartRenderer) -> Int
    {
        return self.maxVisibleValueCount
    }
    
    open func bubbleChartRendererXValCount(_ renderer: BubbleChartRenderer) -> Int
    {
        return _data.xValCount
    }
}
