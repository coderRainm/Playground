//
//  SceneController+Command.swift
//  Playground
//
//  Created by WG on 2017/3/24.
//  Copyright © 2017年 WG. All rights reserved.
//

import Foundation
import PlaygroundSupport

extension SceneController {
    
    var timeScale: Double {
        let mode = PlaygroundPage.current.executionMode
        switch mode {
        case .run:
            return 1
        case .step:
            return 1.5
        case .stepSlowly:
            return 2
        default:
            return 1
        }
    }
    
    func onReceive(_ action:Action, variables:[String]? = nil) {
        currentAction = action
        switch action {
        case .start:
            starting = true
            tryStarting()
            playMusic()
        case .finish:
            running = false
            currentAction = nil
            animationTimer?.invalidate()
            animationTimer = nil
            runCommonAnimation(.reset)
            sendCommand(.finish)
            setTipsAsStop()
        case .moveBody:
            guard let v = variables else { onAnimationFinish(); break }
            runMoveBodyAnimation(v[0..<6].map{Int8($0)}, beats:v.count > 6 ? Double(v.last!) : nil)
        case .setBpmOfMySong:
            if let v = variables?.first, let i = UInt(v) {
                bpmOfMySong = i
            }
            onAnimationFinish()
        default:
            runCommonAnimation(action, beats:Double(variables?.last ?? ""))
        }
    }
    
    func sendCommand(_ action:Action, variables:[String]? = nil) {
        send(Command(action, variables:variables).playgroundValue)
    }
    
    func onAnimationFinish() {
        if let a = currentAction {
            sendCommand(a, variables: a == .start ? ["\(bpm)", "\(music)"] : nil)
            currentAction = nil
        }
    }
    
    func tryStarting() {
        if !connecting && starting {
            starting = false
            runCommonAnimation(.reset)
        }
    }
}

extension SceneController:PlaygroundLiveViewMessageHandler {
    //手动开始
    public func liveViewMessageConnectionOpened() {
        liveLog("live opened")
        dismissAudioMenu()
        running = true
    }
    
    //手动结束
    public func liveViewMessageConnectionClosed() {
        liveLog("live closed \(running)")
        if running {
            running = false
            currentAction = nil
            animationTimer?.invalidate()
            animationTimer = nil
            runCommonAnimation(.reset)
            sendCommand(._cancel)
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        guard let cmd = Command(message) else {
            return
        }
        if cmd.action == ._log {
            if let arr = cmd.variables, arr.count >= 2 {
                if let n = Int(arr[1]) {
                    log(arr[0], line:n)
                }
            }
        }else {
            if running {
                liveLog("recv act = \(cmd.action.rawValue)")
                onReceive(cmd.action, variables:cmd.variables)
            }
        }
    }
}
