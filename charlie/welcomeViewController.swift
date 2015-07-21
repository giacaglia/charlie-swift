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
                UIImage(named: "iTunesArtwork")!,
                UIImage(named: "iTunesArtwork")!,
                UIImage(named: "iTunesArtwork")!
        ]
        
        pageTitles =
            [  "Page 1",
                "Page 2",
                "Page 3",
                "Page 4"
        ]
        
        
        
        
        let pageCount = pageImages.count
        
        // pageControl.currentPage = 0
        // pageControl.numberOfPages = pageCount
        
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
        
        
        
        
//        if access_token != "" && users.count == 0
//        {
//            //recover user
//            println("Need to recover user")
//            
//            
//            //get categories
//            cService.getCategories()
//                {
//                    
//                    (responses) in
//                    
//                    for response in responses
//                    {
//                        
//                        var cat = Category()
//                        var id:String = response["id"] as! String
//                        var type:String = response["type"] as! String
//                        cat.id = id
//                        cat.type = type
//                        let categories = ",".join(response["hierarchy"] as! Array)
//                        cat.categories = categories
//                        realm.write {
//                            realm.add(cat, update: true)
//                        }
//                    }
//                    
//                    let access_token = self.keyStore.stringForKey("access_token")!
//                    
//                    
//                    // Create a user object
//                    let user = User()
//                    user.email = "test@charlie.com"
//                    user.pin = "0000"
//                    user.password = "password"
//                    user.access_token = access_token
//                    realm.write {
//                        realm.add(user, update: true)
//                    }
//                    
//                    self.keyStore.setString("test@charlie.com", forKey: "email")
//                    self.keyStore.setString("password", forKey: "password")
//                    self.keyStore.setString(access_token, forKey: "access_token")
//                    self.keyStore.synchronize()
//                    
//                    
//                    
//                    
//                    self.cHelp.addUpdateResetAccount(1, dayLength: 0)
//                        {
//                            (response) in
//                            
//                        
//                            self.performSegueWithIdentifier("skipOnboarding", sender: self)
//                            
//                    }
//                    
//            }
//            
//            
//        }
//            //no icloud token and no users so show onboarding
//        else if users.count == 0
//        {
//            println("no user so show onboarding")
//            
//        }
//            //if we have users skip onboarding
//        else
//        {
//            println("have user")
//            
//            performSegueWithIdentifier("skipOnboarding", sender: self)
//            
//        }
        
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
            
            let newPageView = UIView()
            newPageView.backgroundColor = colors[page]
            newPageView.frame = frame
            
            
            var imageView = UIImageView(frame: CGRectMake(0, 0, 200, 200))
            imageView.image =   pageImages[page]
            imageView.layer.cornerRadius = 100
            imageView.clipsToBounds = true
            //imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
            newPageView.addSubview(imageView)
            
            
            var label = UILabel(frame: CGRectMake(0, 0, 200, 21))
            label.center = CGPointMake(160, 284)
            label.textAlignment = NSTextAlignment.Center
            label.text = pageTitles[page]
            
            newPageView.addSubview(label)
            
            
            scrollView.addSubview(newPageView)
            
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
        //pageControl.currentPage = page
        
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
