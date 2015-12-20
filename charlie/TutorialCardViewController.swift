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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(true)
        pageImages = [
                UIImage(named: "tutorial_1")!,
                UIImage(named: "tutorial_2")!,
                UIImage(named: "tutorial_3")!,
                UIImage(named: "tutorial_4")!,
                UIImage(named: "tutorial_5")!
        ]
   
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(pageImages.count),
            height: scrollView.frame.size.height)
        
        loadAllPages()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        charlieAnalytics.track("App Tutorial Started")
    }
    
    func loadAllPages() {
        for page in 0 ..< pageImages.count {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .ScaleAspectFill
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
         // Load the pages that are now on screen
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
    }
    
    @IBAction func didPressNext(sender: AnyObject) {
        let pageWidth = self.scrollView.frame.size.width
        let page = Int(floor((self.scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
//        self.scrollView.
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        charlieAnalytics.track("App Tutorial Completed")
    }
    
    
}