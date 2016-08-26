//
//  ChartYAxis.swift
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

/// Class representing the y-axis labels settings and its entries.
/// Be aware that not all features the YLabels class provides are suitable for the RadarChart.
/// Customizations that affect the value range of the axis need to be applied before setting data for the chart.
open class ChartYAxis: ChartAxisBase
{
    @objc
    public enum YAxisLabelPosition: Int
    {
        case outsideChart
        case insideChart
    }
    
    ///  Enum that specifies the axis a DataSet should be plotted against, either Left or Right.
    @objc
    public enum AxisDependency: Int
    {
        case left
        case right
    }
    
    open var entries = [Double]()
    open var entryCount: Int { return entries.count; }
    
    /// the number of y-label entries the y-labels should have, default 6
    fileprivate var _labelCount = Int(6)
    
    /// indicates if the top y-label entry is drawn or not
    open var drawTopYLabelEntryEnabled = true
    
    /// if true, the y-labels show only the minimum and maximum value
    open var showOnlyMinMaxEnabled = false
    
    /// flag that indicates if the axis is inverted or not
    open var inverted = false
    
    /// if true, the y-label entries will always start at zero
    open var startAtZeroEnabled = true
    
    /// if true, the set number of y-labels will be forced
    open var forceLabelsEnabled = true

    /// the formatter used to customly format the y-labels
    open var valueFormatter: NumberFormatter?
    
    /// the formatter used to customly format the y-labels
    internal var _defaultValueFormatter = NumberFormatter()
    
    /// A custom minimum value for this axis. 
    /// If set, this value will not be calculated automatically depending on the provided data. 
    /// Use `resetCustomAxisMin()` to undo this.
    /// Do not forget to set startAtZeroEnabled = false if you use this method.
    /// Otherwise, the axis-minimum value will still be forced to 0.
    open var customAxisMin = Double.nan
        
    /// Set a custom maximum value for this axis. 
    /// If set, this value will not be calculated automatically depending on the provided data. 
    /// Use `resetCustomAxisMax()` to undo this.
    open var customAxisMax = Double.nan

    /// axis space from the largest value to the top in percent of the total axis range
    open var spaceTop = CGFloat(0.1)

    /// axis space from the smallest value to the bottom in percent of the total axis range
    open var spaceBottom = CGFloat(0.1)
    
    open var axisMaximum = Double(0)
    open var axisMinimum = Double(0)
    
    /// the total range of values this axis covers
    open var axisRange = Double(0)
    
    /// the position of the y-labels relative to the chart
    open var labelPosition = YAxisLabelPosition.outsideChart
    
    /// the side this axis object represents
    fileprivate var _axisDependency = AxisDependency.left
    
    /// the minimum width that the axis should take
    /// 
    /// **default**: 0.0
    open var minWidth = CGFloat(0)
    
    /// the maximum width that the axis can take.
    /// use zero for disabling the maximum
    /// 
    /// **default**: 0.0 (no maximum specified)
    open var maxWidth = CGFloat(0)
    
    public override init()
    {
        super.init()
        
        _defaultValueFormatter.minimumIntegerDigits = 1
        _defaultValueFormatter.maximumFractionDigits = 1
        _defaultValueFormatter.minimumFractionDigits = 1
        _defaultValueFormatter.usesGroupingSeparator = true
        self.yOffset = 0.0
    }
    
    public init(position: AxisDependency)
    {
        super.init()
        
        _axisDependency = position
        
        _defaultValueFormatter.minimumIntegerDigits = 1
        _defaultValueFormatter.maximumFractionDigits = 1
        _defaultValueFormatter.minimumFractionDigits = 1
        _defaultValueFormatter.usesGroupingSeparator = true
        self.yOffset = 0.0
    }
    
    open var axisDependency: AxisDependency
    {
        return _axisDependency
    }
    
    open func setLabelCount(_ count: Int, force: Bool)
    {
        _labelCount = count
        
        if (_labelCount > 25)
        {
            _labelCount = 25
        }
        if (_labelCount < 2)
        {
            _labelCount = 2
        }
    
        forceLabelsEnabled = force
    }
    
    /// the number of label entries the y-axis should have
    /// max = 25,
    /// min = 2,
    /// default = 6,
    /// be aware that this number is not fixed and can only be approximated
    open var labelCount: Int
    {
        get
        {
            return _labelCount
        }
        set
        {
            setLabelCount(newValue, force: false);
        }
    }
    
    /// By calling this method, any custom minimum value that has been previously set is reseted, and the calculation is done automatically.
    open func resetCustomAxisMin()
    {
        customAxisMin = Double.nan
    }
    
    /// By calling this method, any custom maximum value that has been previously set is reseted, and the calculation is done automatically.
    open func resetCustomAxisMax()
    {
        customAxisMax = Double.nan
    }
    
    open func requiredSize() -> CGSize
    {
        let label = getLongestLabel() as NSString
        var size = label.size(attributes: [NSFontAttributeName: labelFont])
        size.width += xOffset * 2.0
        size.height += yOffset * 2.0
        size.width = max(minWidth, min(size.width, maxWidth > 0.0 ? maxWidth : size.width))
        return size
    }
    
    open func getRequiredHeightSpace() -> CGFloat
    {
        return requiredSize().height + 2.5 * 2.0 + yOffset
    }

    open override func getLongestLabel() -> String
    {
        var longest = ""
        
        for (i in 0 ..< entries.count)
        {
            let text = getFormattedLabel(i)
            
            if (longest.characters.count < text.characters.count)
            {
                longest = text
            }
        }
        
        return longest
    }

    /// - returns: the formatted y-label at the specified index. This will either use the auto-formatter or the custom formatter (if one is set).
    open func getFormattedLabel(_ index: Int) -> String
    {
        if (index < 0 || index >= entries.count)
        {
            return ""
        }
        
        return (valueFormatter ?? _defaultValueFormatter).string(from: entries[index])!
    }
    
    /// - returns: true if this axis needs horizontal offset, false if no offset is needed.
    open var needsOffset: Bool
    {
        if (isEnabled && isDrawLabelsEnabled && labelPosition == .outsideChart)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    open var isInverted: Bool { return inverted; }
    
    open var isStartAtZeroEnabled: Bool { return startAtZeroEnabled; }

    /// - returns: true if focing the y-label count is enabled. Default: false
    open var isForceLabelsEnabled: Bool { return forceLabelsEnabled }

    open var isShowOnlyMinMaxEnabled: Bool { return showOnlyMinMaxEnabled; }
    
    open var isDrawTopYLabelEntryEnabled: Bool { return drawTopYLabelEntryEnabled; }
}
