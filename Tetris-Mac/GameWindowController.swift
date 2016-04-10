//
//  GameWindowController.swift
//  Tetris-Mac
//
//  Created by ZhangLei on 16/4/10.
//  Copyright © 2016年 MiniBear0523. All rights reserved.
//

import Cocoa
import SpriteKit

class GameWindowController: NSWindowController, NSWindowDelegate {
    var view: SKView {
        let gameViewController = window!.contentViewController as! ViewController
        return gameViewController.view as! SKView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        window?.delegate = self
    }
    
    func windowWillStartLiveResize(notification: NSNotification) {
        
    }
    
    func windowDidEndLiveResize(notification: NSNotification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}