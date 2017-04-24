//
//  GameScene.swift
//  ZombieConga
//
//  Created by Michael Radzwilla on 3/27/17.
//  Copyright © 2017 hackingwithswift. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let zombieMovePointsPerSec: CGFloat = 600.0
    let zombieAnimation: SKAction
    let backgroundMovePointsPerSec: CGFloat = 200.0
    let backgroundLayer = SKNode()
    
    var lastTouchedLocation = CGPoint(x:0,y:0)
    var isZombieInvincible = false
    var lives = 5
    var gameOver = false
    
    let catMovePointsPerSec: CGFloat = 480.0
    
    let playableRect: CGRect
    
    var velocity = CGPoint(x:0,y:0)
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed( "hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed( "hitCatLady.wav", waitForCompletion: false)
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight)
        
        var textures:[SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.repeatForever( SKAction.animate(with: textures, timePerFrame: 0.1))
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") // 6
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = location - zombie.position
        
        let length = sqrt(
            Double(offset.x * offset.x + offset.y * offset.y)
        )
        
        let direction = offset/CGFloat(length)
        velocity = direction * zombieMovePointsPerSec
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zRotation = direction.angle
    }
    
    func boundsCheckZombie() {
        let bottomLeft = backgroundLayer.convert(
            CGPoint(x: 0, y: playableRect.minY), from: self)
        let topRight = backgroundLayer.convert(
            CGPoint(x: size.width, y: playableRect.maxY), from: self)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y }
    }
    
    func startZombieAnimation() {
        if zombie.action(forKey: "animation") == nil {
            zombie.run(
                zombieAnimation,
                withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeAction(forKey: "animation")
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        let enemyScenePos = CGPoint(x: size.width + enemy.size.width / 2.0, y: CGFloat.random(min: playableRect.minY + enemy.size.height / 2.0, max: playableRect.maxY - enemy.size.height / 2.0))

        enemy.position = backgroundLayer.convert(enemyScenePos, from: self)

        enemy.name = "enemy"
        backgroundLayer.addChild(enemy)
        let enemySceneDestination = CGPoint(x: -enemy.size.width/2, y: enemy.position.y)
        let enemyDestination = backgroundLayer.convert(enemySceneDestination, from: self)
        let actionMove = SKAction.moveTo(x: enemyDestination.x, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchedLocation = touchLocation
        moveZombieToward(location: touchLocation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchLocation = touch.location(in: backgroundLayer)
            sceneTouched(touchLocation: touchLocation)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchLocation = touch.location(in: backgroundLayer)
            sceneTouched(touchLocation: touchLocation)
        }
    }
    
    override func didMove(to: SKView) {
        backgroundLayer.zPosition = -1
        addChild(backgroundLayer)
        backgroundColor = SKColor.white
        playBackgroundMusic(filename: "backgroundMusic.mp3")
        
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            backgroundLayer.addChild(background)
        }
        
        zombie.position = CGPoint(x:400, y:400)
        zombie.zPosition = 100
        
        backgroundLayer.addChild(zombie)
        
        startZombieAnimation()
//        debugDrawPlayableArea()
        run(SKAction.repeatForever( SKAction.sequence([SKAction.run(spawnEnemy), SKAction.wait(forDuration: 2.0)])))
        run(SKAction.repeatForever( SKAction.sequence([SKAction.run(spawnCat), SKAction.wait(forDuration: 1.0)])))
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveSprite(sprite: zombie, velocity: velocity)
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime
        boundsCheckZombie()
        //checkCollisions()
        rotateSprite(sprite: zombie, direction: velocity)
        moveTrain()
        moveBackground()
        
        if lives <= 0 && !gameOver {
            gameOver = true
            
            backgroundMusicPlayer.stop()
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        let catScenePos = CGPoint(x: CGFloat.random(min: playableRect.minX, max: playableRect.maxX), y: CGFloat.random(min: playableRect.minY, max: playableRect.maxY))
        cat.position = backgroundLayer.convert(catScenePos, from: self)
        cat.name = "cat"
        cat.setScale(0)
        backgroundLayer.addChild(cat)
        
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
    }
    
    func zombieHitCat(cat: SKSpriteNode) {
        cat.name = "train"
        cat.removeAllActions()
        cat.zRotation = 0
        cat.setScale(1)
        cat.color = .green
        cat.colorBlendFactor = 0.7
        
        run(catCollisionSound)
    }
    func zombieHitEnemy(enemy: SKSpriteNode) {
        if !(isZombieInvincible){
            blinkZombie()
            run(enemyCollisionSound)
            loseCats()
            lives -= 1
        }
    }
    
    func blinkZombie(){
        let zombie = self.zombie
        isZombieInvincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) {
            node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        zombie.run(blinkAction, completion: {
            self.isZombieInvincible = false
        })
        
    }
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        backgroundLayer.enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat: cat)
        }
        var hitEnemies: [SKSpriteNode] = []
        
        if !(isZombieInvincible){
            backgroundLayer.enumerateChildNodes(withName: "enemy") { node, _ in
                let enemy = node as! SKSpriteNode
                if node.frame.insetBy(dx: 20, dy: 20).intersects(
                    self.zombie.frame) {
                    hitEnemies.append(enemy)
                }
            }
            for enemy in hitEnemies {
                zombieHitEnemy(enemy: enemy)
            }
        }
    }
    
    func moveTrain() {
        var targetPosition = zombie.position
        var trainCount = 0
        
        backgroundLayer.enumerateChildNodes(withName: "train") { node, _ in
            trainCount += 1
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = (targetPosition - node.position)
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
                self.rotateSprite(sprite: node as! SKSpriteNode, direction: direction)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
        
        if trainCount >= 30 && !gameOver {
            gameOver = true
            
            backgroundMusicPlayer.stop()
            // 1
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            // 2
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            // 3
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func loseCats() {
        var loseCount = 0
        backgroundLayer.enumerateChildNodes(withName: "train") { node, stop in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            node.name = ""
            node.run(
                SKAction.sequence([ SKAction.group([
                    SKAction.rotate(byAngle: π*4, duration: 1.0), SKAction.move(to: randomSpot, duration: 1.0), SKAction.scale(to: 0, duration: 1.0)
                    ]),
                                    
                                    SKAction.removeFromParent() ]))
            loseCount += 1
            if loseCount >= 2 {
                stop[0] = true
            }
        }
    }
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        return backgroundNode
    }
    
    func moveBackground() { let backgroundVelocity =
        CGPoint(x: -backgroundMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        backgroundLayer.position += amountToMove
        
        backgroundLayer.enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            let backgroundScreenPos = self.backgroundLayer.convert( background.position, to: self)
            if backgroundScreenPos.x <= -background.size.width {
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2, y: background.position.y)
            }
        }
    }
}
