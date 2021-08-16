//
//  GameScene.swift
//  Fireworks-Night-P20
//
//  Created by Łukasz Nycz on 14/08/2021.
//

import SpriteKit

class GameScene: SKScene {
    
    var scoreLabel: SKLabelNode!
    var launchesLabel: SKLabelNode!

    var gameTimer: Timer?
    var fireworks = [SKNode]()
    
    var leftEdge = -22
    var bottomEdge = -22
    var rightEdge =  1024 + 22
    var score = 0 {
        didSet {
            scoreLabel?.text = "Score: \(score)"
        }
    }
    var rocketLeft = 0 {
        didSet {
            launchesLabel.text = "Launches left: \(rocketLeft)"
        }
    }

    
    
    override func didMove(to view: SKView) {
 
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameTimer =  Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        launchesLabel = SKLabelNode(fontNamed: "Chalkduster")
        launchesLabel.position = CGPoint(x: 16, y: 60)
        launchesLabel.horizontalAlignmentMode = .left
        addChild(launchesLabel)
        
        rocketLeft = 6
    }
    
    @objc func createFireworks(xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        default:
            firework.color = .red
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        
        node.run(SKAction.sequence([move,
                                    SKAction.wait(forDuration: 3),
                                    SKAction.removeFromParent()]))
        
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        fireworks.append(node)
        addChild(node)

    }
    @objc func launchFireworks() {
        
        rocketLeft -= 1
        
        if rocketLeft == 0 {
            gameTimer?.invalidate()
        }
        let movement : CGFloat = 1800
        
        switch Int.random(in: 0...3) {
        case 0:
            createFireworks(xMovement: 0, x: 512, y: bottomEdge)
            createFireworks(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFireworks(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFireworks(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFireworks(xMovement: 0, x: 512 + 200, y: bottomEdge)

        case 1:
            createFireworks(xMovement: 0, x: 512, y: bottomEdge)
            createFireworks(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFireworks(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFireworks(xMovement: 100, x: 512 + 200, y: bottomEdge)
            createFireworks(xMovement: 200, x: 512 + 100, y: bottomEdge)
        case 2:
            createFireworks(xMovement: movement, x: leftEdge, y: bottomEdge)
            createFireworks(xMovement: movement, x: leftEdge, y: bottomEdge + 400)
            createFireworks(xMovement: movement, x: leftEdge, y: bottomEdge + 300)
            createFireworks(xMovement: movement, x: leftEdge, y: bottomEdge + 200)
            createFireworks(xMovement: movement, x: leftEdge, y: bottomEdge + 100)
        case 3:
            createFireworks(xMovement: -movement, x: rightEdge, y: bottomEdge)
            createFireworks(xMovement: -movement, x: rightEdge, y: bottomEdge + 400)
            createFireworks(xMovement: -movement, x: rightEdge, y: bottomEdge + 300)
            createFireworks(xMovement: -movement, x: rightEdge, y: bottomEdge + 200)
            createFireworks(xMovement: -movement, x: rightEdge, y: bottomEdge + 100)
        default:
            break
        }
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint  {
            guard node.name == "firework" else { continue }
            
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else {continue}
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
        }
        firework.removeFromParent()
    }
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue}
            
            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        switch  numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
            rocketLeft += 1
        case 4:
            score += 2500
            rocketLeft += 2
        case 5:
            score += 4000
            rocketLeft += 3
        default:
            break
        }
    }
}
