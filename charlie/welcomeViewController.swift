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
    
    var keyStore = NSUbiquitousKeyValueStore()
    
    var cHelp = cHelper()
    
    
    var pageImages: [UIImage] = []
    var pageViews: [UIView?] = []
    var pageTitles = [String()]
    
   // var realm = Realm(path: Realm.defaultPath, readOnly: false, encryptionKey: cHelper().getKey())!
    var realm = Realm()
    
    var colors:[UIColor] = [UIColor.whiteColor(), listGreen, listRed, listBlue]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
 
    
    
  
    
    
    func didEnterBackgroundNotification(notification: NSNotification)
    {
        var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blur.frame = view.frame
        blur.tag = 86
        view.addSubview(blur)
    }

    
    
    
    func didFinishLaunching(notification: NSNotification!) {
        
//        var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
//        blur.frame = view.frame
//        blur.tag = 86
//        view.addSubview(blur)
        
        if let resultController = storyboard!.instantiateViewControllerWithIdentifier("passcodeViewController") as? passcodeViewController {
            
            presentViewController(resultController, animated: true, completion: { () -> Void in
                
//                self.view.viewWithTag(86)?.removeFromSuperview()
                
            })
        }
        
    }
    
    
    
    
    
    
    func setupWelcomeScreens() {
        
       
        
        
        
        charlieAnalytics.track("Tutorial Show")
        
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
    
    
    
    
    func alertUserRecoverData()
    {
        
        
        
        var refreshAlert = UIAlertController(title: "Alert", message: "Would you like us to recover?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            
            
            
            
                        //get categories
                        cService.getCategories()
                            {
            
                                (responses) in
            
                                for response in responses
                                {
            
                                    var cat = Category()
                                    var id:String = response["id"] as! String
                                    var type:String = response["type"] as! String
                                    cat.id = id
                                    cat.type = type
                                    let categories = ",".join(response["hierarchy"] as! Array)
                                    cat.categories = categories
                                    self.realm.write {
                                        self.realm.add(cat, update: true)
                                    }
                                }
            
                                let access_token = self.keyStore.stringForKey("access_token")!
                                let email = self.keyStore.stringForKey("email_address")!
                                
                                //add user
                                // Create a Person object
                                let user = User()
                                user.email = email
                                user.password = "password"
                                user.access_token = access_token    
                                self.realm.write {
                                    self.realm.add(user, update: true)
                                }
            
                                self.cHelp.addUpdateResetAccount(1, dayLength: 0)
                                    {
                                        (response) in
                                        
                                         
                                        
                                        self.performSegueWithIdentifier("skipOnboarding", sender: self)
                                        
                                }
                                
                        }

            
            
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
            
            self.setupWelcomeScreens()
        }))
        
        self.presentViewController(refreshAlert, animated: true, completion: nil)
        
        
        
        
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
       
        
        if users.count == 0
        {
            
            setupWelcomeScreens()
        }
            
            var access_token = ""
            if keyStore.stringForKey("access_token") != nil
            {
                access_token = keyStore.stringForKey("access_token")!
            }
            
            
            if access_token != "" && users.count == 0
            {
                //recover user
                println("Need to recover user")
                
                
                //alertUserRecoverData()
                
                
            }
           //     no icloud token and no users so show onboarding
            
            
            
            
            else if users.count == 0 ||  keyChainStore.get("pin") == nil
            {
                println("no user so show onboarding")
                
            }
                //if we have users skip onboarding
            else
            {
                println("have user")
                
                
                
                performSegueWithIdentifier("skipOnboarding", sender: self)
                
            }
            
    
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
// 
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishLaunching:", name: UIApplicationDidFinishLaunchingNotification, object: nil)
 
        
        
        
        
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
            var imageViewFrame = CGRectMake(0, 0, 250, 250)
            imageViewFrame.origin.x = (self.view.frame.size.width / 2) - 125
            imageViewFrame.origin.y = (self.view.frame.size.height) - (self.view.frame.size.height * 0.60)
            var imageView = UIImageView(frame: imageViewFrame)
            imageView.image =   pageImages[page]
            imageView.layer.cornerRadius = 125
            imageView.clipsToBounds = true
            imageView.layer.borderColor = UIColor.whiteColor().CGColor
            imageView.layer.borderWidth = 10

            newPageView.addSubview(imageView)

            
            
            
            
            //loginbutton
            if page == 3
            {
                var loginButtonFrame = CGRectMake(0, 0, 300, 50)
                loginButtonFrame.origin.x = (self.view.frame.size.width / 2) - 150
                loginButtonFrame.origin.y = self.view.frame.size.height -  (self.view.frame.size.height * 0.15)
                var loginButton = UIButton(frame: loginButtonFrame)
                loginButton.setTitle("Let's Get Started", forState: .Normal)
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
        println("Button tapped")
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
    
    
    
   
    
  
  
    
    
    
}
