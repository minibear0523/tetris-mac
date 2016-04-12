//
//  KeyboardControlInputSource.swift
//  Tetris-Mac
//
//  Created by ZhangLei on 16/4/12.
//  Copyright © 2016年 MiniBear0523. All rights reserved.
//

import simd


class KeyboardControlInputSource {
    var downKeys = Set<Character>()
    
    static let leftVector = float2(x: -1, y: 0)
    static let rightVector = float2(x: 1, y: 0)
    
    func handleKeyDownForCharacter(character: Character) {
        if downKeys.contains(character) {
            return
        }
        downKeys.insert(character)
    }
}