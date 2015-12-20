//
//  tutorialCardViewController.swift
//  charlie
//
//  Created by Jim Caralis on 7/8/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit


class TutorialCardViewController: UIViewController, UIScrollViewDelegate {
    var pageImages: [UIImage] = []
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(true)
        pageImages = [
                UIImage(named: "tutorial_1")!,
                UIImage(named: "tutorial_4")!,
                UIImage(named: "tutorial_5")!,
                UIImage(named: "tutorial_6")!
        ]
        
        let pageCount = pageImages.count
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
   
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(pageImages.count),
            height: scrollView.frame.size.height)
        
        loadAllPages()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        charlieAnalytics.track("App Tutorial Started")
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        pageControl.currentPage = page
    }
    
    
    func loadAllPages() {
        for page in 0..<pageImages.count {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
        }
    }
    
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        charlieAnalytics.track("App Tutorial Completed")
    }
    
    
}