//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Michael Radzwilla on 4/21/17.
//  Copyright © 2017 hackingwithswift. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        let background: SKSpriteNode
        background = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let scene = GameScene(size:CGSize(width: 2048, height: 1536))
        scene.scaleMode = .aspectFill
        let reveal = SKTransition.doorway(withDuration: 1.5)

        view?.presentScene(scene, transition: reveal)

    }
}
