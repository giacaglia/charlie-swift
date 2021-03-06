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
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
            newPageView.contentMode = .scaleAspectFill
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         // Load the pages that are now on screen
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x) / (pageWidth)))
        switch page {
        case 0:
            self.nextButton.backgroundColor = listBlue
            self.nextButton.setTitle("Start Tutorial", for: UIControlState())
            self.nextButton.setImage(nil, for: UIControlState())
        case 1:
            self.nextButton.backgroundColor = UIColor.white
            self.nextButton.setTitle("", for: UIControlState())
            self.nextButton.setImage(UIImage(named: "blue_next"), for: UIControlState())
            self.nextButton.tintColor = listBlue
        case 2:
            self.nextButton.backgroundColor = UIColor.white
            self.nextButton.setTitle("", for: UIControlState())
            self.nextButton.setImage(UIImage(named: "red_next"), for: UIControlState())
            self.nextButton.tintColor = listRed
        case 3:
            self.nextButton.backgroundColor = UIColor.white
            self.nextButton.setTitle("", for: UIControlState())
            self.nextButton.setImage(UIImage(named: "green_next"), for: UIControlState())
            self.nextButton.tintColor = listGreen
        case 4:
            self.nextButton.backgroundColor = listBlue
            self.nextButton.setTitle("Start Swiping", for: UIControlState())
            self.nextButton.setImage(nil, for: UIControlState())
        default:
            break
        }
    }
    
    @IBAction func didPressNext(_ sender: AnyObject) {
        let pageWidth = self.scrollView.frame.size.width
        let page : CGFloat = (self.scrollView.contentOffset.x) / (pageWidth)
        
        if page < 4 {
            var frame = scrollView.frame
            frame.origin.x = frame.size.width * (page + 1.0);
            frame.origin.y = 0;
            scrollView.scrollRectToVisible(frame, animated: true)
        }
        else {
            dismiss(animated: true, completion: nil)
            charlieAnalytics.track("App Tutorial Completed")
        }
    }
    
    
}
