//
//  GuideViewController.swift
//  PlaygroundScene
//
//  Created by newman on 17/3/22.
//  Copyright © 2017年 UBTech Inc. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {
    var lesson:Lesson?
    var guideLable = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: 240, height: 80)
        guideLable.textAlignment = .center
        guideLable.numberOfLines = 0
        guideLable.textColor = UIColor.black
        guideLable.frame = CGRect(x: 10, y: 10, width: 220, height: 60)
        self.view.addSubview(guideLable)
        guideLable.text = lesson!.getLessonTips()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension Lesson{
    func getLessonTips() -> String {
        switch self{
        case .lesson1:
            return "Connect and see dance performed in real Meebot"
        case .lesson2:
            return "Let's dance!"
        case .lesson2_1:
            return "Well done. Good dancing"
        case .lesson3:
            return "Let's dance!"
        case .lesson3_1:
            return "Cool, you have create your own move"
        case .lesson3_2:
            return "Cool, you have create your own dance routine"
        case .lesson4:
            return "Let's dance!"
        case .lesson4_1:
            return "Good job, Try to pick other BPM and see how the dance would like"
        default : break
        }
        return ""
    }
    
}

