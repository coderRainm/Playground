//
//  Command.swift
//  JimuPlaygroundBook
//
//  Created by frank on 2016/12/30.
//  Copyright © 2016年 UBTech Inc. All rights reserved.
//

import Foundation
import PlaygroundSupport

let keyCommand = "cmd"
let keyVariables = "vars"

public struct Command:Equatable {
    public let action: Action
    public var variables:[String]?
    
    //control命令发送时会排队
    public var isControl:Bool {
        return action.rawValue.hasPrefix("_")
    }
    
    public var playgroundValue:PlaygroundValue {
        if let v = variables, v.count > 0 {
            let arr = v.map {PlaygroundValue.string($0)}
            return PlaygroundValue.dictionary([keyCommand: PlaygroundValue.string(action.rawValue), keyVariables:PlaygroundValue.array(arr)])
        }else{
            return PlaygroundValue.dictionary([keyCommand: PlaygroundValue.string(action.rawValue)])
        }
    }
    public init?(_ playgroundValue:PlaygroundValue) {
        guard case let PlaygroundValue.dictionary(dic) = playgroundValue else {
            return nil
        }
        guard case let PlaygroundValue.string(key)? = dic[keyCommand], let k = Action(rawValue: key) else {
            return nil
        }
        self.init(k, variables:nil)
        if case let PlaygroundValue.array(arr)? = dic[keyVariables] {
            self.variables = arr.flatMap {
                if case let PlaygroundValue.string(str) = $0 {
                    return str
                }else{
                    return nil
                }
            }
        }
    }
    public init(_ action:Action, variables:[String]? = nil){
        self.action = action
        self.variables = variables
    }
    public static func ==(lhs: Command, rhs: Command) -> Bool{
        if let l = lhs.variables, let r = rhs.variables {
            return lhs.action == rhs.action && l == r
        }else if lhs.variables == nil && rhs.variables == nil{
            return lhs.action == rhs.action
        }else{
            return false
        }
    }
}

public enum Action:String,ExpressibleByStringLiteral {
    case reset, moveToLeft, moveToRight, moveForward, moveBackward, raiseHands, bend, happy, split, skip, twist, stepAndShake, bendAndTwist, crazyDance, shake, wave, swagger
    case moveBody
    case beginMoveBody, endMoveBody
    case setBpmOfMySong
    case start, finish, _cancel
    case _notif
    case _log
    
    //control命令发送时会排队
    public var isControl:Bool {
        return rawValue.hasPrefix("_")
    }
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
    public init(unicodeScalarLiteral value: String) {
        self.init(rawValue: value)!
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(rawValue: value)!
    }
}

public func stringFromOptional(_ obj:Any?)->String{
    if let o = obj {
        return "\(o)"
    }else {
        return "nil"
    }
}

public func stringFromString(_ str:String)->String?{
    if str == "nil"{
        return nil
    }else{
        return str
    }
}
