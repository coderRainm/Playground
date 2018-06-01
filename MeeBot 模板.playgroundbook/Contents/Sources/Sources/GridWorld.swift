//
//  GridWorld.swift
//  PlaygroundScene
//
//  Created by Chao He on 2017/2/27.
//  Copyright © 2017年 UBTech Inc. All rights reserved.
//

import UIKit
import SceneKit

public class GridWorld: NSObject {
    
    var gridNode = SCNNode()
    
    
    init(node: SCNNode) {
        self.gridNode = node
        
        super.init()
    }

}
