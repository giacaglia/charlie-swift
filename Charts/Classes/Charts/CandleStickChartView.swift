//
//  CandleStickChartView.swift
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

/// Financial chart type that draws candle-sticks.
open class CandleStickChartView: BarLineChartViewBase, CandleStickChartRendererDelegate
{
    internal override func initialize()
    {
        super.initialize()
        
        renderer = CandleStickChartRenderer(delegate: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _chartXMin = -0.5
    }

    internal override func calcMinMax()
    {
        super.calcMinMax()

        _chartXMax += 0.5
        _deltaX = CGFloat(abs(_chartXMax - _chartXMin))
    }
    
    // MARK: - CandleStickChartRendererDelegate
    
    open func candleStickChartRendererCandleData(_ renderer: CandleStickChartRenderer) -> CandleChartData!
    {
        return _data as! CandleChartData!
    }
    
    open func candleStickChartRenderer(_ renderer: CandleStickChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return self.getTransformer(which)
    }
    
    open func candleStickChartDefaultRendererValueFormatter(_ renderer: CandleStickChartRenderer) -> NumberFormatter!
    {
        return self.valueFormatter
    }
    
    open func candleStickChartRendererChartYMax(_ renderer: CandleStickChartRenderer) -> Double
    {
        return self.chartYMax
    }
    
    open func candleStickChartRendererChartYMin(_ renderer: CandleStickChartRenderer) -> Double
    {
        return self.chartYMin
    }
    
    open func candleStickChartRendererChartXMax(_ renderer: CandleStickChartRenderer) -> Double
    {
        return self.chartXMax
    }
    
    open func candleStickChartRendererChartXMin(_ renderer: CandleStickChartRenderer) -> Double
    {
        return self.chartXMin
    }
    
    open func candleStickChartRendererMaxVisibleValueCount(_ renderer: CandleStickChartRenderer) -> Int
    {
        return self.maxVisibleValueCount
    }
}
