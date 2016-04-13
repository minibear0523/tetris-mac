//
//  AppDelegate.swift
//  Tetris-Mac
//
//  Created by ZhangLei on 16/4/9.
//  Copyright © 2016年 MiniBear0523. All rights reserved.
//

import Cocoa

func PrintFunctionName(logMessage: String?, functionName: String = #function) {
    if let message = logMessage {
        print("\(functionName): \(message)")
    } else {
        print("\(functionName)")
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // 对本地application添加一个monitor来监听
//        NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask) {
//            (event: NSEvent) -> NSEvent? in
//            return event
//        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}

