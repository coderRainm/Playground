//
//  SceneController+Lesson.swift
//  PlaygroundScene
//
//  Created by newman on 17/3/23.
//  Copyright © 2017年 UBTech Inc. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import SceneKit

public enum Lesson: String {
    case lessonNone = "none"
    case lesson1 = "first Lesson"
    case lesson2 = "second Lesson begin"
    case lesson2_1 = "second Lesson end"
    case lesson3 = "third Lesson"
    case lesson3_1 = "third Lesson use set"
    case lesson3_2 = "third Lesson end"
    case lesson4   = "forth lesson"
    case lesson4_1 = "forth lesson end"
    
    case lesson5
    
    case lesson6 = "sixth lesson"

    case lesson7
    
    case lesson8
    
    case lesson9 = "last lesson"
}


extension SceneController{
    
    func addLesson(les:Lesson){
        
        if let pc = presentedViewController{
            pc.dismiss(animated: true, completion: nil)
        }
        let guide = GuideViewController()
        guide.modalPresentationStyle = .popover
        guide.popoverPresentationController?.passthroughViews = [view]
        guide.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 5, width: 44, height: 44)
        guide.popoverPresentationController?.delegate = self
        guide.lesson = les
        switch les {
        case .lesson1:
            guide.popoverPresentationController?.permittedArrowDirections = .up
            break
        case .lesson2,.lesson2_1:
            guide.popoverPresentationController?.permittedArrowDirections = .down
            guide.popoverPresentationController?.sourceView = guideBtn
        case .lesson3,.lesson3_1,.lesson3_2:
            guide.popoverPresentationController?.permittedArrowDirections = .down
            guide.popoverPresentationController?.sourceView = guideBtn
        case .lesson4,.lesson4_1:
            guide.popoverPresentationController?.permittedArrowDirections = .down
            guide.popoverPresentationController?.sourceView = guideBtn
     
        default:
            break
        }
       // self.present(guide, animated: true) { }
    }
    
    func setTipsAsStart() {
        
    }
    
    func setTipsAsStop() {
        if userLesson == .lesson9 {
            appluse()
            confetti()
        }
    }
}


