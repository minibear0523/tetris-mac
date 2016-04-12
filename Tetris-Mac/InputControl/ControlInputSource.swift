//
//  ControlInputSource.swift
//  Tetris-Mac
//
//  Created by ZhangLei on 16/4/12.
//  Copyright © 2016年 MiniBear0523. All rights reserved.
//

import simd

enum ControlInputDirection: Int, CustomStringConvertible {
    case Up = 0, Down, Left, Right
    
    var description: String {
        switch self {
        case .Up:
            return "up"
        case .Down:
            return "down"
        case .Left:
            return "left"
        case .Right:
            return "right"
        }
    }
}

