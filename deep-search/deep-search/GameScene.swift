//
//  GameScene.swift
//  deep-search
//
//  Created by Jack Pardungsin on 6/5/16.
//  Copyright (c) 2016 Jack Pardungsin. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    var contentCreated = false
    
    enum FishType {
        case A
        case B
        case C
        
        static var size: CGSize {
            return CGSize(width: 19, height: 30)
        }
        
        static var name: String {
            return "fish"
        }
    }
        
    let kFishGridSpacing = CGSize(width: 19, height: 30)
    let kFishRowCount = 1
    let kFishColCount = 1
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
            //motionManager.startAccelerometerUpdates()
        }
        
        //physicsWorld.contactDelegate = self
    }
    
    func createContent() {
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        //physicsBody!.categoryBitMask = kSceneEdgeCategory
        
        setupFish()
        //setupShip()
        //setupHud()
        
        // black space color
        self.backgroundColor = SKColor.blackColor()
    }
    
    func makeFishOfType(fishType: FishType) -> SKNode {
        // 1
        var fishColor: SKColor
        
        switch(fishType) {
        case .A:
            fishColor = SKColor.redColor()
        case .B:
            fishColor = SKColor.greenColor()
        case .C:
            fishColor = SKColor.blueColor()
        }
        
        // 2
        let fish = SKSpriteNode(color: fishColor, size: FishType.size)
        fish.name = FishType.name
        
        return fish
    }
    
    func setupFish() {
        
        // 1
        let baseOrigin = CGPoint(x: size.width / 3, y: size.height / 2)
        
        for row in 0..<kFishRowCount {
            
            // 2
            var fishType: FishType
            
            if row % 3 == 0 {
                fishType = .A
            } else if row % 3 == 1 {
                fishType = .B
            } else {
                fishType = .C
            }
            
            // 3
            let fishPositionY = CGFloat(row) * (FishType.size.height * 2) + baseOrigin.y
            
            var fishPosition = CGPoint(x: baseOrigin.x, y: fishPositionY)
            
            // 4
            for _ in 0..<kFishColCount {
                
                // 5
                let fish = makeFishOfType(fishType)
                fish.position = fishPosition
                
                addChild(fish)
                
                fishPosition = CGPoint(
                    x: fishPosition.x + FishType.size.width + kFishGridSpacing.width,
                    y: fishPositionY
                )
            }
        }
    }
    
    /*override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }*/
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
