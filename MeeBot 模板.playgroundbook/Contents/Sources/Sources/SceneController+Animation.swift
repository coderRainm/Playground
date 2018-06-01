//
//  SceneController+Animation.swift
//  PlaygroundScene
//
//  Created by newman on 17/3/15.
//  Copyright © 2017年 UBTech Inc. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

let rotate_vectors = [[(name:"youtui_1_ID01", vector:SCNVector3Make(0, 1, 0)), (name:"youtui_2_ID03", vector:SCNVector3Make(0, 1, 0))],
                      [(name:"youshou_ID02", vector:SCNVector3Make(0, 0, 1))],
                      [(name:"youtui_3", vector:SCNVector3Make(0, 0, 1))],
                      [(name:"zuotui_1_ID04", vector:SCNVector3Make(0, 1, 0)), (name:"zuotui_2_ID06", vector:SCNVector3Make(0, 1, 0))],
                      [(name:"zuoshou_ID05", vector:SCNVector3Make(0, 0, 1))],
                      [(name:"zuotui_3", vector:SCNVector3Make(0, 0, 1))],]

func calibrate_step_duration(_ duration:Double) -> Double {
    return max(0.25, min(duration, 10))
}

extension SceneController{
    
    func loadAnimations() {
        //load servo angles
        if let p = Bundle.main.path(forResource: "Angles/servo_angles", ofType: "plist"), let nd = NSDictionary(contentsOfFile: p) as? [String:[[UInt8]]] {
            nd.forEach{
                if let a = Action(rawValue:$0) {
                    servoAngles[a] = $1
                }
            }
        }
        //load animation
        Bundle.main.paths(forResourcesOfType: "plist", inDirectory: "Actions").forEach{
            if let dict  = NSArray(contentsOfFile: $0) as? [[String:[Double]]], let last = $0.components(separatedBy: "/").last, let name = last.components(separatedBy: ".").first, let a = Action(rawValue:name){
                animations[a] = dict
            }
        }
    }
    
    func runCommonAnimation(_ action:Action, beats:Double? = nil) {
        guard let angles = servoAngles[action] else { return }
        guard let actions = animations[action] else { return }
        let beats_per_step = beats ?? 0 > 0 ? beats! / Double(angles.count) : 1.0
        let duration_per_step = calibrate_step_duration(beats_per_step * 60 / Double(bpm) * timeScale)
        liveLog("duration_per_step \(duration_per_step)")
        var index = 0
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: duration_per_step, repeats: true){[weak self] in
            let time = CFAbsoluteTimeGetCurrent()
            if index >= angles.count || index >= actions.count {
                $0.invalidate()
                liveLog("animation finish \(time - (self?.animationTimeStamp ?? 0))")
                self?.onAnimationFinish()
            }else {
                liveLog("duration \(action) \(time - (self?.animationTimeStamp ?? 0))")
                Meebot.shared.setServos(angles[index], duration:UInt(duration_per_step * 1000))
                actions[index].forEach{
                    if let node = self?.scnView.scene?.rootNode.childNode(withName: $0, recursively: true) {
                        let move = SCNAction.move(to: SCNVector3($1[0], $1[1], $1[2]), duration: duration_per_step)
                        let rotate = SCNAction.rotateTo(x: CGFloat($1[3] * Double.pi / 180) , y: CGFloat($1[4] * Double.pi / 180), z: CGFloat($1[5] * Double.pi / 180), duration: duration_per_step, usesShortestUnitArc: true)
                        node.removeAllActions()
                        node.runAction(SCNAction.group([move, rotate]))
                    }
                }
                index += 1
            }
            self?.animationTimeStamp = time
        }
        animationTimer?.tolerance = 0
        animationTimer?.fire()
    }
    
    func runMoveBodyAnimation(_ angles:[Int8?], beats:Double? = nil) {
        let beats_per_step = beats ?? 0 > 0 ? beats! : 1.0
        let duration_per_step = calibrate_step_duration(beats_per_step * 60 / Double(bpm) * timeScale)
        liveLog("duration_per_step \(duration_per_step)")
        Meebot.shared.setServos(angles.map{$0 == nil ? nil : UInt8(120 + Int($0!))}, duration:UInt(duration_per_step * 1000))

        var acts = [String:SCNAction]()
        for (i, e) in angles.enumerated() {
            if let ee = e {
                let tuples = rotate_vectors[i]
                tuples.forEach{
                    let rotate = SCNAction.rotateTo(x: CGFloat($0.vector.x) * CGFloat(ee) * CGFloat(Double.pi / 180), y: CGFloat($0.vector.y) * CGFloat(ee) * CGFloat(Double.pi / 180), z: CGFloat($0.vector.z) * CGFloat(ee) * CGFloat(Double.pi / 180), duration: duration_per_step, usesShortestUnitArc: true)
                    acts[$0.name] = rotate
                }
            }
        }
        //腿没动就是没联动，可以reset以避免3D运行混乱
        if angles[0] == nil && angles[3] == nil {
            if let vs = animations[.reset]?.first {
                vs.forEach{
                    let move = SCNAction.move(to: SCNVector3($1[0], $1[1], $1[2]), duration: duration_per_step)
                    let rotate = SCNAction.rotateTo(x: CGFloat($1[3] * Double.pi / 180) , y: CGFloat($1[4] * Double.pi / 180), z: CGFloat($1[5] * Double.pi / 180), duration: duration_per_step, usesShortestUnitArc: true)
                    if let r = acts[$0] {
                        acts[$0] = SCNAction.group([move, r])
                    }else{
                        acts[$0] = SCNAction.group([move, rotate])
                    }
                }
            }
        }
        acts.forEach{
            if let node = self.scnView.scene?.rootNode.childNode(withName: $0, recursively: true) {
                node.removeAllActions()
                node.runAction($1)
            }
        }
        let time = CFAbsoluteTimeGetCurrent()
        liveLog("duration moveBody \(time - animationTimeStamp)")
        animationTimeStamp = time
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: duration_per_step, repeats: false) {[weak self] _ in
            self?.onAnimationFinish()
        }
        animationTimer?.tolerance = 0
    }
}
