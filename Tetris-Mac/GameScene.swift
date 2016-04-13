//
//  GameScene.swift
//  Tetris-Mac
//
//  Created by ZhangLei on 16/4/10.
//  Copyright © 2016年 MiniBear0523. All rights reserved.
//

import Foundation
import SpriteKit

let BlockSize: CGFloat = 20.0
let TickLengthLevelOne = NSTimeInterval(600)

let NumKeyControlTypes: UInt32 = 4
enum GameKeyControlType: Int, CustomStringConvertible {
    case Left=0, Right, Down, Rotate, Accelerate
    
    var description: String {
        switch self {
        case .Left:
            return "left"
        case .Right:
            return "right"
        case .Down:
            return "down"
        case .Rotate:
            return "rotate"
        case .Accelerate:
            return "accelerate"
        }
    }
    
}

protocol GameSceneInputDelegate {
    func keyPressed(keyType: GameKeyControlType)
}

class GameScene: SKScene {
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let LayerPosition = CGPoint(x: 6, y: -6)
    
    var tick: (() -> ())?
    var tickLengthMillis = TickLengthLevelOne
    var lastTick: NSDate?
    
    var textureCache = Dictionary<String, SKTexture>()
    
    var inputDelegate: GameSceneInputDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSError not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(color: SKColor.lightGrayColor(), size: size)
        background.position = CGPoint(x: 1.0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        addChild(background)
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))
        gameBoard.anchorPoint = CGPoint(x: 0, y: 1.0)
        gameBoard.position = LayerPosition
        
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        runAction(SKAction.repeatActionForever(SKAction.playSoundFileNamed("theme.mp3", waitForCompletion: true)))
    }
    
    func playSound(sound: String) {
        runAction(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    override func update(currentTime: NSTimeInterval) {
        guard let lastTick = lastTick else {
            return
        }
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis {
            self.lastTick = NSDate()
            tick?()
        }
    }
    
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x = LayerPosition.x + CGFloat(column) * BlockSize + (BlockSize / 2)
        let y = LayerPosition.y - (CGFloat(row) * BlockSize + (BlockSize / 2))
        return CGPointMake(x, y)
    }
    
    func addPreviewShapeToScene(shape: Shape, completion: ()->()) {
        // 首先为图形的每个block创建SKTexture和Node
        for block in shape.blocks {
            var texture = textureCache[block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            
            let sprite = SKSpriteNode(texture: texture)
            sprite.position = pointForColumn(block.column, row: block.row)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            sprite.alpha = 0
            
            // 为Node创建动作Action
            let moveAction = SKAction.moveTo(pointForColumn(block.column, row: block.row), duration: NSTimeInterval(0.2))
            moveAction.timingMode = .EaseOut
            let fadeInAction = SKAction.fadeAlphaTo(0.7, duration: NSTimeInterval(0.4))
            fadeInAction.timingMode = .EaseOut
            sprite.runAction(SKAction.group([moveAction, fadeInAction]))
        }
        runAction(SKAction.waitForDuration(NSTimeInterval(0.4)), completion: completion)
    }
    
    func movePreviewShape(shape: Shape, completion: () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row: block.row)
            let moveToAction: SKAction = SKAction.moveTo(moveTo, duration: NSTimeInterval(0.2))
            moveToAction.timingMode = .EaseOut
            sprite.runAction(SKAction.group([moveToAction, SKAction.fadeAlphaTo(1.0, duration: NSTimeInterval(0.2))]), completion: {})
        }
        
        runAction(SKAction.waitForDuration(NSTimeInterval(0.2)), completion: completion)
    }
    
    /**
     重新绘制图形
     */
    func redrawShape(shape: Shape, completion: ()->()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row: block.row)
            let moveToAction: SKAction = SKAction.moveTo(moveTo, duration: NSTimeInterval(0.05))
            moveToAction.timingMode = .EaseOut
            if block == shape.blocks.last {
                sprite.runAction(moveToAction, completion: completion)
            } else {
                sprite.runAction(moveToAction)
            }
        }
    }
    
    func animateCollapsingLines(linesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion: ()->()){
        var longestDuration: NSTimeInterval = 0
        for (columnIdx, column) in fallenBlocks.enumerate() {
            for (blockIdx, block) in column.enumerate() {
                let newPosition = pointForColumn(block.column, row: block.row)
                let sprite = block.sprite!
                
                let delay = (NSTimeInterval(columnIdx) * 0.05) + (NSTimeInterval(blockIdx) * 0.05)
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.1)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.runAction(SKAction.sequence([SKAction.waitForDuration(delay), moveAction]))
                longestDuration = max(longestDuration, duration + delay)
            }
        }
        
        for rowToRemove in linesToRemove {
            for block in rowToRemove {
                let randomRadius = CGFloat(UInt(arc4random_uniform(400) + 100))
                let goLeft = arc4random_uniform(100) % 2 == 0
                var point = pointForColumn(block.column, row: block.row)
                point = CGPointMake(point.x + (goLeft ? -randomRadius: randomRadius), point.y)
                let randomDuration = NSTimeInterval(arc4random_uniform(2)) + 0.5
                
                var startAngle = CGFloat(M_PI)
                var endAngle = startAngle * 2
                if goLeft {
                    endAngle = startAngle
                    startAngle = 0
                }
                let archPath = NSBezierPath()
                archPath.appendBezierPathWithArcWithCenter(point, radius: randomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: goLeft)
                let archAction = SKAction.followPath(archPath.toCGPath()!,
                                                     asOffset: false,
                                                     orientToPath: true,
                                                     duration: randomDuration)
                archAction.timingMode = .EaseIn
                let sprite = block.sprite!
                sprite.zPosition = 100
                sprite.runAction(SKAction.sequence([SKAction.group([archAction, SKAction.fadeOutWithDuration(NSTimeInterval(randomDuration))]), SKAction.removeFromParent()]))
            }
        }
        
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    override func keyDown(theEvent: NSEvent) {
        guard let characters = theEvent.charactersIgnoringModifiers else {
            return
        }
        
        let char = characters[characters.startIndex]
        var keyType: GameKeyControlType?
        switch char {
        case "a":
            keyType = GameKeyControlType(rawValue: 0)
        case "d":
            keyType = GameKeyControlType(rawValue: 1)
        case "s":
            keyType = GameKeyControlType(rawValue: 2)
        case " ":
            keyType = GameKeyControlType(rawValue: 4)
        case "w":
            keyType = GameKeyControlType(rawValue: 3)
        default:
            keyType = nil
        }
        guard keyType != nil else {
            return
        }
        inputDelegate?.keyPressed(keyType!)
    }
}

extension NSBezierPath {
    func toCGPath() -> CGPath? {
        guard self.elementCount != 0 else {
            return nil
        }
        
        let path = CGPathCreateMutable()
        var didClosePath = false
        
        for i in 0...self.elementCount - 1 {
            var points = [NSPoint](count:3, repeatedValue: NSZeroPoint)
            switch self.elementAtIndex(i, associatedPoints: &points) {
            case .MoveToBezierPathElement:
                CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
            case .LineToBezierPathElement:
                CGPathAddLineToPoint(path, nil, points[0].x, points[0].y)
            case .CurveToBezierPathElement:
                CGPathAddCurveToPoint(path, nil, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y)
            case .ClosePathBezierPathElement:
                CGPathCloseSubpath(path)
                didClosePath = true
            }
        }
        
        if !didClosePath {
            CGPathCloseSubpath(path)
        }
        return CGPathCreateCopy(path)
    }
}