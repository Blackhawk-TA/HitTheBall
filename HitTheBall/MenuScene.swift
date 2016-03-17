//
//  MenuScene.swift
//  HitTheBall
//
//  Created by Daniel Peters on 26.10.15.
//  Copyright © 2015 Daniel Peters. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameKit
import StoreKit
import GoogleMobileAds
import Darwin

class MenuScene: SKScene, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    //Constant Values
    let NotFirstStart_Defaults = NSUserDefaults.standardUserDefaults()
    let Music_Defaults = NSUserDefaults.standardUserDefaults()
    let Sound_Defaults = NSUserDefaults.standardUserDefaults()
    let RemovedAds_Defaults = NSUserDefaults.standardUserDefaults()
    let GameModeValue_Defaults = NSUserDefaults.standardUserDefaults()
    let HighscoreEasy_Defaults = NSUserDefaults.standardUserDefaults()
    let HighscoreHard_Defaults = NSUserDefaults.standardUserDefaults()
    
    //Global Variables
    var request : SKProductsRequest!
    var products : [SKProduct] = [] // List of available purchases
    var removedAds = false
    var Clouds = [SKSpriteNode]()
    var CloudText = ["Play (Easy)", "Play (Hard)", "Remove Ads"]
    var CloudName = ["play_easy", "play_hard", "remove_ads"]
    var notFirstStart = Bool()

    override func didMoveToView(view: SKView) {
        //Check if first start
        notFirstStart = NotFirstStart_Defaults.boolForKey("NotFirstStart")
        
        //Game hasn't been started yet
        if (notFirstStart == false) {
            self.NotFirstStart_Defaults.setBool(true, forKey: "NotFirstStart")
            
            //Enable Music & Sound for start
            self.Music_Defaults.setBool(true, forKey: "Music")
            self.Sound_Defaults.setBool(true, forKey: "Sound")
            
            //Enable Ads for start
            self.RemovedAds_Defaults.setBool(false, forKey: "RemoveAds")
        }
        
        
        //Check if iPad
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
        {
            let alert = UIAlertController(title: "Warning", message: "HitTheBird doesn't support iPad, you need an iPhone or iPod touch to play it.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.Default)  { _ in
                    exit(0)
                })
            
            // Show the alert
            self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
        
        // In-App Purchase
        removedAds = RemovedAds_Defaults.boolForKey("RemoveAds")
        self.initInAppPurchases()
        self.checkAndRemoveAds()
        
        //Get Res
        let width = self.size.width
        let height = self.size.height
        
        GlobalFunctions().drawBackground(self)
        GlobalFunctions().drawMenuOverlay(self)
        GlobalFunctions().drawGuns(self)
        
        //Scale Button
        let ButtonScale = width*0.15
        
        //Draw Settings Buttons
        let SettingsButton = SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfMenuIcon(frame: CGRect(x: 0, y: 0, width: ButtonScale, height: ButtonScale), toggleVisibility: true)))
        SettingsButton.position = CGPoint(x: SettingsButton.size.width*0.75, y: height-SettingsButton.size.height*0.75)
        SettingsButton.name = "SettingsButton"
        self.addChild(SettingsButton)
        
        //Draw Easy Highscore Label
        //Draw Score
        let lbl_HighscoreEasy = SKLabelNode(fontNamed:"Chalkduster")
        lbl_HighscoreEasy.text = "Highscore (Easy): " + GlobalFunctions().formatNumber(HighscoreEasy_Defaults.integerForKey("HighscoreEasy"))
        lbl_HighscoreEasy.fontSize = width*0.04
        lbl_HighscoreEasy.fontColor = UIColor(white: 0.0, alpha: 1.0)
        lbl_HighscoreEasy.position = CGPoint(x: width*0.5, y: height-width*0.1);
        self.addChild(lbl_HighscoreEasy)
        
        //Draw Highscore
        let lbl_HighscoreHard = SKLabelNode(fontNamed:"Chalkduster")
        lbl_HighscoreHard.text = "Highscore (Hard): " +  GlobalFunctions().formatNumber(HighscoreHard_Defaults.integerForKey("HighscoreHard"))
        lbl_HighscoreHard.fontSize = width*0.04
        lbl_HighscoreHard.fontColor = UIColor(white: 0.0, alpha: 1.0)
        lbl_HighscoreHard.position = CGPoint(x: width*0.5, y: height-width*0.16);
        self.addChild(lbl_HighscoreHard)
        
        //Draw Clouds
        var CloudPos = [ CGPoint(x: width*0.3, y: height*0.8), CGPoint(x: width*0.7, y: height*0.6), CGPoint(x: width*0.4, y: height*0.4) ]
        for var i=0; i<3; i++ {
            Clouds.append(SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfCloud(frame: CGRect(x: 0, y: 0, width: width/2.5, height: width/5), textInput: CloudText[i], textSize: width*0.035))))
            Clouds[i].position = CloudPos[i]
            Clouds[i].name = CloudName[i]
            self.addChild(Clouds[i])
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        //Create transitions
        let transition = SKTransition.fadeWithDuration(2.0)
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            node.runAction(SKAction.scaleTo(1.1, duration: NSTimeInterval(0.1))) {
                node.runAction(SKAction.scaleTo(1.0, duration: NSTimeInterval(0.1))) {
                    if (node.name == "play_easy") {
                        //Set GameMode Value for GameScene
                        self.GameModeValue_Defaults.setInteger(0, forKey: "GameMode")
                        
                        //Load Scene
                        let scene = GameScene(size: self.scene!.size)
                        scene.scaleMode = SKSceneScaleMode.AspectFill
                        self.scene!.view!.presentScene(scene, transition: transition)
                    }
                    else if (node.name == "play_hard") {
                        //Set GameMode Value for GameScene
                        self.GameModeValue_Defaults.setInteger(1, forKey: "GameMode")
                        
                        //Load Scene
                        let scene = GameScene(size: self.scene!.size)
                        scene.scaleMode = SKSceneScaleMode.AspectFill
                        self.scene!.view!.presentScene(scene, transition: transition)
                    }
                    else if (node.name == "remove_ads") {
                        self.inAppPurchase()
                    }
                    else if (node.name == "SettingsButton") {
                        let scene = MenuSettings(size: self.scene!.size)
                        scene.scaleMode = SKSceneScaleMode.AspectFill
                        self.scene!.view!.presentScene(scene, transition: transition)
                    }
                    else if (node.name == "InfoButton") {                        
                        let alert = UIAlertController(title: "Info", message: "If you need any help or support, contact me on my website.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)  { _ in
                        })
                    
                        alert.addAction(UIAlertAction(title: "Support", style: UIAlertActionStyle.Default) { _ in
                            UIApplication.sharedApplication().openURL(NSURL(string:"http://tapadventures.com/")!)
                        })
                    
                        // Show the alert
                        self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    // ———————————
    // —- Handle In-App Purchases —-
    // ———————————
    // Open a menu with the available purchases
    func inAppPurchase() {
        let alert = UIAlertController(title: "In App Purchases", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        // Add an alert action for each available product
        for (var i = 0; i < products.count; i++) {
            let currentProduct = products[i]
            if !(currentProduct.productIdentifier == "InAppRemoveAds" && removedAds) {
                // Get the localized price
                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = .CurrencyStyle
                numberFormatter.locale = currentProduct.priceLocale
                // Add the alert action
                alert.addAction(UIAlertAction(title: currentProduct.localizedTitle + " " + numberFormatter.stringFromNumber(currentProduct.price)!, style: UIAlertActionStyle.Default)  { _ in
                    // Perform the purchase
                    self.buyProduct(currentProduct)
                })
            }
        }
        // Offer the restore option only if purchase info is not available
        if(removedAds == false) {
            alert.addAction(UIAlertAction(title: "Restore", style: UIAlertActionStyle.Default)  { _ in
                self.restorePurchasedProducts()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { _ in
        })
        // Show the alert
        self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    // Initialize the App Purchases
    func initInAppPurchases() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        // Get the list of possible purchases
        if self.request == nil {
            self.request = SKProductsRequest(productIdentifiers: Set(["InAppRemoveAds"]))
            self.request.delegate = self
            self.request.start()
        }
    }
    // Request a purchase
    func buyProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    // Restore purchases
    func restorePurchasedProducts() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    // StoreKit protocoll method. Called when the AppStore responds
    func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        self.products = response.products 
        self.request = nil
    }
    // StoreKit protocoll method. Called when an error happens in the communication with the AppStore
    func request(request: SKRequest, didFailWithError error: NSError) {
        print(error)
        self.request = nil
    }
    // StoreKit protocoll method. Called after the purchase
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .Purchased:
                if transaction.payment.productIdentifier == "InAppRemoveAds" {
                    self.handleAdRemoved()
                }
                queue.finishTransaction(transaction)
            case .Restored:
                if transaction.payment.productIdentifier == "InAppRemoveAds" {
                    self.handleAdRemoved()
                }
                queue.finishTransaction(transaction)
            case .Failed:
                print("Payment Error: %@", transaction.error)
                queue.finishTransaction(transaction)
            default:
                print("Transaction State: %@", transaction.transactionState)
            }
        }
    }
    // Called after the purchase to provide the ‘green ship’ feature
    func handleAdRemoved() {
        removedAds = true
        checkAndRemoveAds()
        // persist the purchase locally
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "RemoveAds")
    }
    // Called after applicattion start to check if the ‘green ship’ feature was purchased
    func checkAndRemoveAds() {
        if NSUserDefaults.standardUserDefaults().boolForKey("RemoveAds") {
            removedAds = true
        }
    }
}