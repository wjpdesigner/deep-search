//
//  GameScene.swift
//  deep-search
//
//  Created by Jack Pardungsin on 6/5/16.
//  Copyright (c) 2016 Jack Pardungsin. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    var contentCreated = false
    
    var fishMovementDirection: FishMovementDirection = .Right
    var timeOfLastMove: CFTimeInterval = 0.0
    let timePerMove: CFTimeInterval = 1.0
    
    enum FishMovementDirection {
        case Right
        case Left
        case DownThenRight
        case DownThenLeft
        case None
    }
    
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
    
    enum BulletType {
        case SubmarineFired
        case FishFired
    }
    
    let kFishGridSpacing = CGSize(width: 19, height: 30)
    let kFishRowCount = 6
    let kFishColCount = 6
    
    let kSubmarineSize = CGSize(width: 21, height: 43)
    let kSubmarineName = "submarine"
    
    let kSubmarineFiredBulletName = "submarineFiredBullet"
    let kFishFiredBulletName = "fishFiredBullet"
    let kBulletSize = CGSize(width:4, height: 8)
    
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    
    var tapQueue = [Int]()
    var contactQueue = [SKPhysicsContact]()
    
    var score: Int = 0
    var submarineHealth: Float = 1.0
    
    let kFishCategory: UInt32 = 0x1 << 0
    let kSubmarineFiredBulletCategory: UInt32 = 0x1 << 1
    let kSubmarineCategory: UInt32 = 0x1 << 2
    let kSceneEdgeCategory: UInt32 = 0x1 << 3
    let kFishFiredBulletCategory: UInt32 = 0x1 << 4
    
    override func didMoveToView(view: SKView) {
        
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
            motionManager.startAccelerometerUpdates()
        }
        
        physicsWorld.contactDelegate = self
    }
    
    func createContent() {
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        physicsBody!.categoryBitMask = kSceneEdgeCategory
        
        setupFish()
        setupSubmarine()
        setupHud()
        
        // black space color
        self.backgroundColor = SKColor.blackColor()
    }
    
    // Scene Setup and Content Creation
    
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
        
        fish.physicsBody = SKPhysicsBody(rectangleOfSize: fish.frame.size)
        fish.physicsBody!.dynamic = false
        fish.physicsBody!.categoryBitMask = kFishCategory
        fish.physicsBody!.contactTestBitMask = 0x0
        fish.physicsBody!.collisionBitMask = 0x0
        
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
            for _ in 1..<kFishColCount {
                
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
    
    func setupSubmarine() {
        let submarine = makeSubmarine()
        
        submarine.position = CGPoint(x: size.width / 2.0, y: kSubmarineSize.height / 2.0)
        addChild(submarine)
    }
    
    func makeSubmarine() -> SKNode {
        let submarine = SKSpriteNode(color: SKColor.greenColor(), size: kSubmarineSize)
        submarine.name = kSubmarineName
        
        // 1
        submarine.physicsBody = SKPhysicsBody(rectangleOfSize: submarine.frame.size)
        
        // 2
        submarine.physicsBody!.dynamic = true
        
        // 3
        submarine.physicsBody!.affectedByGravity = false
        
        // 4
        submarine.physicsBody!.mass = 0.02
        
        // 1
        submarine.physicsBody!.categoryBitMask = kSubmarineCategory
        // 2
        submarine.physicsBody!.contactTestBitMask = 0x0
        // 3
        submarine.physicsBody!.collisionBitMask = kSceneEdgeCategory
        
        return submarine
    }
    
    func setupHud() {
        // 1
        let scoreLabel = SKLabelNode(fontNamed: "SilkscreenNormal")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        
        // 2
        scoreLabel.fontColor = SKColor.greenColor()
        scoreLabel.text = String(format: "%04u", 0)
        
        // 3
        scoreLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (40 + scoreLabel.frame.size.height/2)
        )
        addChild(scoreLabel)
        
        // 4
        let healthLabel = SKLabelNode(fontNamed: "SilkscreenNormal")
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        
        // 5
        healthLabel.fontColor = SKColor.redColor()
        healthLabel.text = String(format: "+++", submarineHealth * 100.0)
        
        // 6
        healthLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (80 + healthLabel.frame.size.height/2)
        )
        addChild(healthLabel)
    }
    
    func adjustScoreBy(points: Int) {
        score += points
        
        if let score = childNodeWithName(kScoreHudName) as? SKLabelNode {
            score.text = String(format: "%04u", self.score)
        }
    }
    
    func adjustShipHealthBy(healthAdjustment: Float) {
        // 1
        submarineHealth = max(submarineHealth + healthAdjustment, 0)
        
        if let health = childNodeWithName(kHealthHudName) as? SKLabelNode {
            
            if (submarineHealth * 100 <= 66.6) {
                health.text = String(format: "++x", self.submarineHealth * 100)
            }
            if (submarineHealth * 100 <= 33.2) {
                health.text = String(format: "+xx", self.submarineHealth * 100)
            }
            if (submarineHealth * 100 <= 0.0){
                health.text = String(format: "xxx", self.submarineHealth * 100)
            }
        }
    }
    
    func makeBulletOfType(bulletType: BulletType) -> SKNode {
        var bullet: SKNode
        
        switch bulletType {
            
        case .SubmarineFired:
            bullet = SKSpriteNode(color: SKColor.greenColor(), size: kBulletSize)
            bullet.name = kSubmarineFiredBulletName
            
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
            bullet.physicsBody!.dynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kSubmarineFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kFishCategory
            bullet.physicsBody!.collisionBitMask = 0x0
            
        case .FishFired:
            bullet = SKSpriteNode(color: SKColor.magentaColor(), size: kBulletSize)
            bullet.name = kFishFiredBulletName
            
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
            bullet.physicsBody!.dynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kFishFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kSubmarineCategory
            bullet.physicsBody!.collisionBitMask = 0x0
            
            break
        }
        
        return bullet
    }
   
    // Scene Updates
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        processContactsForUpdate(currentTime)
        processUserMotionForUpdate(currentTime)
        moveFishForUpdate(currentTime)
        processUserTapsForUpdate(currentTime)
        fireFishBulletsForUpdate(currentTime)
    }
    
    func moveFishForUpdate(currentTime: CFTimeInterval) {
        // 1
        if (currentTime - timeOfLastMove < timePerMove) {
            return
        }
        
        determineFishMovementDirection()
        
        // 2
        enumerateChildNodesWithName(FishType.name) {
            node, stop in
            
            switch self.fishMovementDirection {
            case .Right:
                node.position = CGPointMake(node.position.x + 10, node.position.y)
            case .Left:
                node.position = CGPointMake(node.position.x - 10, node.position.y)
            case .DownThenLeft, .DownThenRight:
                node.position = CGPointMake(node.position.x, node.position.y - 10)
            case .None:
                break
            }
            
            // 3
            self.timeOfLastMove = currentTime
        }
    }
    
    func processUserMotionForUpdate(currentTime: CFTimeInterval) {
        // 1
        if let submarine = childNodeWithName(kSubmarineName) as? SKSpriteNode {
            // 2
            if let data = motionManager.accelerometerData {
                // 3
                if fabs(data.acceleration.x) > 0.2 {
                    // 4 How do you move the ship?
                    submarine.physicsBody!.applyForce(CGVectorMake(40.0 * CGFloat(data.acceleration.x), 0))
                }
            }
        }
    }
    
    func fireFishBulletsForUpdate(currentTime: CFTimeInterval) {
        let existingBullet = childNodeWithName(kFishFiredBulletName)
        
        // 1
        if existingBullet == nil {
            var allFish = Array<SKNode>()
            
            // 2
            enumerateChildNodesWithName(FishType.name) {
                node, stop in
                
                allFish.append(node)
            }
            
            if allFish.count > 0 {
                // 3
                let allFishIndex = Int(arc4random_uniform(UInt32(allFish.count)))
                
                let fish = allFish[allFishIndex]
                
                // 4
                let bullet = makeBulletOfType(.FishFired)
                bullet.position = CGPoint(
                    x: fish.position.x,
                    y: fish.position.y - fish.frame.size.height / 2 + bullet.frame.size.height / 2
                )
                
                // 5
                let bulletDestination = CGPoint(x: fish.position.x, y: -(bullet.frame.size.height / 2))
                
                // 6
                fireBullet(bullet, toDestination: bulletDestination, withDuration: 2.0, andSoundFileName: "FishBullet.wav")
            }
        }
    }
    
    func processContactsForUpdate(currentTime: CFTimeInterval) {
        for contact in contactQueue {
            handleContact(contact)
            
            if let index = contactQueue.indexOf(contact) {
                contactQueue.removeAtIndex(index)
            }
        }
    }
    
    // Scene Update Helpers
    
    func determineFishMovementDirection() {
        // 1
        var proposedMovementDirection: FishMovementDirection = fishMovementDirection
        
        // 2
        enumerateChildNodesWithName(FishType.name) {
            node, stop in
            
            switch self.fishMovementDirection {
            case .Right:
                //3
                if (CGRectGetMaxX(node.frame) >= node.scene!.size.width - 1.0) {
                    proposedMovementDirection = .DownThenLeft
                    
                    stop.memory = true
                }
            case .Left:
                //4
                if (CGRectGetMinX(node.frame) <= 1.0) {
                    proposedMovementDirection = .DownThenRight
                    
                    stop.memory = true
                }
                
            case .DownThenLeft:
                proposedMovementDirection = .Left
                
                stop.memory = true
                
            case .DownThenRight:
                proposedMovementDirection = .Right
                
                stop.memory = true
                
            default:
                break
            }
            
        }
        
        //7
        if (proposedMovementDirection != fishMovementDirection) {
            fishMovementDirection = proposedMovementDirection
        }
    }
    
    func processUserTapsForUpdate(currentTime: CFTimeInterval) {
        // 1
        for tapCount in tapQueue {
            if tapCount == 1 {
                // 2
                fireSubmarineBullets()
            }
            // 3
            tapQueue.removeAtIndex(0)
        }
    }
    
    // Interactive Helpers
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if (touch.tapCount == 1) {
                tapQueue.append(1)
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        contactQueue.append(contact)
    }
    
    func handleContact(contact: SKPhysicsContact) {
        // Ensure you haven't already handled this contact and removed its nodes
        if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
            return
        }
        
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        
        if nodeNames.contains(kSubmarineName) && nodeNames.contains(kFishFiredBulletName) {
            // Fish bullet hit a submarine
            runAction(SKAction.playSoundFileNamed("SubmarineHit.wav", waitForCompletion: false))
            
            // 1
            adjustShipHealthBy(-0.334)
            
            if submarineHealth <= 0.0 {
                // 2
                contact.bodyA.node!.removeFromParent()
                contact.bodyB.node!.removeFromParent()
            } else {
                // 3
                if let ship = self.childNodeWithName(kSubmarineName) {
                    ship.alpha = CGFloat(submarineHealth)
                    
                    if contact.bodyA.node == ship {
                        contact.bodyB.node!.removeFromParent()
                        
                    } else {
                        contact.bodyA.node!.removeFromParent()
                    }
                }
            }
            
        } else if nodeNames.contains(FishType.name) && nodeNames.contains(kSubmarineFiredBulletName) {
            // Submarine bullet hit a fish
            runAction(SKAction.playSoundFileNamed("FishHit.wav", waitForCompletion: false))
            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            
            // 4
            adjustScoreBy(100)
        }
    }
    
    func fireBullet(bullet: SKNode, toDestination destination: CGPoint, withDuration duration: CFTimeInterval, andSoundFileName soundName: String) {
        // 1
        let bulletAction = SKAction.sequence([
            SKAction.moveTo(destination, duration: duration),
            SKAction.waitForDuration(3.0 / 60.0), SKAction.removeFromParent()
            ])
        
        // 2
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        // 3
        bullet.runAction(SKAction.group([bulletAction, soundAction]))
        
        // 4
        addChild(bullet)
    }
    
    func fireSubmarineBullets() {
        let existingBullet = childNodeWithName(kSubmarineFiredBulletName)
        
        // 1
        if existingBullet == nil {
            if let submarine = childNodeWithName(kSubmarineName) {
                let bullet = makeBulletOfType(.SubmarineFired)
                // 2
                bullet.position = CGPoint(
                    x: submarine.position.x,
                    y: submarine.position.y + submarine.frame.size.height - bullet.frame.size.height / 2
                )
                // 3
                let bulletDestination = CGPoint(
                    x: submarine.position.x,
                    y: frame.size.height + bullet.frame.size.height / 2
                )
                // 4
                fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "SubmarineBullet.wav")
            }
        }
    }

    
}
