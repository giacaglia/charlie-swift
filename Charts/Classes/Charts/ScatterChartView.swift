//
//  ScatterChartView.swift
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

/// The ScatterChart. Draws dots, triangles, squares and custom shapes into the chartview.
open class ScatterChartView: BarLineChartViewBase, ScatterChartRendererDelegate
{
    open override func initialize()
    {
        super.initialize()
        
        renderer = ScatterChartRenderer(delegate: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _chartXMin = -0.5
    }

    open override func calcMinMax()
    {
        super.calcMinMax()

        if (_deltaX == 0.0 && _data.yValCount > 0)
        {
            _deltaX = 1.0
        }
        
        _chartXMax += 0.5
        _deltaX = CGFloat(abs(_chartXMax - _chartXMin))
    }
    
    // MARK: - ScatterChartRendererDelegate
    
    open func scatterChartRendererData(_ renderer: ScatterChartRenderer) -> ScatterChartData!
    {
        return _data as! ScatterChartData!
    }
    
    open func scatterChartRenderer(_ renderer: ScatterChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return getTransformer(which)
    }
    
    open func scatterChartDefaultRendererValueFormatter(_ renderer: ScatterChartRenderer) -> NumberFormatter!
    {
        return self._defaultValueFormatter
    }
    
    open func scatterChartRendererChartYMax(_ renderer: ScatterChartRenderer) -> Double
    {
        return self.chartYMax
    }
    
    open func scatterChartRendererChartYMin(_ renderer: ScatterChartRenderer) -> Double
    {
        return self.chartYMin
    }
    
    open func scatterChartRendererChartXMax(_ renderer: ScatterChartRenderer) -> Double
    {
        return self.chartXMax
    }
    
    open func scatterChartRendererChartXMin(_ renderer: ScatterChartRenderer) -> Double
    {
        return self.chartXMin
    }
    
    open func scatterChartRendererMaxVisibleValueCount(_ renderer: ScatterChartRenderer) -> Int
    {
        return self.maxVisibleValueCount
    }
}
