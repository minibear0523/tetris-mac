//
//  Tetris.swift
//  Tetris-Mac
//
//  Created by ZhangLei on 16/4/9.
//  Copyright © 2016年 MiniBear0523. All rights reserved.
//

let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

let PointsPerLine = 10
let LevelThreshold = 1000


protocol TetrisDelegate {
    func gameDidEnd(tetris: Tetris)
    func gameDidBegin(tetris: Tetris)
    func gameShapeDidLand(tetris: Tetris)
    func gameShapeDidMove(tetris: Tetris)
    func gameShapeDidDrop(tetris: Tetris)
    func gameDidLevelUp(tetris: Tetris)
}

class Tetris {
    var blockArray: Array2D<Block>
    var nextShape: Shape?
    var fallingShape: Shape?
    var delegate: TetrisDelegate?
    
    var score = 0
    var level = 1
    
    /**
     初始化Tetris游戏桌面, 20 * 10的棋盘
     */
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    /**
     开始游戏, 如果不存在nextShape, 随机创建一个Shape对象
     */
    func beginGame() {
        if nextShape == nil {
            nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(self)
    }
}