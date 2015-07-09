//
//  tutorialCardViewController.swift
//  charlie
//
//  Created by Jim Caralis on 7/8/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit


class tutorialCardViewController: UIViewController, UIScrollViewDelegate {

    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []

    @IBOutlet weak var pageControl: UIPageControl!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        pageImages =
            [
                UIImage(named: "tutorial_1.png")!,
                UIImage(named: "tutorial_4.png")!,
                UIImage(named: "tutorial_5.png")!,
                UIImage(named: "tutorial_6.png")!
        ]
        
        let pageCount = pageImages.count
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
        
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        let pagesScrollViewSize = scrollView.frame.size
    
        
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageImages.count),
            height: pagesScrollViewSize.height)
        
        loadVisiblePages()
        
        //scrollViewDidScroll(scrollView)
        
        
        
        
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
      
   
       
       
        
    }
    
    func loadPage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // 1
        if let pageView = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            // 2
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            // 3
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            
            // 4
            pageViews[page] = newPageView
        }
    }
    
    
    func purgePage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
    
    
    func loadVisiblePages() {
        
        println(scrollView.frame.size)
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        println("PAGE \(page)")
        if page == 0
        {
//            fbLoginView.hidden = true
//            message12.hidden = false
//            message12.text = "When curiosity strikes,\n poll your friends"
//            message3.hidden = true
//            privacyButton.hidden = true
            
        }
        
        if page == 1
        {
//            fbLoginView.hidden = true
//            message12.hidden = false
//            message12.text = "Help others gain knowledge, \n answer their polls"
//            message3.hidden = true
//            privacyButton.hidden = true
            
        }
        
        if page == 2
        {
//            fbLoginView.hidden = false
//            message12.hidden = true
//            message3.hidden = false
//            message3.text = "We will never post anything to Facebook on your behalf! "
//            privacyButton.hidden = false
            
            
        }
    
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        
       
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }
    
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
