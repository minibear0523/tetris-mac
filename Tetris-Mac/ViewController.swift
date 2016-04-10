//
//  ViewController.swift
//  Tetris-Mac
//
//  Created by ZhangLei on 16/4/9.
//  Copyright © 2016年 MiniBear0523. All rights reserved.
//

import Cocoa
import SpriteKit

class ViewController: NSViewController, TetrisDelegate {
    
    var scene: GameScene!
    var tetris: Tetris!

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        scene.tick = didTick
        
        tetris = Tetris()
        tetris.delegate = self
        tetris.beginGame()
        
        skView.presentScene(scene)
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
    
    func gameDidBegin(tetris: Tetris) {
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
    }
    
    func gameDidLevelUp(tetris: Tetris) {
        
    }
    
    func gameShapeDidDrop(tetris: Tetris) {
        scene.stopTicking()
        scene.redrawShape(tetris.fallingShape!) { 
            tetris.letShapeFall()
        }
    }
    
    func gameShapeDidLand(tetris: Tetris) {
        scene.stopTicking()
        let removedLines = tetris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks: removedLines.fallenBlocks, completion: { 
                self.gameShapeDidLand(tetris)
            })
        }
    }
    
    func gameShapeDidMove(tetris: Tetris) {
        scene.redrawShape(tetris.fallingShape!) {}
    }
}

