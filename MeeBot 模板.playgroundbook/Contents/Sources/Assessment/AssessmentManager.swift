//
//  AssessmentManager.swift
//  Playground
//
//  Created by WG on 2017/3/27.
//  Copyright © 2017年 WG. All rights reserved.
//

import Foundation
import PlaygroundSupport

public var assessmentManager:AssessmentManager?

public class AssessmentManager:NSObject {
    var assessment:([Command], Bool?)->PlaygroundPage.AssessmentStatus
    public init(_ assessment:@escaping ([Command], Bool?)->PlaygroundPage.AssessmentStatus){
        self.assessment = assessment
        super.init()
    }
    public func updateAssessment(_ commands:[Command], successful:Bool? = nil){
        PlaygroundPage.current.assessmentStatus = assessment(commands, successful)
    }
}
