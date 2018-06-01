//
//  Commands.swift
//  JimuPlaygroundBook
//
//  Created by hechao on 2016/12/30.
//  Copyright © 2016年 UBTech Inc. All rights reserved.
//

import Foundation
import PlaygroundSupport

public var BPMofCurrentMusic: Int = 120
public var currentMusic:String?

public func isPlaying(song:String)->Bool {
    return song == currentMusic
}

/**
 Restart to play current music when code start running
 */

//public func crazyDance(beats:Double = 10) {
//    let beatsPerMove = (max(5, min(beats, 200))) / 20.0
//    
//    moveBody(beats:beatsPerMove, moves: {
//        moveLeftFoot(angle: -57)
//        moveRightFoot(angle: -25)
//    })
//    
//    moveBody(beats:beatsPerMove, moves: {
//        moveRightFoot(angle: -35)
//        moveRightArm(angle: -20)
//        moveLeftFoot(angle: 10)
//    })
//    
//    for i in  1 ... 4 {
//        moveBody(beats:beatsPerMove, moves: {
//            moveLeftLeg(angle: 20)
//            moveRightLeg(angle: -20)
//            moveLeftArm(angle: 30)
//            moveLeftFoot(angle: 30)
//            moveRightArm(angle: -20)
//        })
//        moveBody(beats:beatsPerMove, moves: {
//            moveLeftLeg(angle: -20)
//            moveRightLeg(angle: 20)
//            moveLeftArm(angle: -30)
//            moveLeftFoot(angle: -30)
//            moveRightArm(angle: 0)
//        })
//    }
//    
//    reset()
//    
//    moveBody(beats:beatsPerMove, moves: {
//        moveRightFoot(angle: 57)
//        moveLeftFoot(angle: 25)
//    })
//    
//    moveBody(beats:beatsPerMove, moves: {
//        moveLeftFoot(angle: 35)
//        moveLeftArm(angle: 20)
//        moveRightFoot(angle: -10)
//    })
//    
//    for i in  1 ... 4 {
//        moveBody(beats:beatsPerMove, moves: {
//            moveLeftLeg(angle: 20)
//            moveRightLeg(angle: -20)
//            moveRightArm(angle: 30)
//            moveRightFoot(angle: 30)
//            moveLeftArm(angle: 20)
//        })
//        moveBody(beats:beatsPerMove, moves: {
//            moveLeftLeg(angle: -20)
//            moveRightLeg(angle: 20)
//            moveRightArm(angle: -30)
//            moveRightFoot(angle: -30)
//            moveLeftArm(angle: 0)
//        })
//    }
//    
//    reset()
//}

/**
 Let MeeBot go forward
 - parameters:
 - beats: 1.0 default
 */
public func moveForward(beats:Double) {
    commandManager?.sendCommand(.moveForward, variables: ["\(beats)"])
}
public func moveForward() {
    commandManager?.sendCommand(.moveForward)
}
/**
 Let MeeBot go backward
 */
public func moveBackward(beats:Double) {
    commandManager?.sendCommand(.moveBackward, variables: ["\(beats)"])
}
public func moveBackward() {
    commandManager?.sendCommand(.moveBackward)
}
/**
 Let MeeBot go to left
 */
public func moveToLeft(beats:Double) {
    commandManager?.sendCommand(.moveToLeft, variables: ["\(beats)"])
}
public func moveToLeft() {
    commandManager?.sendCommand(.moveToLeft)
}
/**
 Let MeeBot go  to right
 */
public func moveToRight(beats:Double) {
    commandManager?.sendCommand(.moveToRight, variables: ["\(beats)"])
}
public func moveToRight() {
    commandManager?.sendCommand(.moveToRight)
}
/**
 Let MeeBot bend
 */
public func bend(){
    commandManager?.sendCommand(.bend)
}

public func bend(beats:Double){
    commandManager?.sendCommand(.bend, variables: ["\(beats)"])
}

/**
 Let MeeBot happy
 */
public func happy(){
    commandManager?.sendCommand(.happy)
}

public func happy(beats:Double){
    commandManager?.sendCommand(.happy, variables: ["\(beats)"])
}

/**
 Let MeeBot split
 */
public func split(){
    commandManager?.sendCommand(.split)
}

public func split(beats:Double){
    commandManager?.sendCommand(.split, variables: ["\(beats)"])
}

/**
 Let MeeBot skip
 */
public func skip(){
    commandManager?.sendCommand(.skip)
}

public func skip(beats:Double){
    commandManager?.sendCommand(.skip, variables: ["\(beats)"])
}

/**
 Let MeeBot dance2
 */
public func twist(){
    commandManager?.sendCommand(.twist)
}

public func twist(beats:Double){
    commandManager?.sendCommand(.twist, variables: ["\(beats)"])
}

/**
 Let MeeBot dance3
 */
public func stepAndShake(){
    commandManager?.sendCommand(.stepAndShake)
}

public func stepAndShake(beats:Double){
    commandManager?.sendCommand(.stepAndShake, variables: ["\(beats)"])
}

/**
 Let MeeBot bendAndTwist
 */
public func bendAndTwist(){
    commandManager?.sendCommand(.bendAndTwist)
}

public func bendAndTwist(beats:Double){
    commandManager?.sendCommand(.bendAndTwist, variables: ["\(beats)"])
}

/**
 Let MeeBot crazyDance
 */
public func crazyDance(){
    crazyDance(beats:10)
}

public func crazyDance(beats:Double){
    commandManager?.sendCommand(.crazyDance, variables: ["\(beats)"])
}

/**
 Let MeeBot shake
 */
public func shake(){
    commandManager?.sendCommand(.shake)
}

public func shake(beats:Double){
    commandManager?.sendCommand(.shake, variables: ["\(beats)"])
}

/**
 Let MeeBot wave
 */
public func wave(){
    commandManager?.sendCommand(.wave)
}

public func wave(beats:Double){
    commandManager?.sendCommand(.wave, variables: ["\(beats)"])
}

/**
 Let MeeBot swagger
 */
public func swagger(){
    commandManager?.sendCommand(.swagger)
}

public func swagger(beats:Double){
    commandManager?.sendCommand(.swagger, variables: ["\(beats)"])
}

/**
 Set MeeBot to the initial posture, all its joints angle would be set zero
 */
public func reset() {
    commandManager?.sendCommand(.reset)
}

/**
 Let MeeBot raise both hands
 */
public func raiseHands(beats:Double) {
    commandManager?.sendCommand(.raiseHands, variables: ["\(beats)"])
}
public func raiseHands() {
    commandManager?.sendCommand(.raiseHands)
}

public func moveLeftArm(angle:Int){
    commandManager?.sendCommand(.moveBody, variables: ["nil", "nil", "nil", "nil", "\(angle_calibrate(angle, index:4))", "nil"])
}

public func moveRightArm(angle:Int){
    commandManager?.sendCommand(.moveBody, variables: ["nil", "\(angle_calibrate(angle, index:1))", "nil", "nil", "nil", "nil"])
}

public func moveLeftLeg(angle:Int){
    commandManager?.sendCommand(.moveBody, variables: ["nil", "nil", "nil", "\(angle_calibrate(angle, index:3))", "nil", "nil"])
}

public func moveRightLeg(angle:Int){
    commandManager?.sendCommand(.moveBody, variables: ["\(angle_calibrate(angle, index:0))", "nil", "nil", "nil", "nil", "nil"])
}

public func moveLeftFoot(angle:Int){
    commandManager?.sendCommand(.moveBody, variables: ["nil", "nil", "nil", "nil", "nil", "\(angle_calibrate(angle, index:5))"])
}

public func moveRightFoot(angle:Int){
    commandManager?.sendCommand(.moveBody, variables: ["nil", "nil", "\(angle_calibrate(angle, index:2))", "nil", "nil", "nil"])
}

public func moveLeftArm(angle:Int, beats:Double){
    commandManager?.sendCommand(.moveBody, variables: ["nil", "nil", "nil", "nil", "\(angle_calibrate(angle, index:4))", "nil", "\(beats)"])
}

public func moveRightArm(angle:Int, beats:Double){
    commandManager?.sendCommand(.moveBody, variables: ["nil", "\(angle_calibrate(angle, index:1))", "nil", "nil", "nil", "nil", "\(beats)"])
}

public func moveLeftLeg(angle:Int, beats:Double){
    commandManager?.sendCommand(.moveBody, variables: ["nil", "nil", "nil", "\(angle_calibrate(angle, index:3))", "nil", "nil", "\(beats)"])
}

public func moveRightLeg(angle:Int, beats:Double){
    commandManager?.sendCommand(.moveBody, variables: ["\(angle_calibrate(angle, index:0))", "nil", "nil", "nil", "nil", "nil", "\(beats)"])
}

public func moveLeftFoot(angle:Int, beats:Double){
    commandManager?.sendCommand(.moveBody, variables: ["nil", "nil", "nil", "nil", "nil", "\(angle_calibrate(angle, index:5))", "\(beats)"])
}

public func moveRightFoot(angle:Int, beats:Double){
    commandManager?.sendCommand(.moveBody, variables: ["nil", "nil", "\(angle_calibrate(angle, index:2))", "nil", "nil", "nil", "\(beats)"])
}

func beginMoveBody(_ beats:Double){
    commandManager?.sendCommand(.beginMoveBody, variables: ["\(beats)"])
}

func endMoveBody(){
    commandManager?.sendCommand(.endMoveBody)
}

public func moveBody(beats:Double, moves:()->Void){
    beginMoveBody(beats)
    moves()
    endMoveBody()
}

public func moveBody(moves:()->Void){
    beginMoveBody(1)
    moves()
    endMoveBody()
}

public func setBpmOfMySong(bpm:UInt){
    commandManager?.sendCommand(.setBpmOfMySong, variables: ["\(max(30, min(bpm, 300)))"])
}

public let limits_angle = [(low:-45, high:45), (low:-75, high:110), (low:-75, high:65), (low:-45, high:45), (low:-110, high:75), (low:-65, high:75)]

public func angle_calibrate(_ angle:Int, index:Int)->Int8 {
    return Int8(max(limits_angle[index].low, min(angle, limits_angle[index].high)))
}
