//
//  MenuSettings.swift
//  HitTheBall
//
//  Created by Daniel Peters on 26.10.15.
//  Copyright © 2015 Daniel Peters. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameKit
import StoreKit

class MenuSettings: SKScene, SKPaymentTransactionObserver, SKProductsRequestDelegate  {
    
    //Constant Values
    let Music_Defaults = NSUserDefaults.standardUserDefaults()
    let Sound_Defaults = NSUserDefaults.standardUserDefaults()
    let RemovedAds_Defaults = NSUserDefaults.standardUserDefaults()
    
    //Global Variables
    var request : SKProductsRequest!
    var products : [SKProduct] = [] // List of available purchases
    var removedAds = false
    var Clouds = [SKSpriteNode]()
    var CloudText = ["Music", "Sound", "Remove Ads"]
    var CloudName = ["music_toggle", "sound_toggle", "remove_ads"]
    var Music = Bool()
    var Sound = Bool()
    
    override func didMoveToView(view: SKView) {
        GlobalFunctions().drawBackground(self)
        GlobalFunctions().drawMenuOverlay(self)
        GlobalFunctions().drawGuns(self)
        
        // In-App Purchase
        removedAds = RemovedAds_Defaults.boolForKey("RemoveAds")
        self.initInAppPurchases()
        self.checkAndRemoveAds()
        
        //Check Music Variable
        Music = Music_Defaults.boolForKey("Music")
        Sound = Sound_Defaults.boolForKey("Sound")
        
        //Set CloudText for Music
        if (Music) {
            CloudText[0] = "Music (On)"
        }
        else {
            CloudText[0] = "Music (Off)"
        }
        
        
        if (Sound) {
            CloudText[1] = "Sound (On)"
        }
        else {
            CloudText[1] = "Sound (Off)"
        }
        
        //Add Back Button
        let width = self.size.width
        let height = self.size.height
        let ButtonScale = width*0.15
        
        let BackButton = SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfBackButton(frame: CGRect(x: 0, y: 0, width: ButtonScale, height: ButtonScale))))
        BackButton.position = CGPoint(x: BackButton.size.width*0.75, y: height-BackButton.size.height*0.75)
        BackButton.name = "exit"
        self.addChild(BackButton)
        
        drawCloud()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //Create transitions
        let transition = SKTransition.fadeWithDuration(2.0)
        
        for touch in (touches) {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            node.runAction(SKAction.scaleTo(1.1, duration: NSTimeInterval(0.1))) {
                node.runAction(SKAction.scaleTo(1.0, duration: NSTimeInterval(0.1))) {
                    if (node.name == "music_toggle") {
                        if (self.Music) {
                            self.Music = false
                            self.CloudText[0] = "Music (Off)"
                        }
                        else {
                            self.Music = true
                            self.CloudText[0] = "Music (On)"
                        }
                        self.Music_Defaults.setBool(self.Music, forKey: "Music")
                        
                        //Redraw Clouds
                        for var i=0; i<3; i++ {
                            self.Clouds[i].removeAllActions()
                            self.Clouds[i].removeFromParent()
                            self.Clouds[i].removeAllChildren()
                        }
                        self.Clouds.removeAll()
                        self.drawCloud()
                    }
                    else if (node.name == "sound_toggle") {
                        if (self.Sound) {
                            self.Sound = false
                            self.CloudText[1] = "Sound (Off)"
                        }
                        else {
                            self.Sound = true
                            self.CloudText[1] = "Sound (On)"
                        }
                        self.Sound_Defaults.setBool(self.Sound, forKey: "Sound")
                        
                        //Redraw Clouds
                        for var i=0; i<3; i++ {
                            self.Clouds[i].removeAllActions()
                            self.Clouds[i].removeFromParent()
                            self.Clouds[i].removeAllChildren()
                        }
                        self.Clouds.removeAll()
                        self.drawCloud()
                    }

                    else if (node.name == "remove_ads") {
                        self.inAppPurchase()
                    }
                    else if (node.name == "exit") {
                        //Load Menu
                        let scene = MenuScene(size: self.scene!.size)
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
    
    func drawCloud() {
        
        //Get Res
        let width = self.size.width
        let height = self.size.height
        
        //Draw Clouds
        var CloudPos = [ CGPoint(x: width*0.3, y: height*0.8), CGPoint(x: width*0.7, y: height*0.6), CGPoint(x: width*0.4, y: height*0.4) ]
        for var i=0; i<3; i++ {
            Clouds.append(SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfCloud(frame: CGRect(x: 0, y: 0, width: width/2.5, height: width/5), textInput: CloudText[i], textSize: width*0.033))))
            Clouds[i].position = CloudPos[i]
            Clouds[i].name = CloudName[i]
            self.addChild(Clouds[i])
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
