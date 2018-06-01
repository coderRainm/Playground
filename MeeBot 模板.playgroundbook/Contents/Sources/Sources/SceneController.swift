//
//  SceneController.swift
//  JimuPlaygroundBook
//
//  Created by hechao on 2016/12/26.
//  Copyright © 2016年 UBTech Inc. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation
import PlaygroundSupport
import MediaPlayer

import CoreBluetooth
import PlaygroundBluetooth


class SceneController: UIViewController {
    
    // MARK: Properties
    let scene: Scene
    
    let scnView = SCNView()
    
    var cameraController: CameraController?
    
    // control buttons
    let lightButton = UIButton(type: .custom)
    
    let audioButton = UIButton(type: .custom)
    
    var labelMeeBotDescription = UILabel()
    
    var playgroundBluetoothConnectionView:PlaygroundBluetoothConnectionView!
    lazy var connecting = false
    lazy var starting = false
    
    // loadingQueue
    let loadingQueue = OperationQueue()
    
    // Audio menu
    var audioMenu:AudioMenuController?
    
    /// audioPlayer
    var audioPlayer:AVAudioPlayer?
    var isPlaying: Bool?
    lazy var loadingView = UIImageView(frame:CGRect(x:0, y:0, width:100, height:100))
    /// MPMusicPlayerController 
    let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    
    // song file name
    lazy var buildInSongArray = [musicIntro, musicBitBitLoop]
    lazy var songArray = [musicIntro, musicBitBitLoop, /*musicSpikey, musicPumpedup*/]
    lazy var curentBPM:UInt = 120
    var curentMusic:String?
    var bpmOfMySong:UInt?
    
    
    // lights file name
    lazy var lightArray = ["Light1","Light2","Light3"]
    
    // Persisted data
    var isAudioOpen = Persisted.isBackgroundAudioEnabled {
        didSet {
            self.updateLiveViewOverallAccessibility()
        }
    }
    
    var isLightOn = Persisted.isBackgroundLightEnabled
    
    // logs
    lazy var logView = UITextView(frame:CGRect(x:0,y:0,width:250,height:450))
    let logDateFormat = DateFormatter()
    
    /// lesson
    var userLesson: Lesson?
    var lessonThirdHaveDance = false
    
    /// Guide button
    let guideBtn = UIButton(type: .custom)
    
    /// BPM
    let lesson4BPM = UILabel()
    let bmpViewContainer = UIView()
    
    /// command & animation
    var running = false {
        didSet {
            self.updateLiveViewOverallAccessibility()
        }
    }
    
    var currentAction:Action?
    lazy var servoAngles = [Action:[[UInt8]]]()
    lazy var animations = [Action:[[String:[Double]]]]()
    var animationTimer:Timer?
    var animationTimeStamp = 0.0
    
    // Light Timer
    var lightTimer: Timer?
    
    // Animation Test button(only for test)
    var testButton = UIButton(type: .custom)
    
    // MARK: Initialization
    
    init(scene: Scene , _ lesson: Lesson = .lessonNone) {
        self.scene = scene
        
        super.init(nibName: nil, bundle: nil)
        // Register as the delegate to update with state changes. See SceneController+StateChanges.swift
        scene.delegate = self
        
        // Config each page
        userLesson = lesson
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This method has not been implemented.")
    }
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Config log format
        logDateFormat.dateFormat = "ss:SSS"
        
        // Add SCNView to controller view
        addViews()
        
        Meebot.shared.delegate = self
        playgroundBluetoothConnectionView = PlaygroundBluetoothConnectionView(centralManager: Meebot.shared.getCentralManager())
        playgroundBluetoothConnectionView.delegate = self
        playgroundBluetoothConnectionView.dataSource = self
        
        loadingQueue.addOperation { [weak self] in
            /// Load the `SCNScene`.
            guard let scene = self?.scene.scnScene else { return }
            
            DispatchQueue.main.async {
                self?.scnView.scene = scene
                
                // load geometries such as camera, lights & actor
                self?.addGeomtries()
                
                self?.sceneDidLoad(scene)
            }
        }
        
        
        ///
        scnView.contentMode = .center
        configureViewForDevice()
        
        // Controls
        addControlButtons()
        view.addSubview(loadingView)
        loadingView.image = UIImage(named: "Images/big_spin")
        loadingView.isUserInteractionEnabled = false
        let ca = CABasicAnimation(keyPath: "transform.rotation.z")
        ca.toValue = Double.pi * 2
        ca.repeatCount = HUGE
        ca.duration = 1
        loadingView.layer.add(ca, forKey: "rotation")
        loadingView.isHidden = true
        // Command has finished excuting and its feedback
        loadAnimations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func applicationDidEnterBackground() {

        pauseAudioIfAppEnterBackground()
    }
    
    func applicationWillEnterForeground() {
        
        // play audio
        lessonConfig(lesson:userLesson!)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Layout
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        loadingView.center = view.center
        cameraController?.resetCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

       // setVoiceOverForCurrentStatus(forceLayout: true)
    }
    
    
    // MARK: Internal Methods
    
    /// Adds the `scnView` and `posterImageView`.
    private func addViews() {
        scnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scnView)
        scnView.frame = view.bounds
        scnView.backgroundColor = UIColor.clear
        
        // Debug logView
        if MACRO_DEBUG {
            self.view.addSubview(logView)
            logView.scrollsToTop = true
            logView.textColor = .red
            logView.backgroundColor = .lightGray
            logView.alpha = 0.8
            logView.isHidden = !MACRO_DEBUG
        }
        
        if MACRO_DEBUG {
            scnView.showsStatistics = true
        }
        
    }
    
    /// Add geomtries to the scene view
    private func addGeomtries() {
        // Get root node
        let rootNode = scnView.scene?.rootNode
        
        
        // Get geometries root node
        /// actor
        let actorNode = getRootNodeWithSceneName(sceneName: "Meebot")
        actorNode.name = "Meebot"
        actorNode.scale = SCNVector3Make(1.5, 1.5, 1.5)
        rootNode?.addChildNode(actorNode)
        
        /// lights effect nodes
        for lightName in lightArray {
            let lightNode = getRootNodeWithSceneName(sceneName: lightName)
            lightNode.name = lightName
            lightNode.position = SCNVector3Make(0, 0, 0)
            lightNode.isHidden = true   // default
            lightNode.scale = SCNVector3(x:1, y:1, z:1)
            rootNode?.addChildNode(lightNode)
        }
        
        
        // Add real light node
        let customlightNode = SCNNode()
        let light = SCNLight()
        light.shadowColor = UIColor.red
        light.type = .ambient
        customlightNode.light = light
        customlightNode.light?.color = UIColor.clear
        customlightNode.name = "lightNode"
        customlightNode.position = SCNVector3Make(0, 375, 0)
        rootNode?.addChildNode(customlightNode)
        
        // Add audience node
        let audienceNode = getRootNodeWithSceneName(sceneName: "Audience")
        audienceNode.name = "Audience"
        rootNode?.addChildNode(audienceNode)
        
        // only for test
        if MACRO_DEBUG {
//            appluse()
//            confetti()
        }
    }
    
    fileprivate func sound(named: String) -> SCNAudioSource? {
        guard let url = Bundle.main.url(forResource: named, withExtension: "mp3") else {
            return nil
        }
        
        return SCNAudioSource(url: url)
    }
    
    // MARK: Node
    fileprivate func getRootNodeWithSceneName(sceneName: String) -> SCNNode {
        var node = SCNNode()
        
        let path = "WorldResources.scnassets/_Scenes/" + sceneName
        guard let sceneURL = Bundle.main.url(forResource: path, withExtension: "scn"),
            let source = SCNSceneSource(url: sceneURL, options: nil) else {
                return node
        }
        
        do {
            let sourceScene = try source.scene()
            node = sourceScene.rootNode
        }
        catch {
            fatalError("Failed to Load Scene.\n \(error)")
        }
        
        return node
    }
    
    /// get the node by its name
    fileprivate func getNodeWithName(name: String) -> SCNNode? {
        return (scnView.scene?.rootNode)!.childNode(withName: name, recursively: false)
    }

    
    // MARK: sceneDidLoad
    /// Called after the scene has been manually assigned to the SCNView.
    private func sceneDidLoad(_: SCNScene) {
        // Now that the scene has been loaded, trigger a
        // verification pass.
        scene.state = .built
        
        // Set controller after scene has been initialized on `scnView`.
        cameraController = CameraController(view: scnView)
        
        if userLesson == .lesson9 {
            
            // Persisted current lesson is last
            Persisted.isLastLesson = true
            
            // music From Lib
            if let music = Persisted.musicNameFromLib {
                self.songArray.append(music)
            }
        } else {
            Persisted.isLastLesson = false
        }

        // Lesson Configurations
        lessonConfig(lesson:userLesson!)
     }
    
    /// config view
    func configureViewForDevice() {
        // Grab the device from the scene view and interrogate it.
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            // Setup for the sim
            scnView.contentScaleFactor = 1.5
            scnView.preferredFramesPerSecond = 30
        #else
            if let defaultDevice = scnView.device,
                defaultDevice.supportsFeatureSet(.iOS_GPUFamily2_v2) {
                scnView.antialiasingMode = .multisampling2X
            }
        #endif
    }

    /// Gesture
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if (presentedViewController as? GuideViewController) != nil{
            return
        }
        if let pc = presentedViewController{
            pc.dismiss(animated: true, completion: nil)
        }
    }

    /// Debug log
    func log(_ log:String, line:Int) {
        logView.text = "\(logView.text ?? "")\n\(logDateFormat.string(from: Date())) \(line): \(log)"
        NSLog("\(line) \(log)")
    }
    
    
    // MARK: Lesson configurations for each lesson
    
    func lessonConfig(lesson: Lesson) {
        switch lesson {
        case .lesson1, .lesson2, .lesson3, .lesson4 :
            showControlButton(show: false)
            self.isAudioOpen = false
            
        case .lesson5, .lesson6, .lesson7, .lesson8, .lesson9 :
            showControlButton(show: true)
            playAudioIfAudioIsOpen()
            
        default:
            break
        }
    }
}


// MARK: Finished coding effects
extension SceneController {
    
    // Audience applause
    func appluse(){
        
        self.play(songName: musicApplause10s)
        //        let audioNode = SCNNode()
        //        audioNode.name = "audioPlayerNode"
        //
        //        guard let audienceNode = getNodeWithName(name: "Audience") else {
        //            return
        //        }
        //        audienceNode.addChildNode(audioNode)
        //
        //        guard let source = self.sound(named: "Audios/applause_10s") else {
        //            return
        //        }
        //        let player = SCNAudioPlayer(source: source)
        //        audioNode.addAudioPlayer(player)
        //
        //        let play = SCNAction.playAudio(source, waitForCompletion: true)
        //        audioNode.runAction(play) {
        //            audioNode.removeFromParentNode()
        //        }
    }
    
    // Particle system
    func confetti() {
        
        let rainParticleNode = SCNNode()
        rainParticleNode.name = "ConfettiNode"
        rainParticleNode.position = SCNVector3(x:0, y:800, z:0)
        
        guard let actorNode = getNodeWithName(name: "Meebot") else {
            return
        }
        // Create particle system
        guard let rainParticleSystem = SCNParticleSystem(named: "Particle/Confetti.scnp", inDirectory: nil) else {
            fatalError("Confetti particle file is not exsit")
        }
        rainParticleNode.addParticleSystem(rainParticleSystem)
        actorNode.addChildNode(rainParticleNode)
        rainParticleSystem.particleAngularVelocity = 90
        rainParticleSystem.particleImage = UIImage(named: "Particle/Confetti")

        removeConfettiNode()
    }
    
    func removeConfettiNode() {
        
        let delaySeconds = 0.1
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delaySeconds, execute: {
            if let confettiNode = self.getNodeWithName(name: "ConfettiNode") {
                confettiNode.removeFromParentNode()
            }
        })
    }
    
    // Rotate to see the audience
    func rotateToSeeAudience() {
        
        cameraController?.performFlyover(withRotation: SCNFloat(-Double.pi), duration: 3)
        cameraController?.zoomCamera(toYFov: 20, duration: 5, completionHandler: {
            self.cameraController?.resetCamera()
        })
    }
    
}

// MARK: SceneController Accessibility

extension SceneController {
    
    func registerForAccessibilityNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(voiceOverStatusChanged), name: Notification.Name(rawValue: UIAccessibilityVoiceOverStatusChanged), object: nil)
    }
    
    func unregisterForAccessibilityNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: UIAccessibilityVoiceOverStatusChanged), object: nil)
    }
    
    func voiceOverStatusChanged() {
        DispatchQueue.main.async {
            self.setVoiceOverForCurrentStatus(forceLayout: true)
        }
    }
    
    /**
     Configures the scene to account for the current VoiceOver status.
     - parameters:
     - forceLayout: Passing `true` will force the accessibility elements
     to be recalculated for the current grid.
     */
    func setVoiceOverForCurrentStatus(forceLayout: Bool = false) {
        // Ensure the view is loaded and the `characterPicker` is not presented.
        
        
        if UIAccessibilityIsVoiceOverRunning() {
            scnView.gesturesEnabled = false
            
            // Lazily recompute the `accessibilityElements`.
            if forceLayout || view.accessibilityElements?.isEmpty == true {
                
                let container = configureAccessibilityElementsForGrid()
                
                // Add buttons because we've removed the default elements.
                view.accessibilityElements?.append(audioButton)
                
                UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, container)
            }
            
            
            
            // Add custom actions to provide details about the world.
            accessibilityCustomActions = [
                UIAccessibilityCustomAction(name: NSLocalizedString("Character Locations", comment: "AX action label"), target: self, selector: #selector(announceCharacterLocations)),
                UIAccessibilityCustomAction(name: NSLocalizedString("Goal Locations", comment: "AX action label"), target: self, selector: #selector(announceGoalLocations)),
            ]
            
            // Add an action for random items only when there are random items.
            
        }
        else {
            scnView.gesturesEnabled = true
            
        }
    }
    
    private func configureAccessibilityElementsForGrid() -> UIAccessibilityElement {
        view.isAccessibilityElement = false
        view.accessibilityElements = []
        
        
        let container = UIAccessibilityElement(accessibilityContainer: scnView)
        container.accessibilityFrame = scnView.bounds
        view.accessibilityElements?.append(container)
        
        return container
    }
    
    // MARK: Custom Actions
    func announce(speakableDescription: String) {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, speakableDescription)
    }
    
    func announceCharacterLocations() -> Bool {
        announce(speakableDescription: "我是中国人")
        return true
    }
    
    func announceGoalLocations() -> Bool {
        announce(speakableDescription: "我是地球人")
        return true
    }
}
