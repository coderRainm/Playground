//
//  CommandQueue.swift
//  JimuPlaygroundBook
//
//  Created by frank on 2016/12/30.
//  Copyright © 2016年 UBTech Inc. All rights reserved.
//

import Foundation
import PlaygroundSupport

public var commandManager:CommandManager?

/**
 A queue which all commands are added so that top level code always
 executers in order, one command at a time.
 */

public class CommandManager: NSObject {
    
    var running = false //执行start()时变true，执行finish()或者liveView取消时变false
    var busy = false    //普通指令发出后标记为true，收到回包后标记为false
    var moveBodyCommand:Command?
    lazy var commands = [Command]()
    //开始执行代码
    public func start(){
        running = true
        busy = false
        commands.removeAll()
        sendCommand(.start)
    }
    //代码执行完毕
    public func finish(){
        assessmentManager?.updateAssessment(commands, successful: nil)
        sendCommand(.finish)
    }
    
    public func sendCommand(_ action:Action, variables:[String]? = nil)
    {
        if let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
            if !action.isControl {
                if running {
                    var cmd: Command?
                    if moveBodyCommand != nil {
                        if action == .moveBody {
                            for (i, e) in variables!.enumerated() {
                                if e != "nil" {
                                    moveBodyCommand?.variables?[i] = e
                                }
                            }
                        } else if action == .endMoveBody {
                            cmd = moveBodyCommand
                            moveBodyCommand = nil
                        }
                    }else if action == .beginMoveBody {
                        moveBodyCommand = Command(.moveBody, variables:["nil", "nil", "nil", "nil", "nil", "nil", variables!.first!])
                    }else {
                        cmd = Command(action, variables:variables)
                    }
                    if let c = cmd {
                        proxy.send(c.playgroundValue)
                        busy = true
                        commands.append(c)
                        pageLog("before runloop \(c.action)")
                        while running && busy{
                            RunLoop.main.run(mode: .defaultRunLoopMode, before: Date(timeIntervalSinceNow: 0.02))
                        }
                        pageLog("after runloop \(c.action)")
                    }
                }
            }else if action != ._log{
                proxy.send(Command(action, variables:variables).playgroundValue)
            }
        }
    }
    
    public func onReceive(_ cmd:Command){
        switch cmd.action {
        case .finish:
            running = false
            PlaygroundPage.current.finishExecution()
        case ._notif, .start:
            if let arr = cmd.variables {
                updateValues(arr)
            }
        case ._cancel:
            running = false
            PlaygroundPage.current.finishExecution()
        default:
            break
        }
        if !cmd.isControl {
            if running {
                busy = false
            }
        }
    }
    
    public func log(_ log:String, line:Int){
        if let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
            proxy.send(Command(._log, variables:[log, "\(line)"]).playgroundValue)
        }
    }
}

extension CommandManager{
    func updateValues(_ values:[String]) {
        if values.count >= 2, let bpm = Int(values[0]) {
            BPMofCurrentMusic = bpm
            currentMusic = stringFromString(values[1])
            pageLog("\(BPMofCurrentMusic)  \(currentMusic)")
        }
    }
}

extension CommandManager:PlaygroundRemoteLiveViewProxyDelegate{
    public func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
        pageLog("page close")
        PlaygroundPage.current.finishExecution()
    }
    
    public func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received value: PlaygroundValue) {
        guard let cmd = Command(value) else {
            return
        }
        pageLog("recv act = \(cmd.action.rawValue)")
        onReceive(cmd)
    }
}
