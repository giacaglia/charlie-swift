//
//  SBGestureTableViewCellAction.swift
//  SBGestureTableView-Swift
//
//  Created by Ben Nichols on 10/3/14.
//  Copyright (c) 2014 Stickbuilt. All rights reserved.
//

import UIKit

class SBGestureTableViewGroupCellAction: NSObject {
    
    var icon : UIImage
    var color : UIColor
    var fraction : CGFloat
    var didTriggerBlock: ((SBGestureTableViewGroup, SBGestureTableViewGroupCell) -> (Void))
    var didHighlightBlock: ((SBGestureTableViewGroup, SBGestureTableViewGroupCell) -> (Void))?
    var didUnhighlightBlock: ((SBGestureTableViewGroup, SBGestureTableViewGroupCell) -> (Void))?
    
    init(icon: UIImage, color: UIColor, fraction: CGFloat, didTriggerBlock:(SBGestureTableViewGroup, SBGestureTableViewGroupCell)->()) {
        self.icon = icon
        self.color = color
        self.fraction = fraction
        self.didTriggerBlock = didTriggerBlock
        super.init()
    }
}
