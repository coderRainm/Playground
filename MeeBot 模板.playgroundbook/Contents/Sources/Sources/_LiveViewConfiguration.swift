//
//  _LiveViewConfiguration.swift
//  JimuPlaygroundBook
//
//  Created by Chao He on 2016/12/20.
//  Copyright © 2016年 UBTech Inc. All rights reserved.
//

import UIKit
import SceneKit
import PlaygroundSupport

var sceneController:SceneController?
/// A global reference to the loaded scene.
private var loadedScene: Scene? = nil
public func loadGridWorld(named name: String) -> GridWorld {
    do {
        loadedScene = try Scene(named: name)
    }
    catch {
        
    }
    
    return loadedScene!.gridWorld
}

public func setUpLiveViewWith(_ world: GridWorld , _ lesson: Lesson = .lessonNone) {
    // Attempt to use the loaded scene or create one from the world.
    let scene = loadedScene ?? Scene(world: world)
//    sceneController = SceneController(scene: scene)
    sceneController = SceneController(scene: scene, lesson)
    // add scnview and scene
    PlaygroundPage.current.liveView = sceneController
}

