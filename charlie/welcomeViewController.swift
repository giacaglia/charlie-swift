//
//  welcomeViewController.swift
//  charlie
//
//  Created by James Caralis on 7/18/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
import RealmSwift


class welcomeViewController: UIViewController, UIScrollViewDelegate {
    
    var cHelp = cHelper()
    var keyStore = NSUbiquitousKeyValueStore()
    var pageImages: [UIImage] = []
    var pageViews: [UIView?] = []
    var pageTitles = [String()]
    var colors:[UIColor] = [UIColor.whiteColor(), listGreen, listRed, listBlue]
    
    var realm = Realm(path: Realm.defaultPath, readOnly: false, encryptionKey: cHelper().getKey())!
  
    //var realm = Realm()
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var splashImageView: UIImageView!
    
   
    func didFinishLaunching(notification: NSNotification!) {
        

        if defaults.stringForKey("firstLoad") != nil
        {
            if let resultController = storyboard!.instantiateViewControllerWithIdentifier("passcodeViewController") as? passcodeViewController {
                presentViewController(resultController, animated: true, completion: nil)
            }
        }
        
    }
    
    func didEnterBackgroundNotification(notification: NSNotification) {
        cHelp.splashImageView(self.view)
        
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishLaunching:", name: UIApplicationDidFinishLaunchingNotification, object: nil)
        
        
        
        if Reachability.isConnectedToNetwork() {
            // Go ahead and fetch your data from the internet
            // ...
        } else {
            println("Internet connection not available")
            
            var alert = UIAlertView(title: "No Internet connection", message: "Please ensure you are connected to the Internet", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    
        
        if defaults.stringForKey("firstLoad") == nil
        {
             keyChainStore.set("", key: "pin")
          
        }

            
        if users.count > 0 &&  keyChainStore.get("pin") != ""

        {
            performSegueWithIdentifier("skipOnboarding", sender: self)
        }
        else
        {
            
            self.splashImageView.hidden = true
            self.setupWelcomeScreens()
        }
        
        
        
    }
    
    
    
    func setupWelcomeScreens() {
        
        cHelp.getSettings()
            {
                (response) in
                
                if response == false
                {
                    println("error getting public database")
                
                }

                
                
            }
        
        
        
        
        charlieAnalytics.track("Onboarding Tutorial Started")
        
        //setup welcome screens
        pageImages =
            [
                UIImage(named: "iTunesArtwork")!,
                UIImage(named: "happy_onboard")!,
                UIImage(named: "sad_onboard")!,
                UIImage(named: "iTunesArtwork")!
        ]
        
        pageTitles =
            [  "Spend money on what makes you happy",
                "Sometimes we spend money on things that bring us joy",
                "...and sometimes we spend on things that don't",
                "Charlie tracks your spending so you can buy more of what makes you happy"
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
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            // 3
          
            let newPageView = UIView()
            newPageView.backgroundColor = colors[page]
            newPageView.frame = frame
            
           
            if page == 0
            {
                //tutorial title
                var welcomeFrame = CGRectMake(0, 0, 326, 50)
                welcomeFrame.origin.x = (self.view.frame.size.width / 2) - 163
                welcomeFrame.origin.y = self.view.frame.size.height -  (self.view.frame.size.height * 0.90)
                var welcome = UILabel(frame: welcomeFrame)
                welcome.numberOfLines = 0
                welcome.font = UIFont (name: "AvenirNext-Regular", size: 22)
                welcome.textColor =  UIColor.blackColor()
                welcome.textAlignment = .Center
                welcome.textAlignment = NSTextAlignment.Center
                welcome.text = "Welcome to Charlie"
                newPageView.addSubview(welcome)
               
            }

           
            pageControl.currentPageIndicatorTintColor = UIColor.lightGrayColor()
            pageControl.pageIndicatorTintColor = UIColor.blackColor()

            //tutorial title
            var titleFrame = CGRectMake(0, 0, 280, 150)
            titleFrame.origin.x = (self.view.frame.size.width / 2) - 140
            titleFrame.origin.y = self.view.frame.size.height -  (self.view.frame.size.height * 0.90)
            var title = UILabel(frame: titleFrame)
            title.numberOfLines = 0
            title.font = UIFont (name: "AvenirNext-Regular", size: 22)
            if page == 0
            {
                title.textColor =  UIColor.lightGrayColor()
            }
            else
            {
                title.textColor =  UIColor.whiteColor()
            }
            
            title.textAlignment = .Center
            title.textAlignment = NSTextAlignment.Center
            title.text = pageTitles[page]
            newPageView.addSubview(title)
            
            
            //tutorial image
            var imageViewFrame = CGRectMake(0, 0, 230, 230)
            imageViewFrame.origin.x = (self.view.frame.size.width / 2) - 115
            imageViewFrame.origin.y = (self.view.frame.size.height) - (self.view.frame.size.height * 0.60)
            var imageView = UIImageView(frame: imageViewFrame)
            imageView.image =   pageImages[page]
            imageView.layer.cornerRadius = 115
            imageView.clipsToBounds = true
            imageView.layer.borderColor = UIColor.whiteColor().CGColor
            imageView.layer.borderWidth = 10

            newPageView.addSubview(imageView)

            
            
            
            
            //loginbutton
            if page == 3
            {
                var loginButtonFrame = CGRectMake(0, 0, 300, 40)
                loginButtonFrame.origin.x = (self.view.frame.size.width / 2) - 150
                loginButtonFrame.origin.y = self.view.frame.size.height -  (self.view.frame.size.height * 0.15)
                var loginButton = UIButton(frame: loginButtonFrame)
                loginButton.backgroundColor = UIColor.whiteColor()
                loginButton.setTitle("Let's Get Started", forState: .Normal)
                loginButton.setTitleColor(listBlue, forState: UIControlState.Normal)
                loginButton.layer.cornerRadius = 10
                loginButton.addTarget(self, action: "loginButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
                newPageView.addSubview(loginButton)
            }
            
            
            
            
            
            scrollView.addSubview(newPageView)
            // 4
            pageViews[page] = newPageView
        }
    

    }

    
    func loginButtonAction(sender:UIButton!)
    {
        charlieAnalytics.track("Onboarding Tutorial Completed")
        performSegueWithIdentifier("toRegistration", sender: self)
        
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
        
       
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
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
    
    
    
   
    
  
  
    
    
    
}
