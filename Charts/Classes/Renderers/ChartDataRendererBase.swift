//
//  ChartDataRendererBase.swift
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

open class ChartDataRendererBase: ChartRendererBase
{
    internal var _animator: ChartAnimator!
    
    public init(animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(viewPortHandler: viewPortHandler)
        _animator = animator
    }

    open func drawData(context: CGContext?)
    {
        fatalError("drawData() cannot be called on ChartDataRendererBase")
    }
    
    open func drawValues(context: CGContext?)
    {
        fatalError("drawValues() cannot be called on ChartDataRendererBase")
    }
    
    open func drawExtras(context: CGContext?)
    {
        fatalError("drawExtras() cannot be called on ChartDataRendererBase")
    }
    
    open func drawHighlighted(context: CGContext?, indices: [ChartHighlight])
    {
        fatalError("drawHighlighted() cannot be called on ChartDataRendererBase")
    }
}
