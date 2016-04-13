//
//  ViewController.swift
//  Tetris-Mac
//
//  Created by ZhangLei on 16/4/9.
//  Copyright © 2016年 MiniBear0523. All rights reserved.
//

import Cocoa
import SpriteKit

class ViewController: NSViewController, TetrisDelegate, GameSceneInputDelegate {
    var scene: GameScene!
    var tetris: Tetris!

    @IBOutlet weak var levelLabel: NSTextField!
    @IBOutlet weak var scoreLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        levelLabel.editable = false
        scoreLabel.editable = false
        
        let gameView = view as! SKView
        gameView.showsFPS = true
        gameView.showsNodeCount = true
        scene = GameScene(size: gameView.bounds.size)
        scene.scaleMode = .AspectFill
        scene.tick = didTick
        scene.inputDelegate = self
        
        tetris = Tetris()
        tetris.delegate = self
        tetris.beginGame()
        
        gameView.presentScene(scene)
    }

    func didTick() {
        tetris.letShapeFall()
    }
    
    func nextShape() {
        let newShapes = tetris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
        self.scene.movePreviewShape(fallingShape) {
            self.scene.startTicking()
        }
    }
    
// MARK: TetrisDelegate
    func gameDidBegin(tetris: Tetris) {
        levelLabel.stringValue = "\(tetris.level)"
        scoreLabel.stringValue = "\(tetris.score)"
        
        if tetris.nextShape != nil && tetris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(tetris.nextShape!, completion: { 
                self.nextShape()
            })
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(tetris: Tetris) {
        scene.stopTicking()
        scene.playSound("gameover.mp3")
        scene.animateCollapsingLines(tetris.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) { 
            tetris.beginGame()
        }
    }
    
    func gameDidLevelUp(tetris: Tetris) {
        levelLabel.stringValue = "\(tetris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        
        scene.playSound("levelup.mp3")
    }
    
    func gameShapeDidDrop(tetris: Tetris) {
        scene.stopTicking()
        scene.redrawShape(tetris.fallingShape!) { 
            tetris.letShapeFall()
        }
        
        scene.playSound("drop.mp3")
    }
    
    func gameShapeDidLand(tetris: Tetris) {
        scene.stopTicking()
        let removedLines = tetris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.stringValue = "\(tetris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks: removedLines.fallenBlocks, completion: { 
                self.gameShapeDidLand(tetris)
            })
            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    func gameShapeDidMove(tetris: Tetris) {
        scene.redrawShape(tetris.fallingShape!) {}
    }
    
// MARK: - GameSceneInputDelegate
    func keyPressed(keyType: GameKeyControlType) {
        switch keyType {
        case .Left:
            tetris.moveShapeLeft()
        case .Right:
            tetris.moveShapeRight()
        case .Down:
            tetris.letShapeFall()
        case .Rotate:
            tetris.rotateShape()
        case .Accelerate:
            tetris.dropShape()
        }
    }
}

