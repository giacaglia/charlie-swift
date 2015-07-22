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
    
    let users = realm.objects(User)
    var cHelp = cHelper()
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var pageImages: [UIImage] = []
    var pageViews: [UIView?] = []
    var pageTitles = [String()]
    
    var colors:[UIColor] = [UIColor.whiteColor(), listGreen, listRed, listBlue]
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    override func viewDidAppear(animated: Bool) {
        //if no users and we have icloud access token we should restore user
        
        
        
        
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
        
        
        
        var access_token = ""
        if keyStore.stringForKey("access_token") != nil
        {
            access_token = keyStore.stringForKey("access_token")!
        }
        
        
        
        
        if access_token != "" && users.count == 0
        {
            //recover user
            println("Need to recover user")
            
            
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
                        realm.write {
                            realm.add(cat, update: true)
                        }
                    }
                    
                    let access_token = self.keyStore.stringForKey("access_token")!
                    
                    
                    // Create a user object
                    let user = User()
                    user.email = "test@charlie.com"
                    user.pin = "0000"
                    user.password = "password"
                    user.access_token = access_token
                    realm.write {
                        realm.add(user, update: true)
                    }
                    
                    self.keyStore.setString("test@charlie.com", forKey: "email")
                    self.keyStore.setString("password", forKey: "password")
                    self.keyStore.setString(access_token, forKey: "access_token")
                    self.keyStore.synchronize()
                    
                    
                    
                    
                    self.cHelp.addUpdateResetAccount(1, dayLength: 0)
                        {
                            (response) in
                            
                        
                            self.performSegueWithIdentifier("skipOnboarding", sender: self)
                            
                    }
                    
            }
            
            
        }
            //no icloud token and no users so show onboarding
        else if users.count == 0
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
                welcome.font = UIFont (name: "Montserrat-Bold", size: 24)
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
            title.font = UIFont (name: "Montserrat-Regular", size: 20)
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
