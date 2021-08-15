//
//  GameScene.swift
//  Fireworks-Night-P20
//
//  Created by Łukasz Nycz on 14/08/2021.
//

import SpriteKit

class GameScene: SKScene {

    var gameTimer: Timer?
    var fireworks: [SKNode]()
    
    var leftEdge = -22
    var bottomEdge = -22
    var rightEdge =  1024 + 22
    var score = 0 {
        didSet {
            
        }
    }
    
    
    override func didMove(to view: SKView) {
 
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameTimer =  Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
}
