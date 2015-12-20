//
//  tutorialCardViewController.swift
//  charlie
//
//  Created by Jim Caralis on 7/8/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit


class TutorialCardViewController: UIViewController {
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
    
    @IBAction func didPressNext(sender: AnyObject) {
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        charlieAnalytics.track("App Tutorial Completed")
    }
    
    
}