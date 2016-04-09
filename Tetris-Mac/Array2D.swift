//
//  Array2D.swift
//  Tetris-Mac
//
//  Created by ZhangLei on 16/4/9.
//  Copyright © 2016年 MiniBear0523. All rights reserved.
//

class Array2D<T> {
    var columns: Int
    var rows: Int
    
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        self.array = Array<T?>(count: rows * columns, repeatedValue: nil)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}
