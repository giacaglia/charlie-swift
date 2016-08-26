//
//  SBGestureTableView.swift
//  SBGestureTableView-Swift
//
//  Created by Ben Nichols on 10/3/14.
//  Copyright (c) 2014 Stickbuilt. All rights reserved.
//

import UIKit

class SBGestureTableView: UITableView, UIGestureRecognizerDelegate {

    var draggingViewOpacity = 1.0
    var isEnabled = true
    var edgeSlidingMargin = 0.0
    var edgeAutoscrollMargin = 0.0

    var cellReplacingBlock: ((SBGestureTableView, SBGestureTableViewCell) -> (Void))?
    var didMoveCellFromIndexPathToIndexPathBlock: ((IndexPath, IndexPath) -> (Void))?
    
    var canReorder: Bool {
        get {
            return longPress.isEnabled
        }
        set {
            longPress.isEnabled = newValue
        }
    }
    var minimumLongPressDuration : CFTimeInterval {
        get {
            return longPress.minimumPressDuration;
        }
        set {
            if (newValue <= 0) {
                longPress.minimumPressDuration = 0.5;
            }
            longPress.minimumPressDuration = newValue;
        }
    }
    
    fileprivate var scrollRate = 0.0
    fileprivate var currentLocationIndexPath : IndexPath?
    fileprivate var initialIndexPath : IndexPath?
    fileprivate var draggingView: UIImageView?
    fileprivate var savedObject: NSObject?
    fileprivate var scrollDisplayLink : CADisplayLink?
    fileprivate var longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()

    

    func initialize() {
        longPress.addTarget(self, action: #selector(SBGestureTableView.longPress(_:)))
        longPress.delegate = self
        addGestureRecognizer(longPress)
        cellReplacingBlock = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            tableView.replaceCell(cell, duration: 0.3, bounce: 8, completion: nil)
        }
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func indexPathFromGesture(_ gesture: UIGestureRecognizer) -> IndexPath? {
        let location = gesture.location(in: self)
        let indexPath = indexPathForRow(at: location)
        return indexPath
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func cancelGesture() {
        longPress.isEnabled = false
        longPress.isEnabled = true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
            if isEnabled && didMoveCellFromIndexPathToIndexPathBlock != nil {
                if let indexPath = indexPathFromGesture(gestureRecognizer) {
                    if let canMove = dataSource?.tableView?(self, canMoveRowAt: indexPath) {
                        if canMove {
                            return true
                        }
                    } else {
                        return true
                    }
                }
            }
            return false
        }
        return true
    }
    
    func longPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self)
        let indexPath = indexPathForRow(at: location)
        let sections = numberOfSections
        var rows = 0
        for i in 0 ..< sections {
            rows += numberOfRows(inSection: i)
        }
        
        // get out of here if the long press was not on a valid row or our table is empty
        // or the dataSource tableView:canMoveRowAtIndexPath: doesn't allow moving the row
        if (rows == 0 || (gesture.state == UIGestureRecognizerState.began && indexPath == nil) ||
            (gesture.state == UIGestureRecognizerState.ended && currentLocationIndexPath == nil)) {
                cancelGesture()
                return
        }
        
        // started
        if gesture.state == UIGestureRecognizerState.began {
            isEnabled = false
            let cell = cellForRow(at: indexPath!)!;
//            draggingRowHeight = cell.frame.size.height;
            cell.setSelected(false, animated: false)
            cell.setHighlighted(false, animated: false)
            
            // make an image from the pressed tableview cell
            UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
            cell.layer.render(in: UIGraphicsGetCurrentContext()!)
            let cellImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // create and image view that we will drag around the screen
            if draggingView == nil {
                draggingView = UIImageView(image: cellImage)
                addSubview(draggingView!)
                let rect = rectForRow(at: indexPath!)
                draggingView!.frame = draggingView!.bounds.offsetBy(dx: rect.origin.x, dy: rect.origin.y)
                
                // add drop shadow to image and lower opacity
                draggingView!.layer.masksToBounds = false
                draggingView!.layer.shadowColor = UIColor.black.cgColor
                draggingView!.layer.shadowOffset = CGSize(width: 0, height: 0);
                draggingView!.layer.shadowRadius = 4.0;
                draggingView!.layer.shadowOpacity = 0.7;
                draggingView!.layer.opacity = Float(draggingViewOpacity);
                
                // zoom image towards user
                UIView.beginAnimations("zoom", context: nil)
                draggingView!.transform = CGAffineTransform(scaleX: 1.1, y: 1.1);
                draggingView!.center = CGPoint(x: center.x, y: location.y);
                UIView.commitAnimations()
            }
            cell.isHidden = true;
            currentLocationIndexPath = indexPath;
            initialIndexPath = indexPath;
            
            // enable scrolling for cell
            scrollDisplayLink = CADisplayLink(target: self, selector: #selector(SBGestureTableView.scrollTableWithCell(_:)))
            scrollDisplayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }
            // dragging
        else if gesture.state == UIGestureRecognizerState.changed {
            var rect = bounds;
            // adjust rect for content inset as we will use it below for calculating scroll zones
            rect.size.height -= contentInset.top;
            let location = gesture.location(in: self);
            // tell us if we should scroll and which direction
            let scrollZoneHeight = rect.size.height / 6;
            let bottomScrollBeginning = contentOffset.y + contentInset.top + rect.size.height - scrollZoneHeight;
            let topScrollBeginning = contentOffset.y + contentInset.top  + scrollZoneHeight;
            // we're in the bottom zone
            if location.y >= bottomScrollBeginning {
                scrollRate = Double((location.y - bottomScrollBeginning) / scrollZoneHeight);
            }
                // we're in the top zone
            else if (location.y <= topScrollBeginning) {
                scrollRate = Double((location.y - topScrollBeginning) / scrollZoneHeight);
            }
            else {
                scrollRate = 0;
            }
        }
            // dropped
        else if gesture.state == UIGestureRecognizerState.ended {
            isEnabled = true
            let indexPath: IndexPath = currentLocationIndexPath!
            let cell = cellForRow(at: indexPath)!
            // remove scrolling CADisplayLink
            scrollDisplayLink?.invalidate();
            scrollDisplayLink = nil;
            scrollRate = 0;
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                let rect = self.rectForRow(at: indexPath)
                self.draggingView!.transform = CGAffineTransform.identity
                self.draggingView!.frame = self.draggingView!.bounds.offsetBy(dx: rect.origin.x, dy: rect.origin.y)
                }, completion: {(Bool) -> Void in
                    self.draggingView!.removeFromSuperview()
                    cell.isHidden = false
                    let visibleRows: NSArray = self.indexPathsForVisibleRows!
                    let mutableRows = visibleRows.mutableCopy() as! NSMutableArray
                    mutableRows.remove(indexPath)
                    let n = mutableRows.count
                    var i = 0, rows: [IndexPath] = []
                        for (i = 0; i < n; i += 1) {
                                rows.append(mutableRows[i] as! IndexPath)
                        }
                    self.reloadRows(at: rows as [IndexPath], with: UITableViewRowAnimation.none)
                    self.currentLocationIndexPath = nil
                    self.draggingView = nil
            })
        }
    }
    
    func updateCurrentLocation(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self)
        var indexPath = indexPathForRow(at: location)
        if let newIndexPath = delegate?.tableView?(self, targetIndexPathForMoveFromRowAt: initialIndexPath!, toProposedIndexPath: indexPath!) {
            indexPath = newIndexPath
        }
        if let indexPath = indexPath {
            let oldHeight = rectForRow(at: currentLocationIndexPath!).size.height
            let newHeight = rectForRow(at: indexPath).size.height
            if indexPath != currentLocationIndexPath
                && gesture.location(in: cellForRow(at: indexPath)).y > newHeight - oldHeight {
                    beginUpdates()
                    moveRow(at: currentLocationIndexPath!, to: indexPath)
                    didMoveCellFromIndexPathToIndexPathBlock!(currentLocationIndexPath!, indexPath)
                    currentLocationIndexPath = indexPath
                    endUpdates()
            }
        }
    }
    
    func scrollTableWithCell(_ timer: Timer) {
        let location = longPress.location(in: self)
        let currentOffset = contentOffset
        var newOffset = CGPoint(x: currentOffset.x, y: currentOffset.y + CGFloat(scrollRate) * 10)
        if newOffset.y < -contentInset.top {
            newOffset.y = -contentInset.top
        } else if contentSize.height + contentInset.bottom < frame.size.height {
            newOffset = currentOffset
        } else if newOffset.y > (contentSize.height + contentInset.bottom) - frame.size.height {
            newOffset.y = (contentSize.height + contentInset.bottom) - frame.size.height
        }
        contentOffset = newOffset
        if location.y >= 0 && location.y <= contentSize.height + 50 {
            draggingView!.center = CGPoint(x: center.x, y: location.y)
        }
        updateCurrentLocation(longPress)
    }
    
    
    func removeCellAt(_ indexPath: IndexPath, duration: TimeInterval, completion:(() -> Void)?) {
        let cell = cellForRow(at: indexPath)! as! SBGestureTableViewCell;
        removeCell(cell, indexPath: indexPath, duration: duration, completion: completion)

    }
    
    func removeCell(_ cell: SBGestureTableViewCell, duration: TimeInterval, completion:(() -> Void)?) {
        let indexPath = self.indexPath(for: cell)!
        removeCell(cell, indexPath: indexPath, duration: duration, completion: completion)
    }

    private func removeCell(_ cell: SBGestureTableViewCell, indexPath: IndexPath, duration: TimeInterval, completion: (()-> Void)?) {
        var duration = duration
        if (duration == 0) {
            duration = 0.3;
        }
        isEnabled = false
        let animation = cell.frame.origin.x > 0 ? UITableViewRowAnimation.right : UITableViewRowAnimation.left
        UIView.animate(withDuration: duration * cell.percentageOffsetFromEnd(), animations: { () -> Void in
            cell.center = CGPoint(x: cell.frame.size.width/2 + (cell.frame.origin.x > 0 ? cell.frame.size.width : -cell.frame.size.width),
                y: cell.center.y)
        }) { (finished) -> Void in
            UIView.animate(withDuration: duration, animations: { () -> Void in
                cell.leftSideView.alpha = 0
                cell.rightSideView.alpha = 0
            })
            self.deleteRowsAtIndexPaths([indexPath], withRowAnimation: animation, duration:duration, completion: { () -> Void in
                cell.leftSideView.alpha = 1
                cell.rightSideView.alpha = 1
                cell.leftSideView.removeFromSuperview()
                cell.rightSideView.removeFromSuperview()
                self.isEnabled = true
                completion?()
            })
        }
    }
    
    func replaceCell(_ cell: SBGestureTableViewCell, duration: TimeInterval, bounce: (CGFloat), completion:(() -> Void)?) {
        var duration = duration, bounce = bounce
        if duration == 0 {
            duration = 0.25
        }
        bounce = fabs(bounce)
        
        UIView.animate(withDuration: duration * cell.percentageOffsetFromCenter(), animations: { () -> Void in
            cell.center = CGPoint(x: cell.frame.size.width/2 + (cell.frame.origin.x > 0 ? -bounce : bounce), y: cell.center.y)
            cell.leftSideView.iconImageView.alpha = 0
            cell.rightSideView.iconImageView.alpha = 0
            }, completion: {(done) -> Void in
                UIView.animate(withDuration: duration/2, animations: { () -> Void in
                    cell.center = CGPoint(x: cell.frame.size.width/2, y: cell.center.y)
                    }, completion: {(done) -> Void in
                        cell.leftSideView.removeFromSuperview()
                        cell.rightSideView.removeFromSuperview()
                        completion?()
                })
        })
    }
    
    func fullSwipeCell(_ cell: SBGestureTableViewCell, duration: TimeInterval, completion:(() -> Void)?) {
        UIView.animate(withDuration: duration * cell.percentageOffsetFromCenter(), animations: { () -> Void in
            cell.center = CGPoint(x: cell.frame.size.width/2 + (cell.frame.origin.x > 0 ? cell.frame.size.width : -cell.frame.size.width), y: cell.center.y)
            }, completion: {(done) -> Void in
                completion?()
        })
    }
    
    fileprivate func deleteRowsAtIndexPaths(_ indexPaths: [IndexPath], withRowAnimation animation: UITableViewRowAnimation, duration: TimeInterval, completion:() -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        UIView.animate(withDuration: duration) { () -> Void in
            self.deleteRows(at: indexPaths, with: animation)
            
        }
        CATransaction.commit()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        showOrHideBackgroundViewAnimatedly(false)
    }

    func showOrHideBackgroundViewAnimatedly(_ animatedly: Bool) {
        UIView.animate(withDuration: animatedly ? 0.3 : 0, animations: { () -> Void in
            self.backgroundView?.alpha = self.isEmpty() ? 1 : 0
        })
    }
    
    func isEmpty() -> (Bool) {
        if let dataSource = dataSource {
            let numberOfSections = dataSource.numberOfSections!(in: self)
            for i in 0 ..< numberOfSections {
                let numberOfRowsInSection = dataSource.tableView(self, numberOfRowsInSection: i)
                if numberOfRowsInSection > 0 {
                    return false
                }
            }
        }
        return true
    }

    override func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        super.insertRows(at: indexPaths, with: animation)
        showOrHideBackgroundViewAnimatedly(true)
    }

    override func insertSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        super.insertSections(sections, with: animation)
        showOrHideBackgroundViewAnimatedly(true)
    }

    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        super.deleteRows(at: indexPaths, with: animation)
        showOrHideBackgroundViewAnimatedly(true)
    }
    
    override func deleteSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        super.deleteSections(sections, with: animation)
        showOrHideBackgroundViewAnimatedly(true)
    }
    
    override func reloadData() {
        super.reloadData()
        showOrHideBackgroundViewAnimatedly(true)
    }
}
