//
//  GameViewController.swift
//  deep-search
//
//  Created by Jack Pardungsin on 6/5/16.
//  Copyright (c) 2016 Jack Pardungsin. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .ResizeFill
            
            // Pause the view (and thus the game) when the app is interrupted or backgrounded
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.handleApplicationWillResignActive(_:)), name: UIApplicationWillResignActiveNotification, object: nil)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.handleApplicationDidBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
            
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
