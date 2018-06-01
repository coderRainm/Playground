//
//  Scene.swift
//  JimuPlaygroundBook
//
//  Created by hechao on 2016/12/26.
//  Copyright © 2016年 UBTech Inc. All rights reserved.
//

import UIKit
import SceneKit

/// Reports changes to the worlds state.
protocol SceneStateDelegate: class {
    func scene(_ scene: Scene, didEnterState: Scene.State)
}

final class Scene: NSObject {
    
    // MARK: Types
    enum State {
        /// The starting state of the scene before anything has been added.
        case initial
        
        /// The state after all inanimate elements have been placed.
        case built
        
        /// The state which rewinds the `commandQueue` in preparation for playback.
        case ready
        
        /// The state which starts running commands in the `commandQueue`.
        case run
        
        /// The final state after all commands have been run.
        case done
    }
    
    // MARK: Properties
    private let source: SCNSceneSource
    
    lazy var scnScene: SCNScene = {
        var scene = SCNScene()
        do {
            let sourceScene = try self.source.scene()
            
            let stageNode = sourceScene.rootNode.childNode(withName: GridNodeName, recursively: false)
            let cameraHandleNode = sourceScene.rootNode.childNode(withName: CameraHandleName, recursively: false)
            scene.rootNode.addChildNode(stageNode!)
            scene.rootNode.addChildNode(cameraHandleNode!)
            
            sourceScene.rootNode.name = GridNodeName
            scene.rootNode.name = RootNodeName
        }
        catch {
            fatalError("Failed to Load Scene.\n\(error)")
        }
        
        // remove stage root node and then reload the stage root node
        scene.rootNode.childNode(withName: GridNodeName, recursively: false)?.removeFromParentNode()
        scene.rootNode.addChildNode(self.gridWorld.gridNode)
        
        
        return scene
    }()
    
    var rootNode: SCNNode {
        return scnScene.rootNode
    }
    
    /// The duration used when rewinding the scene.
    var resetDuration: TimeInterval = 0.0
    
    let gridWorld: GridWorld
    
    weak var delegate: SceneStateDelegate?
    
    var state: State = .initial {
        didSet {
            guard oldValue != state else { return }
            
            let newState = state
            enterState(newState)
            
            OperationQueue.main.addOperation {
                self.delegate?.scene(self, didEnterState: newState)
            }
        }
    }
    
    // MARK: Scene Adjustments
    
    func enterState(_ newState: State) {
        switch newState {
        case .initial:
            break
            
        case .built: break
            // Never animate `built` steps.
            
        case .ready:break

            
        case .run:break
            
        case .done:break
            
        }
        
    }

    /// Initialize with an ".scn" scene.
    convenience init?(named sceneName: String) throws {
        let path = "WorldResources.scnassets/_Scenes/" + sceneName
        
        let sURL = (Bundle.main.url(forResource: path, withExtension: "scn") != nil) ? Bundle.main.url(forResource: path, withExtension: "scn") : Bundle.main.url(forResource: path, withExtension: "dae")
        
        guard let sceneURL = sURL, let source = SCNSceneSource(url: sceneURL, options: nil) else {
            throw GridLoadingError.invalidSceneName(sceneName)
        }
        
        try self.init(source: source)
    }
    
    init?(source: SCNSceneSource) throws {
        self.source = source
        
        let soureRootNode: SCNNode
        soureRootNode = try! source.scene(options: nil).rootNode
        
        guard let baseGridNode = soureRootNode.childNode(withName: GridNodeName, recursively: true) else {
            throw GridLoadingError.missingGridNode(GridNodeName)
        }
        gridWorld = GridWorld(node: baseGridNode)
        
        super.init()
    }
    
    // MARK: Initial
    init(world: GridWorld) {
        gridWorld = world
        // load template scene.
        let templatePath = ""
        let templateURL = Bundle.main.url(forResource: templatePath, withExtension: "dae")!
        source = SCNSceneSource(url: templateURL, options: nil)!
    }

    
}


