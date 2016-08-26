//
//  SBGestureTableViewGroupCell.swift
//  SBGestureTableView-Swift
//
//  Created by Ben Nichols on 10/3/14.
//  Copyright (c) 2014 Stickbuilt. All rights reserved.
//

import UIKit


class SBGestureTableViewGroupCell: UITableViewCell {
    
    var actionIconsFollowSliding = true
    var actionIconsMargin: CGFloat = 20.0
    var actionNormalColor = UIColor(white: 0.85, alpha: 1)
    
    
    var leftSideView = SBGestureTableViewGroupCellSideView()
    var rightSideView = SBGestureTableViewGroupCellSideView()
    
    var firstLeftAction: SBGestureTableViewGroupCellAction? {
        didSet {
            if (firstLeftAction?.fraction == 0) {
                firstLeftAction?.fraction = 0.3
            }
        }
    }
    var secondLeftAction: SBGestureTableViewGroupCellAction? {
        didSet {
            if (secondLeftAction?.fraction == 0) {
                secondLeftAction?.fraction = 0.7
            }
        }
    }
    var firstRightAction: SBGestureTableViewGroupCellAction? {
        didSet {
            if (firstRightAction?.fraction == 0) {
                firstRightAction?.fraction = 0.3
            }
        }
    }
    var secondRightAction: SBGestureTableViewGroupCellAction? {
        didSet {
            if (secondRightAction?.fraction == 0) {
                secondRightAction?.fraction = 0.7
            }
        }
    }
    var currentAction: SBGestureTableViewGroupCellAction?
    override var center: CGPoint {
        get {
            return super.center
        }
        set {
            super.center = newValue
            updateSideViews()
        }
    }
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            updateSideViews()
        }
    }
    fileprivate var gestureTableView: SBGestureTableViewGroup!
    fileprivate let panGestureRecognizer = UIPanGestureRecognizer()
    
    
    
   
    
    @IBOutlet weak var transactionDate: UILabel!
    
    
    
    @IBOutlet weak var transactionAmount: UILabel!
    
    
    func setup() {
        panGestureRecognizer.addTarget(self, action: #selector(SBGestureTableViewGroupCell.slideCell(_:)))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    override func didMoveToSuperview() {
        gestureTableView = superview?.superview as? SBGestureTableViewGroup
    }
    
    func percentageOffsetFromCenter() -> (Double) {
        let diff = fabs(frame.size.width/2 - center.x);
        return Double(diff / frame.size.width);
    }
    
    func percentageOffsetFromEnd() -> (Double) {
        let diff = fabs(frame.size.width/2 - center.x);
        return Double((frame.size.width - diff) / frame.size.width);
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            let panGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            let velocity = panGestureRecognizer.velocity(in: self)
            let horizontalLocation = panGestureRecognizer.location(in: self).x
            if fabs(velocity.x) > fabs(velocity.y)
                && horizontalLocation > CGFloat(gestureTableView.edgeSlidingMargin)
                && horizontalLocation < frame.size.width - CGFloat(gestureTableView.edgeSlidingMargin)
                && gestureTableView.isEnabled {
                    return true;
            }
        } else if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
            if gestureTableView.didMoveCellFromIndexPathToIndexPathBlock == nil {
                return true;
            }
        }
        return false;
    }
    
    func actionForCurrentPosition() -> SBGestureTableViewGroupCellAction? {
        let fraction = fabs(frame.origin.x/frame.size.width)
        if frame.origin.x > 0 {
            if secondLeftAction != nil && fraction > secondLeftAction!.fraction {
                return secondLeftAction!
            } else if firstLeftAction != nil && fraction > firstLeftAction!.fraction {
                return firstLeftAction!
            }
        } else if frame.origin.x < 0 {
            if secondRightAction != nil && fraction > secondRightAction!.fraction {
                return secondRightAction!
            } else if firstRightAction != nil && fraction > firstRightAction!.fraction {
                return firstRightAction!
            }
        }
        return nil
    }
    
    func performChanges() {
        let action = actionForCurrentPosition()
        if let action = action {
            if frame.origin.x > 0 {
                leftSideView.backgroundColor = action.color
                leftSideView.iconImageView.image = action.icon
            } else if frame.origin.x < 0 {
                rightSideView.backgroundColor = action.color
                rightSideView.iconImageView.image = action.icon
            }
        } else {
            if frame.origin.x > 0 {
                leftSideView.backgroundColor = actionNormalColor
                leftSideView.iconImageView.image = firstLeftAction!.icon
            } else if frame.origin.x < 0 {
                rightSideView.backgroundColor = actionNormalColor
                rightSideView.iconImageView.image = firstRightAction!.icon
            }
        }
        if let image = leftSideView.iconImageView.image {
            leftSideView.iconImageView.alpha = frame.origin.x / (actionIconsMargin*2 + image.size.width)
        }
        if let image = rightSideView.iconImageView.image {
            rightSideView.iconImageView.alpha = -(frame.origin.x / (actionIconsMargin*2 + image.size.width))
        }
        if currentAction != action {
            action?.didHighlightBlock?(gestureTableView, self)
            currentAction?.didUnhighlightBlock?(gestureTableView, self)
            currentAction = action
        }
    }
    
    func hasAnyLeftAction() -> Bool {
        return firstLeftAction != nil || secondLeftAction != nil
    }
    
    func hasAnyRightAction() -> Bool {
        return firstRightAction != nil || secondRightAction != nil
    }
    
    func setupSideViews() {
        leftSideView.iconImageView.contentMode = actionIconsFollowSliding ? UIViewContentMode.right : UIViewContentMode.left
        rightSideView.iconImageView.contentMode = actionIconsFollowSliding ? UIViewContentMode.left : UIViewContentMode.right
        superview?.insertSubview(leftSideView, at: 0)
        superview?.insertSubview(rightSideView, at: 0)
    }
    
    func slideCell(_ panGestureRecognizer: UIPanGestureRecognizer) {
        if !hasAnyLeftAction() || !hasAnyRightAction() {
            return
        }
        var horizontalTranslation = panGestureRecognizer.translation(in: self).x
        if panGestureRecognizer.state == UIGestureRecognizerState.began {
            setupSideViews()
        } else if panGestureRecognizer.state == UIGestureRecognizerState.changed {
            if (!hasAnyLeftAction() && frame.size.width/2 + horizontalTranslation > frame.size.width/2)
                || (!hasAnyRightAction() && frame.size.width/2 + horizontalTranslation < frame.size.width/2) {
                    horizontalTranslation = 0
            }
            performChanges()
            center = CGPoint(x: frame.size.width/2 + horizontalTranslation, y: center.y)
        } else if panGestureRecognizer.state == UIGestureRecognizerState.ended {
            if (currentAction == nil && frame.origin.x != 0) || !gestureTableView.isEnabled {
                gestureTableView.cellReplacingBlock?(gestureTableView, self)
            } else {
                currentAction?.didTriggerBlock(gestureTableView, self)
            }
            currentAction = nil
        }
    }
    
    func updateSideViews() {
        leftSideView.frame = CGRect(x: 0, y: frame.origin.y, width: frame.origin.x, height: frame.size.height)
        if let image = leftSideView.iconImageView.image {
            leftSideView.iconImageView.frame = CGRect(x: actionIconsMargin, y: 0, width: max(image.size.width, leftSideView.frame.size.width - actionIconsMargin*2), height: leftSideView.frame.size.height)
        }
        rightSideView.frame = CGRect(x: frame.origin.x + frame.size.width, y: frame.origin.y, width: frame.size.width - (frame.origin.x + frame.size.width), height: frame.size.height)
        if let image = rightSideView.iconImageView.image {
            rightSideView.iconImageView.frame = CGRect(x: rightSideView.frame.size.width - actionIconsMargin, y: 0, width: min(-image.size.width, actionIconsMargin*2 - rightSideView.frame.size.width), height: rightSideView.frame.size.height)
        }
    }
}
