//
//  GameScene.swift
//  HitTheBall
//
//  Created by Daniel Peters on 15.08.15.
//  Copyright (c) 2015 Daniel Peters. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameKit

class GameScene: SKScene {
    
    //Constant Values
    let Music_Defaults = NSUserDefaults.standardUserDefaults()
    let Sound_Defaults = NSUserDefaults.standardUserDefaults()
    let GameModeValue_Defaults = NSUserDefaults.standardUserDefaults()
    let HighscoreEasy_Defaults = NSUserDefaults.standardUserDefaults()
    let HighscoreHard_Defaults = NSUserDefaults.standardUserDefaults()
    
    //Global Variables
    var Balls = [SKSpriteNode]()
    var GameOverBox = SKSpriteNode()
    var Bottom = SKSpriteNode()
    var RetryButton = SKSpriteNode()
    var ExitButton = SKSpriteNode()
    var PauseButton = SKSpriteNode()
    var ContinueButton = SKSpriteNode()
    var Borders = SKSpriteNode()
    var Clouds = [SKSpriteNode]()
    var Guns = [SKSpriteNode]()
    var lbl_Score = SKLabelNode()
    var lbl_Highscore = SKLabelNode()
    var lbl_ScoreGameOver = SKLabelNode()
    var lbl_HighscoreGameOver = SKLabelNode()
    var lbl_GameOver = SKLabelNode()
    var lbl_Info = SKLabelNode()
    var lbl_Info2 = SKLabelNode()
    var timerStarted = false
    var effects_executed = false
    var BallsTimer: NSTimer?
    var Score = 0
    var Highscore = 0
    var gameRunning = false
    var Pause = false
    var backMusic: AVAudioPlayer!
    var GameMode = Int()
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer:AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("NO AUDIO PLAYER")
        }
        
        return audioPlayer!
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //Get GameModeValue
        GameMode = GameModeValue_Defaults.integerForKey("GameMode")
        
        //Get Highscore
        if (GameMode == 0) {
            Highscore = HighscoreEasy_Defaults.integerForKey("HighscoreEasy")
        }
        else if (GameMode == 1) {
            Highscore = HighscoreHard_Defaults.integerForKey("HighscoreHard")
        }
        
        //Get Res
        let width = self.size.width
        let height = self.size.height
        
        //Play Music
        if (Music_Defaults.boolForKey("Music")) {
            backMusic = setupAudioPlayerWithFile("music_standard", type: "mp3")
            backMusic.play()
        }
        GlobalFunctions().drawBackground(self)
        
        //Enable Gravity
        self.physicsWorld.gravity.dy = -9.81;
        //Draw PauseButton
        PauseButton = SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfPauseButton(frame: CGRect(x: 0, y: 0, width: width/12.8, height: width/9.85), toggleVisibility: false)))
        PauseButton.zPosition = 5.0
        PauseButton.position = CGPoint(x: width-PauseButton.size.width*0.75, y: height-PauseButton.size.height*0.75)
        PauseButton.alpha = 1.0
        PauseButton.name = "PauseButton"
        self.addChild(PauseButton)
        
        //Draw ContinueButton
        ContinueButton = SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfPauseButton(frame: CGRect(x: 0, y: 0, width: width/12.8, height: width/9.85), toggleVisibility: true)))
        ContinueButton.zPosition = 5.0
        ContinueButton.position = CGPoint(x: width-ContinueButton.size.width*0.75, y: height-ContinueButton.size.height*0.75)
        ContinueButton.alpha = 0.0
        ContinueButton.name = "ContinueButton"
        self.addChild(ContinueButton)
        
        //Draw Balls Cannons
        var Gun_xPos = [ width*0.2, width*0.5, width*0.8 ]
        for var i=0; i<3; i++ {
            Guns.append(SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfGun(frame: CGRect(x: 0, y: 0, width: width/4.26, height: width/32)))))
            Guns[i].zPosition = 6.0
            Guns[i].position = CGPoint(x: Gun_xPos[i], y: height/5.48 + Guns[i].size.height*0.5)
            self.addChild(Guns[i])
        }
        
        //Draw Clouds
        var CloudPos = [ CGPoint(x: width*0.3, y: height*0.8), CGPoint(x: width*0.7, y: height*0.6), CGPoint(x: width*0.4, y: height*0.4) ]
        for var i=0; i<3; i++ {
            Clouds.append(SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfCloud(frame: CGRect(x: 0, y: 0, width: width/2.5, height: width/5), textInput: "", textSize: 1))))
            Clouds[i].position = CloudPos[i]
            self.addChild(Clouds[i])
        }
        
        //GameOverBox
        GameOverBox = SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfBox(frame: CGRect(x: 0, y: 0, width: width*0.75, height: height*0.25))))
        GameOverBox.zPosition = 10.0
        GameOverBox.position = CGPoint(x: width*0.5, y: height*0.5)
        GameOverBox.alpha = 0.0
        self.addChild(GameOverBox)
        
        //Retry Button
        RetryButton = SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfButton(frame: CGRect(x: 0, y: 0, width: GameOverBox.size.width*0.4, height: GameOverBox.size.height*0.25), textInput: "Retry", textSize: width*0.05)))
        RetryButton.name = "Retry_Button"
        RetryButton.zPosition = 11.0
        RetryButton.position = CGPoint(x: GameOverBox.position.x + GameOverBox.size.width*0.25, y: GameOverBox.position.y - GameOverBox.size.height*0.3)
        RetryButton.alpha = 0.0
        self.addChild(RetryButton)
        
        //Exit Button
        ExitButton = SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfButton(frame: CGRect(x: 0, y: 0, width: GameOverBox.size.width*0.4, height: GameOverBox.size.height*0.25), textInput: "Exit", textSize: width*0.05)))
        ExitButton.name = "Exit_Button"
        ExitButton.zPosition = 11.0
        ExitButton.position = CGPoint(x: GameOverBox.position.x - GameOverBox.size.width*0.25 , y: GameOverBox.position.y - GameOverBox.size.height*0.3)
        ExitButton.alpha = 0.0
        self.addChild(ExitButton)
        
        //Draw Score
        lbl_Score = SKLabelNode(fontNamed:"Chalkduster")
        lbl_Score.text = "Score: " + GlobalFunctions().formatNumber(Score)
        lbl_Score.fontSize = width*0.05
        lbl_Score.fontColor = UIColor(white: 0.0, alpha: 1.0)
        lbl_Score.position = CGPoint(x: width*0.5, y: height-PauseButton.size.height*0.5);
        self.addChild(lbl_Score)
        
        //Draw Highscore
        lbl_Highscore = SKLabelNode(fontNamed:"Chalkduster")
        lbl_Highscore.text = "Highscore: " + GlobalFunctions().formatNumber(Highscore)
        lbl_Highscore.fontSize = width*0.05
        lbl_Highscore.fontColor = UIColor(white: 0.0, alpha: 1.0)
        lbl_Highscore.position = CGPoint(x: width*0.5, y: height-PauseButton.size.height*1.2);
        self.addChild(lbl_Highscore)
        
        //Draw Start Info
        lbl_Info = SKLabelNode(fontNamed:"Chalkduster")
        lbl_Info.text = "Tap to start"
        lbl_Info.fontSize = width*0.075
        lbl_Info.fontColor = UIColor(white: 0.0, alpha: 1.0)
        lbl_Info.position = CGPoint(x: width*0.5, y: height*0.5);
        self.addChild(lbl_Info)
        
        
        //Draw Start Info
        lbl_Info2 = SKLabelNode(fontNamed:"Chalkduster")
        if (GameMode == 0) {
            lbl_Info2.text = ""
        }
        else {
            lbl_Info2.text = "Don't hit the black balls!"
        }
        lbl_Info2.fontSize = width*0.05
        lbl_Info2.fontColor = UIColor(white: 0.0, alpha: 1.0)
        lbl_Info2.position = CGPoint(x: width*0.5, y: height*0.5 - width*0.1);
        lbl_Info2.zPosition = 5.0
        self.addChild(lbl_Info2)
        
        //GameOver Label
        lbl_GameOver = SKLabelNode(fontNamed:"Chalkduster")
        lbl_GameOver.text = "Game Over!"
        lbl_GameOver.fontSize = width*0.065
        lbl_GameOver.fontColor = UIColor(white: 0.0, alpha: 1.0)
        lbl_GameOver.zPosition = 11.0
        lbl_GameOver.position = CGPoint(x: GameOverBox.position.x, y: GameOverBox.position.y + GameOverBox.size.width*0.13)
        lbl_GameOver.alpha = 0.0
        self.addChild(lbl_GameOver)
        
        //GameOver Label
        lbl_ScoreGameOver = SKLabelNode(fontNamed:"Chalkduster")
        lbl_ScoreGameOver.text = "Score: " + GlobalFunctions().formatNumber(Score)
        lbl_ScoreGameOver.fontSize = width*0.05
        lbl_ScoreGameOver.fontColor = UIColor(white: 0.0, alpha: 1.0)
        lbl_ScoreGameOver.zPosition = 11.0
        lbl_ScoreGameOver.position = CGPoint(x: GameOverBox.position.x, y: GameOverBox.position.y + GameOverBox.size.height*0.075)
        lbl_ScoreGameOver.alpha = 0.0
        self.addChild(lbl_ScoreGameOver)
        
        lbl_HighscoreGameOver = SKLabelNode(fontNamed:"Chalkduster")
        lbl_HighscoreGameOver.text = "Highscore: " + GlobalFunctions().formatNumber(Highscore)
        lbl_HighscoreGameOver.fontSize = width*0.05
        lbl_HighscoreGameOver.fontColor = UIColor(white: 0.0, alpha: 1.0)
        lbl_HighscoreGameOver.zPosition = 11.0
        lbl_HighscoreGameOver.position = CGPoint(x: GameOverBox.position.x, y: GameOverBox.position.y - GameOverBox.size.height*0.075)
        lbl_HighscoreGameOver.alpha = 0.0
        self.addChild(lbl_HighscoreGameOver)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        //Create transitions
        let transition = SKTransition.fadeWithDuration(2.0)
        
        //Touch buttons
        for touch in (touches) {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            //Check if clicked on field
            if (location.y > Bottom.size.height) {
                
                //Start Timer
                if (timerStarted == false && gameRunning == false) {
                    //Remove Info
                    lbl_Info.alpha = 0.0
                    lbl_Info2.alpha = 0.0
                    
                    var timerDur = Double()
                    if (GameMode) == 0 {
                        timerDur = 1.0
                    }
                    else {
                        timerDur = 0.75
                    }
                
                    BallsTimer = NSTimer.scheduledTimerWithTimeInterval(timerDur, target: self, selector: "shootBalls:", userInfo: nil, repeats: true)
                    timerStarted = true
                    gameRunning = true
                }
            
                for (var i=0; i<Balls.count; i++) {
                    if (node == self.Balls[i] && Pause == false) {
                        //Effect
                        explosion(Balls[i].position)
                        Balls[i].removeAllActions()
                        Balls[i].removeAllChildren()
                        Balls[i].removeFromParent()
                        
                        
                        if (Balls[i].name == "normal") {
                            Score++
                            lbl_Score.text = "Score: " + GlobalFunctions().formatNumber(Score)
                    
                            if (Score >= Highscore) {
                                lbl_Highscore.text = "New Highscore!"
                                Highscore = Score
                            }
                        }
                        else if (Balls[i].name == "bomb") {
                            gameOver()
                        }
                    }
                }
                
                if ((node.name == PauseButton.name || node.name == ContinueButton.name && PauseButton.alpha == 1.0) && gameRunning == true) {
                    PauseButton.alpha = 0.0
                    ContinueButton.alpha = 1.0
                    
                    //Pause Scene
                    Pause = true
                    physicsWorld.speed = 0.0
                    BallsTimer!.invalidate()
                    BallsTimer = nil
                }
                else if ((node.name == ContinueButton.name || node.name == PauseButton.name && ContinueButton.alpha == 1.0) && gameRunning == true) {
                    PauseButton.alpha = 1.0
                    ContinueButton.alpha = 0.0
                    
                    //Continue Scene
                    Pause = false
                    physicsWorld.speed = 1.0
                    BallsTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "shootBalls:", userInfo: nil, repeats: true)
                }
                else if (node.name == RetryButton.name) {
                    resetGame()
                }
                else if (node.name == ExitButton.name) {
                    
                    //Load Menu
                    let scene = MenuScene(size: self.scene!.size)
                    scene.scaleMode = SKSceneScaleMode.AspectFill
                    self.scene!.view!.presentScene(scene, transition: transition)
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        //Get Res
        let width = self.size.width
        let height = self.size.height
        
        //GameOver Bedingung
        if (gameRunning == true) {
            for (var i=0; i<Balls.count; i++) {
                if (Balls[i].name == "normal") {
                    if (Balls[i].position.y > height + Balls[i].size.height*0.5) {
                        gameOver()
                    }
                    else if (Balls[i].position.x < 0 && Balls[i].position.y < Bottom.size.height) {
                        gameOver()
                    }
                    else if (Balls[i].position.x > width && Balls[i].position.y < Bottom.size.height) {
                        gameOver()
                    }
                    else if (Balls[i].position.y <= 0) {
                        gameOver()
                    }
                }
            }
        }
        
        //Check Music loop
        if (Music_Defaults.boolForKey("Music")) {
            if (backMusic.playing == false) {
                backMusic.play()
            }
        }
    }
    
    override func willMoveFromView(view: SKView) {
        //Save Highscore
        if (GameMode == 0) {
            HighscoreEasy_Defaults.setInteger(Highscore, forKey: "HighscoreEasy")
        }
        else if (GameMode == 1) {
            HighscoreHard_Defaults.setInteger(Highscore, forKey: "HighscoreHard")
        }
        else {
            print("ERROR NO GAMEMODE FOUND")
        }
    }
    
    func shootBalls(timer:NSTimer!) {
        //Get Res
        let width = self.size.width
        let height = self.size.height
        
        var randColor = UInt32()
        let randPos = arc4random_uniform(3)
        let randGold = arc4random_uniform(100000) + 1
        let randVecNegX = arc4random_uniform(2)
        let randVecX = arc4random_uniform(UInt32(height/64)) + 1
        let randVecY = arc4random_uniform(UInt32(height/32)) + 1
        var BallsVectorX = CGFloat()
        var BallsVectorY = CGFloat()
        var golden = false
        var BallsPos = CGPoint()
        
        //Check GameMode and apply changes
        if (GameMode == 0) {
            randColor = arc4random_uniform(4)
        }
        else {
            randColor = arc4random_uniform(5)
        }
        
        //Check if Ball is golden
        if (randGold == 1) {
            golden = true
        }
        
        //Set X apply Force Vector
        if (randVecNegX == 0) {
            BallsVectorX = CGFloat(randVecX) * -1
        }
        
        //Set Y apply Force Vector
        BallsVectorY = CGFloat(randVecY) + (height*0.085)
        
        //Set Ball position
        if (randPos == 0) {
            BallsPos = CGPoint(x: width*0.2, y: Guns[0].position.y - width/6.4)
        }
        else if (randPos == 1) {
            BallsPos = CGPoint(x: width*0.5, y: Guns[0].position.y - width/6.4)
        }
        else if (randPos == 2) {
            BallsPos = CGPoint(x: width*0.8, y: Guns[0].position.y - width/6.4)
        }
        
        //Draw Balls
        Balls.append(SKSpriteNode(texture: SKTexture(image: StyleKitName.imageOfBall(frame: CGRect(x: 0, y: 0, width: width/6.4, height: width/6.4), golden: golden, colorInput: CGFloat(randColor)))))
        Balls[Balls.count-1].position = BallsPos
        Balls[Balls.count-1].physicsBody = SKPhysicsBody(circleOfRadius: Balls[Balls.count-1].size.width*0.5)
        Balls[Balls.count-1].physicsBody?.mass = 0.05
        Balls[Balls.count-1].zPosition = 1.0
        Balls[Balls.count-1].physicsBody?.affectedByGravity = true
        Balls[Balls.count-1].physicsBody?.dynamic = true
        
        if (randColor == 4) {
            Balls[Balls.count-1].name = "bomb"
        }
        else {
            Balls[Balls.count-1].name = "normal"
        }
        self.addChild(Balls[Balls.count-1])
        
        //Shoot Balls
        Balls[Balls.count-1].physicsBody?.applyImpulse(CGVector(dx: BallsVectorX, dy: BallsVectorY))
        
        //Add Animation at Cannon
        GlobalFunctions().drawFire(self, pos:Guns[Int(randPos)].position, duration:1.0)
        GlobalFunctions().drawSmoke(self, pos:Guns[Int(randPos)].position, duration:0.5)
        
        //Ball Shot Sound
        if (Sound_Defaults.boolForKey("Sound")) {
            runAction(SKAction.playSoundFileNamed("Ball_Shot.wav", waitForCompletion: false))
        }
    }
    
    func gameOver() {
        //Remove Balls
        for (var i=0; i<Balls.count; i++) {
            Balls[i].removeAllChildren()
            Balls[i].removeAllActions()
            Balls[i].removeFromParent()
            Balls.removeAll(keepCapacity: false)
        }
        
        BallsTimer!.invalidate()
        BallsTimer = nil
        gameRunning = false
        
        //Change Alpha
        GameOverBox.alpha = 1.0
        RetryButton.alpha = 1.0
        ExitButton.alpha = 1.0
        lbl_ScoreGameOver.alpha = 1.0
        lbl_HighscoreGameOver.alpha = 1.0
        lbl_GameOver.alpha = 1.0
        lbl_Info.alpha = 1.0
        lbl_Info2.alpha = 1.0
        
        //Update Text
        lbl_ScoreGameOver.text = "Score: " + GlobalFunctions().formatNumber(Score)
        
        if (Score >= Highscore) {
            lbl_HighscoreGameOver.text = "New Highscore!"
            
            //Save Highscore
            if (GameMode == 0) {
                HighscoreEasy_Defaults.setInteger(Highscore, forKey: "HighscoreEasy")
            }
            else if (GameMode == 1) {
                HighscoreHard_Defaults.setInteger(Highscore, forKey: "HighscoreHard")
            }
            else {
                print("ERROR NO GAMEMODE FOUND")
            }
            
            //Save Highscore to GameCenter
            saveHighscore(Highscore)
        }
        else {
            lbl_HighscoreGameOver.text = "Highscore: " + GlobalFunctions().formatNumber(Highscore)
        }
        
        //Show Ads
        let showAds = arc4random_uniform(10) + 1
        if (showAds == 5) {
            
        }
    }
    
    func resetGame() {
        //Change Alpha
        GameOverBox.alpha = 0.0
        RetryButton.alpha = 0.0
        ExitButton.alpha = 0.0
        lbl_ScoreGameOver.alpha = 0.0
        lbl_HighscoreGameOver.alpha = 0.0
        lbl_GameOver.alpha = 0.0
        
        //Reset Score
        Score = 0
        lbl_Score.text = "Score: " + GlobalFunctions().formatNumber(Score)
        lbl_Highscore.text = "Highscore: " + GlobalFunctions().formatNumber(Highscore)
        
        //reset Timer variable
        timerStarted = false
    }
    
    // if player is logged in to GC, then report the score
    func saveHighscore(score:Int) {
        if GKLocalPlayer.localPlayer().authenticated {
            var gkScore = GKScore()
            print("GameMode: " + String(GameMode))
            if (GameMode == 0) {
                gkScore = GKScore(leaderboardIdentifier: "HTB_Highscores_DPAPPDEV97")
            }
            else if (GameMode == 1) {
                gkScore = GKScore(leaderboardIdentifier: "HTB_Highscores_Hard_DPAPPDEV97")
            }
            else {
                print("No GameMode")
            }
            gkScore.value = Int64(score)
            GKScore.reportScores([gkScore], withCompletionHandler: ( { (error: NSError?) -> Void in
                if (error != nil) {
                    // handle error
                    print("Error: " + error!.localizedDescription);
                } else {
                    print("Score reported: \(gkScore.value)")
                }
            }))
        }
    }
    
    //Explosion Effect
    func explosion(pos: CGPoint) {
        let emitterNode = SKEmitterNode(fileNamed: "Explosion.sks")
        emitterNode!.particlePosition = pos
        emitterNode!.zPosition = 10.0
        self.addChild(emitterNode!)
        // Don’t forget to remove the emitter node after the explosion
        self.runAction(SKAction.waitForDuration(0.5), completion: { emitterNode!.removeFromParent() })
    }
}
