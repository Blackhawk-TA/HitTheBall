//
//  GameViewController.swift
//  HitTheBall
//
//  Created by Daniel Peters on 15.08.15.
//  Copyright (c) 2015 Daniel Peters. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import GoogleMobileAds

extension SKNode {
}

class GameViewController: UIViewController {
    
    // Properties for Banner Ad
    let RemovedAds_Defaults = NSUserDefaults.standardUserDefaults()
    var removedAds = Bool()
    var bannerVisible = false
    var googleBannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var adShowed = false
    var adTimer: NSTimer?
    
    //Full Screen ad
    func createAndLoadAd() -> GADInterstitial {
        let ad = GADInterstitial(adUnitID: "ca-app-pub-4511874521867277/7430629948")
        let request = GADRequest()
        ad.loadRequest(request)
        return ad
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Ads Variable
        removedAds = RemovedAds_Defaults.boolForKey("RemoveAds")
        
        //GameCenter
        authenticateLocalPlayer()
        
        let scene = MenuScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        
        self.interstitial = self.createAndLoadAd()
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        if (!removedAds) {
            //Show Google Ad Banner
            googleBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            googleBannerView.adUnitID = "ca-app-pub-4511874521867277/8219692342"
        
            googleBannerView.rootViewController = self
            let request: GADRequest = GADRequest()
            googleBannerView.loadRequest(request)
        
            googleBannerView.frame = CGRectMake(0, view.bounds.height-googleBannerView.frame.size.height, googleBannerView.frame.size.width, googleBannerView.frame.size.height)
        
            self.view.addSubview(googleBannerView)
            
            adTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "loadAd:", userInfo: nil, repeats: false)
        }
    }
    
    func loadAd(timer:NSTimer!) {
        if (self.interstitial.isReady && adShowed == false) {
            adShowed = true
            self.interstitial.presentFromRootViewController(self)
            self.interstitial = self.createAndLoadAd()
        }
    }
    
    //initiate gamecenter
    func authenticateLocalPlayer() {
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }
                
            else {
                print("GameCenter Online: ",(GKLocalPlayer.localPlayer().authenticated))
            }
        }
    }
}