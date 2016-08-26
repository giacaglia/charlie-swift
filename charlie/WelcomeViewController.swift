//
//  WelcomeViewController.swift
//  charlie
//
//  Created by James Caralis on 7/18/15.
//  Copyright (c) 2015 James Caralis. All rights reserved.
//

import UIKit
import RealmSwift

class WelcomeViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var splashImageView: UIImageView!
    
    var cHelp = cHelper()
    var keyStore = NSUbiquitousKeyValueStore()
    var pageImages: [UIImage] = []
    var pageTitles = [String()]
    var colors:[UIColor] = [UIColor.white, listGreen, listRed, listBlue]
    //PRODCHANGE
   // var realm = try! Realm(configuration: Realm.Configuration(encryptionKey: cHelper().getKey()))
    
    //var realm =  try! Realm()
    
    //var realm = try! Realm(path: Realm().path, readOnly: false, encryptionKey: cHelper().getKey())

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var encriptionKey = cHelper().getKey()
//       
//        let config = Realm.Configuration(encryptionKey: encriptionKey)
//        realm = try! Realm(configuration: config)

        
        // If it's not connected to the internet
        if !Reachability.isConnectedToNetwork() {
            print("Internet connection not available")
            let alert = UIAlertView(title: "No Internet connection", message: "Please ensure you are connected to the Internet", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // USER FOUND IN THE DEVICE
        if users.count > 0  {
            performSegue(withIdentifier: "skipOnboarding", sender: self)
        }
        else {
            self.splashImageView.isHidden = true
            self.setupWelcomeScreens()
        }
    }
    
    func setupWelcomeScreens() {
        cHelp.getSettings() { (response) in
            if response == false {
                print("error getting public database")
            }
        }
        
        charlieAnalytics.track("Onboarding Tutorial Started")
        
        //setup welcome screens
        pageImages = [
                UIImage(named: "iTunesArtwork")!,
                UIImage(named: "happy_onboard")!,
                UIImage(named: "sad_onboard")!,
                UIImage(named: "iTunesArtwork")!
        ]
        
        pageTitles = [
                "Spend money on what makes you happy",
                "Sometimes we spend money on things that are worth it",
                "...and sometimes we spend on things that aren't",
                "Charlie helps you spend on things that are worth it, so you can buy more of what makes you happy"
        ]
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageImages.count
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(pageImages.count),
            height: scrollView.frame.size.height)
        loadAllPages()
    }
    
    func loginButtonAction(_ sender:UIButton!) {
        charlieAnalytics.track("Onboarding Tutorial Completed")
        performSegue(withIdentifier: "toRegistration", sender: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Load the pages that are now on screen
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        pageControl.currentPage = page
        if (page == 0) {
            pageControl.currentPageIndicatorTintColor = listBlue
            pageControl.pageIndicatorTintColor = UIColor(white: 0/255, alpha: 0.4)
        }
        else {
            pageControl.currentPageIndicatorTintColor = UIColor.white
            pageControl.pageIndicatorTintColor = UIColor(white: 0/255, alpha: 0.4)
        }
    }
    
    func loadAllPages() {
        pageControl.currentPageIndicatorTintColor = listBlue
        pageControl.pageIndicatorTintColor = UIColor(white: 0/255, alpha: 0.4)
        for page in 0..<pageImages.count {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            let newPageView = UIView()
            newPageView.backgroundColor = colors[page]
            newPageView.frame = frame
            
            if page == 0 {
                //tutorial title
                var welcomeFrame = CGRect(x: 0, y: 0, width: 326, height: 50)
                welcomeFrame.origin.x = (self.view.frame.size.width / 2) - 163
                welcomeFrame.origin.y = self.view.frame.size.height -  (self.view.frame.size.height * 0.90)
                let welcome = UILabel(frame: welcomeFrame)
                welcome.numberOfLines = 0
                welcome.font = UIFont (name: "AvenirNext-Regular", size: 22)
                welcome.textColor =  UIColor.black
                welcome.textAlignment = .center
                welcome.textAlignment = NSTextAlignment.center
                welcome.text = "Welcome to Charlie"
                newPageView.addSubview(welcome)
            }
            
            var titleFrame = CGRect(x: 0, y: 0, width: 280, height: 150)
            titleFrame.origin.x = (self.view.frame.size.width / 2) - 140
            titleFrame.origin.y = self.view.frame.size.height -  (self.view.frame.size.height * 0.90)
            let title = UILabel(frame: titleFrame)
            title.numberOfLines = 0
            title.font = UIFont (name: "AvenirNext-Regular", size: 22)
            if page == 0 {
                title.textColor =  UIColor.lightGray
            }
            else {
                title.textColor =  UIColor.white
            }
            title.textAlignment = .center
            title.textAlignment = NSTextAlignment.center
            title.text = pageTitles[page]
            newPageView.addSubview(title)
            
            //tutorial image
            var imageViewFrame = CGRect(x: 0, y: 0, width: 230, height: 230)
            imageViewFrame.origin.x = (self.view.frame.size.width / 2) - 115
            imageViewFrame.origin.y = (self.view.frame.size.height) - (self.view.frame.size.height * 0.60)
            let imageView = UIImageView(frame: imageViewFrame)
            imageView.image =   pageImages[page]
            imageView.layer.cornerRadius = 115
            imageView.clipsToBounds = true
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.layer.borderWidth = 10
            newPageView.addSubview(imageView)
            
            //loginbutton
            if page == 3 {
                var loginButtonFrame = CGRect(x: 0, y: 0, width: 300, height: 50)
                loginButtonFrame.origin.x = (self.view.frame.size.width / 2) - 150
                loginButtonFrame.origin.y = self.view.frame.size.height -  (self.view.frame.size.height * 0.15)
                let loginButton = UIButton(frame: loginButtonFrame)
                loginButton.backgroundColor = UIColor.white
                loginButton.setTitle("Let's Get Started", for: UIControlState())
                loginButton.setTitleColor(listBlue, for: UIControlState())
                loginButton.layer.cornerRadius = 10
                loginButton.addTarget(self, action: #selector(WelcomeViewController.loginButtonAction(_:)), for: UIControlEvents.touchUpInside)
                newPageView.addSubview(loginButton)
            }
            scrollView.addSubview(newPageView)
        }       
    }
    
}
