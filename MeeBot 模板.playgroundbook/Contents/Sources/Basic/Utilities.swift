//
//  Utilities.swift
//  Playground
//
//  Created by WG on 2017/3/27.
//  Copyright © 2017年 WG. All rights reserved.
//

import Foundation

public let MACRO_DEBUG = true

/*******
 十分注意，仅供liveView使用，page不能调用
 ********/
public func liveLog(_ log:Any? = nil, line:Int = #line){
    if MACRO_DEBUG{
        sceneController?.log("\(log ?? "nil")", line: line)
    }
}

/*******
 十分注意，仅供page使用，liveView不能调用
 ********/
public func pageLog(_ log:Any? = nil, line:Int = #line) {
    if MACRO_DEBUG{
        commandManager?.log("P \(log ?? "")", line: line)
    }
}

// Build in music count 
public let buildInMusicCount = 2

// Audio names
public let musicBitBitLoop = "Bit Bit Loop"
public let musicIntro = "Intro"
public let musicSpikey = "Spikey"
public let musicPumpedup = "Pumped up kicks"
public let musicApplause10s = "applause_10s"

// Flash lights interval
public let lightFlashInterval: TimeInterval = 0.2

// Audio rate
public let audioRate: Float = 1.0     // default, value in [0.5,2]
