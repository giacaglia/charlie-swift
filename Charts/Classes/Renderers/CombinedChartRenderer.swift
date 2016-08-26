//
//  CombinedChartRenderer.swift
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

open class CombinedChartRenderer: ChartDataRendererBase,
    LineChartRendererDelegate,
    BarChartRendererDelegate,
    ScatterChartRendererDelegate,
    CandleStickChartRendererDelegate,
    BubbleChartRendererDelegate
{
    fileprivate weak var _chart: CombinedChartView!
    
    /// flag that enables or disables the highlighting arrow
    open var drawHighlightArrowEnabled = false
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    open var drawValueAboveBarEnabled = true
    
    /// if set to true, a grey area is darawn behind each bar that indicates the maximum value
    open var drawBarShadowEnabled = true
    
    internal var _renderers = [ChartDataRendererBase]()
    
    internal var _drawOrder: [CombinedChartView.CombinedChartDrawOrder] = [.bar, .bubble, .line, .candle, .scatter]
    
    public init(chart: CombinedChartView, animator: ChartAnimator, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        _chart = chart
        
        createRenderers()
    }
    
    /// Creates the renderers needed for this combined-renderer in the required order. Also takes the DrawOrder into consideration.
    internal func createRenderers()
    {
        _renderers = [ChartDataRendererBase]()

        for order in drawOrder
        {
            switch (order)
            {
            case .bar:
                if (_chart.barData !== nil)
                {
                    _renderers.append(BarChartRenderer(delegate: self, animator: _animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .line:
                if (_chart.lineData !== nil)
                {
                    _renderers.append(LineChartRenderer(delegate: self, animator: _animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .candle:
                if (_chart.candleData !== nil)
                {
                    _renderers.append(CandleStickChartRenderer(delegate: self, animator: _animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .scatter:
                if (_chart.scatterData !== nil)
                {
                    _renderers.append(ScatterChartRenderer(delegate: self, animator: _animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .bubble:
                if (_chart.bubbleData !== nil)
                {
                    _renderers.append(BubbleChartRenderer(delegate: self, animator: _animator, viewPortHandler: viewPortHandler))
                }
                break
            }
        }

    }
    
    open override func drawData(context: CGContext?)
    {
        for renderer in _renderers
        {
            renderer.drawData(context: context)
        }
    }
    
    open override func drawValues(context: CGContext?)
    {
        for renderer in _renderers
        {
            renderer.drawValues(context: context)
        }
    }
    
    open override func drawExtras(context: CGContext?)
    {
        for renderer in _renderers
        {
            renderer.drawExtras(context: context)
        }
    }
    
    open override func drawHighlighted(context: CGContext?, indices: [ChartHighlight])
    {
        for renderer in _renderers
        {
            renderer.drawHighlighted(context: context, indices: indices)
        }
    }
    
    open override func calcXBounds(chart: BarLineChartViewBase, xAxisModulus: Int)
    {
        for renderer in _renderers
        {
            renderer.calcXBounds(chart: chart, xAxisModulus: xAxisModulus)
        }
    }

    /// - returns: the sub-renderer object at the specified index.
    open func getSubRenderer(index: Int) -> ChartDataRendererBase?
    {
        if (index >= _renderers.count || index < 0)
        {
            return nil
        }
        else
        {
            return _renderers[index]
        }
    }

    /// Returns all sub-renderers.
    open var subRenderers: [ChartDataRendererBase]
    {
        get { return _renderers }
        set { _renderers = newValue }
    }

    // MARK: - LineChartRendererDelegate
    
    open func lineChartRendererData(_ renderer: LineChartRenderer) -> LineChartData!
    {
        return _chart.lineData
    }
    
    open func lineChartRenderer(_ renderer: LineChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return _chart.getTransformer(which)
    }
    
    open func lineChartRendererFillFormatter(_ renderer: LineChartRenderer) -> ChartFillFormatter
    {
        return _chart.fillFormatter
    }
    
    open func lineChartDefaultRendererValueFormatter(_ renderer: LineChartRenderer) -> NumberFormatter!
    {
        return _chart._defaultValueFormatter
    }
    
    open func lineChartRendererChartYMax(_ renderer: LineChartRenderer) -> Double
    {
        return _chart.chartYMax
    }
    
    open func lineChartRendererChartYMin(_ renderer: LineChartRenderer) -> Double
    {
        return _chart.chartYMin
    }
    
    open func lineChartRendererChartXMax(_ renderer: LineChartRenderer) -> Double
    {
        return _chart.chartXMax
    }
    
    open func lineChartRendererChartXMin(_ renderer: LineChartRenderer) -> Double
    {
        return _chart.chartXMin
    }
    
    open func lineChartRendererMaxVisibleValueCount(_ renderer: LineChartRenderer) -> Int
    {
        return _chart.maxVisibleValueCount
    }
    
    // MARK: - BarChartRendererDelegate
    
    open func barChartRendererData(_ renderer: BarChartRenderer) -> BarChartData!
    {
        return _chart.barData
    }
    
    open func barChartRenderer(_ renderer: BarChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return _chart.getTransformer(which)
    }
    
    open func barChartRendererMaxVisibleValueCount(_ renderer: BarChartRenderer) -> Int
    {
        return _chart.maxVisibleValueCount
    }
    
    open func barChartDefaultRendererValueFormatter(_ renderer: BarChartRenderer) -> NumberFormatter!
    {
        return _chart._defaultValueFormatter
    }
    
    open func barChartRendererChartYMax(_ renderer: BarChartRenderer) -> Double
    {
        return _chart.chartYMax
    }
    
    open func barChartRendererChartYMin(_ renderer: BarChartRenderer) -> Double
    {
        return _chart.chartYMin
    }
    
    open func barChartRendererChartXMax(_ renderer: BarChartRenderer) -> Double
    {
        return _chart.chartXMax
    }
    
    open func barChartRendererChartXMin(_ renderer: BarChartRenderer) -> Double
    {
        return _chart.chartXMin
    }
    
    open func barChartIsDrawHighlightArrowEnabled(_ renderer: BarChartRenderer) -> Bool
    {
        return drawHighlightArrowEnabled
    }
    
    open func barChartIsDrawValueAboveBarEnabled(_ renderer: BarChartRenderer) -> Bool
    {
        return drawValueAboveBarEnabled
    }
    
    open func barChartIsDrawBarShadowEnabled(_ renderer: BarChartRenderer) -> Bool
    {
        return drawBarShadowEnabled
    }
    
    open func barChartIsInverted(_ renderer: BarChartRenderer, axis: ChartYAxis.AxisDependency) -> Bool
    {
        return _chart.getAxis(axis).isInverted
    }
    
    // MARK: - ScatterChartRendererDelegate
    
    open func scatterChartRendererData(_ renderer: ScatterChartRenderer) -> ScatterChartData!
    {
        return _chart.scatterData
    }
    
    open func scatterChartRenderer(_ renderer: ScatterChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return _chart.getTransformer(which)
    }
    
    open func scatterChartDefaultRendererValueFormatter(_ renderer: ScatterChartRenderer) -> NumberFormatter!
    {
        return _chart._defaultValueFormatter
    }
    
    open func scatterChartRendererChartYMax(_ renderer: ScatterChartRenderer) -> Double
    {
        return _chart.chartYMax
    }
    
    open func scatterChartRendererChartYMin(_ renderer: ScatterChartRenderer) -> Double
    {
        return _chart.chartYMin
    }
    
    open func scatterChartRendererChartXMax(_ renderer: ScatterChartRenderer) -> Double
    {
        return _chart.chartXMax
    }
    
    open func scatterChartRendererChartXMin(_ renderer: ScatterChartRenderer) -> Double
    {
        return _chart.chartXMin
    }
    
    open func scatterChartRendererMaxVisibleValueCount(_ renderer: ScatterChartRenderer) -> Int
    {
        return _chart.maxVisibleValueCount
    }
    
    // MARK: - CandleStickChartRendererDelegate
    
    open func candleStickChartRendererCandleData(_ renderer: CandleStickChartRenderer) -> CandleChartData!
    {
        return _chart.candleData
    }
    
    open func candleStickChartRenderer(_ renderer: CandleStickChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return _chart.getTransformer(which)
    }
    
    open func candleStickChartDefaultRendererValueFormatter(_ renderer: CandleStickChartRenderer) -> NumberFormatter!
    {
        return _chart._defaultValueFormatter
    }
    
    open func candleStickChartRendererChartYMax(_ renderer: CandleStickChartRenderer) -> Double
    {
        return _chart.chartYMax
    }
    
    open func candleStickChartRendererChartYMin(_ renderer: CandleStickChartRenderer) -> Double
    {
        return _chart.chartYMin
    }
    
    open func candleStickChartRendererChartXMax(_ renderer: CandleStickChartRenderer) -> Double
    {
        return _chart.chartXMax
    }
    
    open func candleStickChartRendererChartXMin(_ renderer: CandleStickChartRenderer) -> Double
    {
        return _chart.chartXMin
    }
    
    open func candleStickChartRendererMaxVisibleValueCount(_ renderer: CandleStickChartRenderer) -> Int
    {
        return _chart.maxVisibleValueCount
    }
    
    // MARK: - BubbleChartRendererDelegate
    
    open func bubbleChartRendererData(_ renderer: BubbleChartRenderer) -> BubbleChartData!
    {
        return _chart.bubbleData
    }
    
    open func bubbleChartRenderer(_ renderer: BubbleChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return _chart.getTransformer(which)
    }
    
    open func bubbleChartDefaultRendererValueFormatter(_ renderer: BubbleChartRenderer) -> NumberFormatter!
    {
        return _chart._defaultValueFormatter
    }
    
    open func bubbleChartRendererChartYMax(_ renderer: BubbleChartRenderer) -> Double
    {
        return _chart.chartYMax
    }
    
    open func bubbleChartRendererChartYMin(_ renderer: BubbleChartRenderer) -> Double
    {
        return _chart.chartYMin
    }
    
    open func bubbleChartRendererChartXMax(_ renderer: BubbleChartRenderer) -> Double
    {
        return _chart.chartXMax
    }
    
    open func bubbleChartRendererChartXMin(_ renderer: BubbleChartRenderer) -> Double
    {
        return _chart.chartXMin
    }
    
    open func bubbleChartRendererMaxVisibleValueCount(_ renderer: BubbleChartRenderer) -> Int
    {
        return _chart.maxVisibleValueCount
    }
    
    open func bubbleChartRendererXValCount(_ renderer: BubbleChartRenderer) -> Int
    {
        return _chart.data!.xValCount
    }
    
    // MARK: Accessors
    
    /// - returns: true if drawing the highlighting arrow is enabled, false if not
    open var isDrawHighlightArrowEnabled: Bool { return drawHighlightArrowEnabled; }
    
    /// - returns: true if drawing values above bars is enabled, false if not
    open var isDrawValueAboveBarEnabled: Bool { return drawValueAboveBarEnabled; }
    
    /// - returns: true if drawing shadows (maxvalue) for each bar is enabled, false if not
    open var isDrawBarShadowEnabled: Bool { return drawBarShadowEnabled; }
    
    /// the order in which the provided data objects should be drawn.
    /// The earlier you place them in the provided array, the further they will be in the background.
    /// e.g. if you provide [DrawOrder.Bar, DrawOrder.Line], the bars will be drawn behind the lines.
    open var drawOrder: [CombinedChartView.CombinedChartDrawOrder]
    {
        get
        {
            return _drawOrder
        }
        set
        {
            if (newValue.count > 0)
            {
                _drawOrder = newValue
            }
        }
    }
}
