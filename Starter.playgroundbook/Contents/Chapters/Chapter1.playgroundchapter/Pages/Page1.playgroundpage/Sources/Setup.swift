//
//  Setup.swift
//  JimuPlaygroundBook
//
//  Created by hechao on 2016/12/30.
//  Copyright © 2016年 UBTech Inc. All rights reserved.
//

import Foundation
import PlaygroundSupport

public func playgroundPrologue() {
    if let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
        PlaygroundPage.current.needsIndefiniteExecution = true
        commandManager = CommandManager()
        proxy.delegate = commandManager
    }
}

public func playgroundEpilogue() {
}
