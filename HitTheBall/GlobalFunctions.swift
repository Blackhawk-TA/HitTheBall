//
//  GlobalFunctions.swift
//  HitTheBall
//
//  Created by Daniel Peters on 26.10.15.
//  Copyright © 2015 Daniel Peters. All rights reserved.
//

import SpriteKit

public class GlobalFunctions : NSObject {
    
    //Variables
    var isWinter = false
    var SettingsName = "SettingsButton"
    var InfoName = "InfoButton"
    var Guns = [SKSpriteNode]()
    var CurMonth = 0
    
    func setWinterMode() {
        let date = NSDate()
        CurMonth = NSCalendar.currentCalendar().component(.Month, fromDate: date)
        
        if (CurMonth > 11) || (CurMonth > 0 && CurMonth < 3) {
            isWinter = true 
        }
        else {
            isWinter = false
        }
    }
    
    func drawSun(Scene: SKScene) {
        //Get Res
        let width = Scene.size.width
        let height = Scene.size.height
        
        let ambientColor = UIColor.darkGrayColor()
        
        //Draw Sun
        //let lightSprite = SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOf
        //lightSprite.position = CGPointMake(width - 100, height - 100)
        //Scene.addChild(lightSprite);
        
        //Emit Light
        let light = SKLightNode()
        light.position = CGPointMake(0, 0)
        light.falloff = 1
        light.ambientColor = ambientColor
        light.lightColor = UIColor.whiteColor()
        Scene.addChild(light)
        
    }
    
    func drawBackground(Scene: SKScene) {
        
        //Get Res
        let width = Scene.size.width
        let height = Scene.size.height
        
        //Set Background Color
        Scene.backgroundColor = StyleKitName.sky
        
        //Get Winter Value
        setWinterMode()
        
        //Draw Bottom Image
        let Bottom = SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfBottom(frame: CGRect(x: 0, y: 0, width: width, height: height/5.48), isWinter: isWinter)))
        Bottom.position = CGPoint(x: width*0.5, y: Bottom.size.height*0.5)
        Bottom.zPosition = 5.0
        Scene.addChild(Bottom)
        
        //Add Snow
        if (isWinter) {
            let emitterNode = SKEmitterNode(fileNamed: "Snow.sks")
            emitterNode!.particlePosition = CGPointMake(width*0.5, height+50)
            emitterNode!.zPosition = 4.9
            Scene.addChild(emitterNode!)
        }
    }
    
    func drawGuns(Scene: SKScene) {
        
        //Get Res
        let width = Scene.size.width
        let height = Scene.size.height
        
        //Draw Balls Cannons
        var Gun_xPos = [ width*0.2, width*0.5, width*0.8 ]
        for var i=0; i<3; i++ {
            Guns.append(SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfGun(frame: CGRect(x: 0, y: 0, width: width/4.26, height: width/32)))))
            Guns[i].zPosition = 6.0
            Guns[i].position = CGPoint(x: Gun_xPos[i], y: height/5.48 + Guns[i].size.height*0.5)
            Scene.addChild(Guns[i])
        }
    }
    
    func drawMenuOverlay(Scene: SKScene) {
        
        //Get Res
        let width = Scene.size.width
        let height = Scene.size.height
        
        //Scale Button
        let ButtonScale = width*0.15
        
        let InfoButton = SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfMenuIcon(frame: CGRect(x: 0, y: 0, width: ButtonScale, height: ButtonScale), toggleVisibility: false)))
        InfoButton.position = CGPoint(x: width-InfoButton.size.width*0.75, y: height-InfoButton.size.height*0.75)
        InfoButton.name = InfoName
        Scene.addChild(InfoButton)
    }
    
    func drawSmoke(Scene: SKScene, pos: CGPoint, duration: Double) {
        let emitterNode = SKEmitterNode(fileNamed: "Smoke.sks")
        emitterNode!.particlePosition = pos
        emitterNode!.zPosition = 0.0
        Scene.addChild(emitterNode!)
        // Don’t forget to remove the emitter node after the explosion
        Scene.runAction(SKAction.waitForDuration(duration), completion: { emitterNode!.removeFromParent() })
    }
    func drawFire(Scene: SKScene, pos: CGPoint, duration: Double) {
        let emitterNode = SKEmitterNode(fileNamed: "Fire.sks")
        emitterNode!.particlePosition = pos
        emitterNode!.zPosition = 0.0
        Scene.addChild(emitterNode!)
        // Don’t forget to remove the emitter node after the explosion
        Scene.runAction(SKAction.waitForDuration(duration), completion: { emitterNode!.removeFromParent() })
    }
    
    //Format Large Numbers
    func formatNumber(Number: Int) -> String {
        var NumString = String(Number)
        
        if (Number >= 1000) {
            let NumLength = NumString.characters.count
            
            for var i=NumLength; i>3; i=i-3 {
                NumString.insert(",", atIndex: NumString.startIndex.advancedBy(i-3))
            }
        }
        return NumString
    }
}