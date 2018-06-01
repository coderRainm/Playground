//
//  File.swift
//  PlaygroundScene
//
//  Created by Chao He on 2017/2/27.
//  Copyright © 2017年 UBTech Inc. All rights reserved.
//
import UIKit
import AVFoundation
import SceneKit
import PlaygroundSupport
import MediaPlayer


/// An indication that the conforming type functions as a control element in the
/// `SceneController`.
protocol WorldControl {}

extension SceneController: PlaygroundLiveViewSafeAreaContainer {
    
    // MARK: Overlay view

    internal class OverlayView: UIView, WorldControl {
        
        init() {
            let blurEffect = UIBlurEffect(style: .extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.layer.cornerRadius = 22
            blurEffectView.clipsToBounds = true
            blurEffectView.translatesAutoresizingMaskIntoConstraints = true
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            super.init(frame: CGRect.zero)
            
            addSubview(blurEffectView)
            blurEffectView.frame = bounds
            
            let whiteOverBlurView = UIView()
            whiteOverBlurView.translatesAutoresizingMaskIntoConstraints = true
            whiteOverBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            addSubview(whiteOverBlurView)
            whiteOverBlurView.frame = bounds
      
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    // MARK: Layout constants
    
    struct ControlLayout {
        static let verticalOffset: CGFloat = 18
        static let height: CGFloat = 44
        static let width: CGFloat = 44
        static let edgeOffset: CGFloat = 20
    }
    
    func generateMeeBotLiveViewAccessibilityString() -> String {
        var accessibilityString = ""
        
        var meebotDescription = NSLocalizedString("MeeBot is standing at the center of the dance stage with a red curtain in the background.", comment: "Live View MeeBot accessibility")
        if self.running {
            meebotDescription = NSLocalizedString("MeeBot is dancing on the stage with a red curtain in the background.", comment: "Live View overall accessibility")
        }
        
        var lightsDescription = NSLocalizedString("Stage lights are off.", comment: "Live View lights accessibility")
        
        if self.isAudioOpen {
            lightsDescription = NSLocalizedString("Stage lights are on.", comment: "Live View lights accessibility")
        }
        
        accessibilityString = String(format: "%1$@ %2$@", meebotDescription, lightsDescription)
        
        liveLog(accessibilityString)
        
        return accessibilityString
    }

    func updateLiveViewOverallAccessibility() {
        self.labelMeeBotDescription.accessibilityLabel = self.generateMeeBotLiveViewAccessibilityString()
    }
    
    // MARK: Control buttons
    func addControlButtons() {
        self.labelMeeBotDescription = UILabel()
        self.labelMeeBotDescription.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        self.labelMeeBotDescription.text = ""
        self.labelMeeBotDescription.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.updateLiveViewOverallAccessibility()
        view.addSubview(labelMeeBotDescription)
        
        // Light button
        let lightContainer = OverlayView()
        view.addSubview(lightContainer)
        lightContainer.isHidden = true
        
        lightContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lightContainer.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: ControlLayout.verticalOffset),
            lightContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(2*ControlLayout.width + 3 * ControlLayout.edgeOffset)),
            lightContainer.heightAnchor.constraint(equalToConstant: ControlLayout.height),
            lightContainer.widthAnchor.constraint(equalToConstant: ControlLayout.width)
            ])
        
        updateLightButtonImage()
        lightButton.imageView?.contentMode = .scaleAspectFit
        lightButton.translatesAutoresizingMaskIntoConstraints = true
        lightButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        lightButton.addTarget(self, action: #selector(adjustLightAction(_:)), for: .touchUpInside)
        lightContainer.addSubview(lightButton)
        
        // Audio button
        let audioContainer = OverlayView()
        view.addSubview(audioContainer)
        
        audioContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioContainer.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: ControlLayout.verticalOffset),
            audioContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: ControlLayout.edgeOffset),
            audioContainer.heightAnchor.constraint(equalToConstant: ControlLayout.height),
            audioContainer.widthAnchor.constraint(equalToConstant: ControlLayout.width)
            ])
        
        updateAudioButtonImage()
        audioButton.imageView?.contentMode = .scaleAspectFit
        audioButton.translatesAutoresizingMaskIntoConstraints = true
        audioButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        audioButton.accessibilityLabel = NSLocalizedString("Music Menu", comment: "Music Menu Button")
        
        audioButton.addTarget(self, action: #selector(adjustAudioAction(_:)), for: .touchUpInside)
        audioContainer.addSubview(audioButton)
       
        
        // Bluetooth
        // playgroundBluetoothConnectionView
        let topConstraint = playgroundBluetoothConnectionView.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: ControlLayout.verticalOffset)
        let horizontalConstraint = playgroundBluetoothConnectionView.trailingAnchor.constraint(equalTo: liveViewSafeAreaGuide.trailingAnchor, constant: -ControlLayout.edgeOffset)
        view.addSubview(playgroundBluetoothConnectionView)
        NSLayoutConstraint.activate([topConstraint, horizontalConstraint])

        // TODO add battery level using this code
//        playgroundBluetoothConnectionView.setBatteryLevel(0.8, peripheral)
        
        // Guide Button
        guideBtn.frame = CGRect(x: 200, y: 300, width: 10, height: 10)
        guideBtn.layer.cornerRadius = 5
        guideBtn.isHidden = true
        guideBtn.backgroundColor = UIColor.red
        view.addSubview(guideBtn)
        
        NSLayoutConstraint.activate([
            guideBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            guideBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            guideBtn.heightAnchor.constraint(equalToConstant: 10),
            guideBtn.widthAnchor.constraint(equalToConstant: 10)
            ])
        
        
        // BPM Value Label
        view.addSubview(bmpViewContainer)
        bmpViewContainer.backgroundColor = UIColor(red: 0.2745098,
                                                   green: 0.36470588,
                                                   blue: 0.38039216,
                                                   alpha: 0.8) // 70, 93, 97, 80%
        bmpViewContainer.translatesAutoresizingMaskIntoConstraints = false
        bmpViewContainer.layer.cornerRadius = 11.0
        bmpViewContainer.isHidden = true
        
        NSLayoutConstraint.activate([
            bmpViewContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: (ControlLayout.width + 2 * ControlLayout.edgeOffset)),
            bmpViewContainer.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 18),
            bmpViewContainer.heightAnchor.constraint(equalToConstant: ControlLayout.height),
            bmpViewContainer.widthAnchor.constraint(equalToConstant: 100)
            ])
        
        lesson4BPM.frame = CGRect(x: 0, y: 0, width: 100, height: ControlLayout.height)
        lesson4BPM.textAlignment = .center
        lesson4BPM.textColor = UIColor.white
        bmpViewContainer.addSubview(lesson4BPM)
        
        
        // only for test
        if MACRO_DEBUG {
            testButton.backgroundColor = UIColor.white
            testButton.layer.cornerRadius = 20
            testButton.frame = CGRect(x:80, y: 80, width: 40, height: 40)
            testButton.addTarget(self, action: #selector(testButtonClick), for: .touchUpInside)
          //  view.addSubview(testButton)
            testButton.isHidden = !MACRO_DEBUG
        }
    }
    
    // only for test
    func testButtonClick() {
        //
        let path = "WorldResources.scnassets/_Scenes/tiaowu4_Amin"
        
        guard let sceneURL = Bundle.main.url(forResource: path, withExtension: "dae") else { return }
        guard let sceneSource = SCNSceneSource(url: sceneURL, options: [:]) else { return }
        let animationIdentifiers = sceneSource.identifiersOfEntries(withClass: CAAnimation.self)
        var longAnimations = [CAAnimation]()
        var maxDuration:CFTimeInterval = 0;
        for identifier in animationIdentifiers {
            if let animation = sceneSource.entryWithIdentifier(identifier, withClass: CAAnimation.self){
                maxDuration = max(maxDuration,animation.duration)
                longAnimations.append(animation)
            }
        }
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = longAnimations;
        animationGroup.duration = maxDuration
        animationGroup.repeatCount = 1
        let modelNode = scnView.scene?.rootNode.childNode(withName: "Meebot", recursively: true);
        modelNode?.addAnimation(animationGroup, forKey: "walk_key")
    }
    
    // MARK: Control button Actions
    func adjustLightAction(_ button: UIButton) {
        
        // Dismiss a previous presented `AudioMenuController`.
        if let vc = presentedViewController as? LightMenuController {
            vc.dismiss(animated: true, completion: nil)
            return
        }else{
            if let pc = presentedViewController{
                pc.dismiss(animated: true, completion: nil)
            }
            let menu = LightMenuController(tableTitle: "切换灯光", dataArray: lightArray)
            menu.modalPresentationStyle = .popover
            menu.popoverPresentationController?.passthroughViews = [view]
            
            menu.popoverPresentationController?.permittedArrowDirections = .up
            menu.popoverPresentationController?.sourceView = button
            
            // Offset the popup arrow under the button.
            menu.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 5, width: 44, height: 44)
            
            menu.popoverPresentationController?.delegate = self
            menu.menuDelegate = self
            present(menu, animated: true, completion: nil)
            
            
        }
    }
    
    func adjustAudioAction(_ button: UIButton) {
        // Dismiss a previous presented `AudioMenuController`.

        if let vc = presentedViewController as? UINavigationController {
            vc.dismiss(animated: true, completion: nil)
            return
        }else{
            if let pc = presentedViewController{
                pc.dismiss(animated: true, completion: nil)
            }
            
            let title = NSLocalizedString("Play Music", comment: "Menu label")
            let audioMenuController = AudioMenuController(tableTitle: title, dataArray: songArray)
            audioMenuController.menuDelegate = self
            self.audioMenu = audioMenuController

            let navigationController = UINavigationController(rootViewController: audioMenuController)
            
            navigationController.modalPresentationStyle = .popover
            navigationController.popoverPresentationController?.passthroughViews = [view]
            
            navigationController.popoverPresentationController?.permittedArrowDirections = .up
            navigationController.popoverPresentationController?.sourceView = button
            
            // Offset the popup arrow under the button.
            navigationController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 5, width: 44, height: 44)
            
            navigationController.popoverPresentationController?.delegate = self
            audioMenuController.menuMusicPickerDelegate = self
            present(navigationController, animated: true, completion: nil)
            
        }
    }
    
    /// control light node
    func showLightNode(lightName: String, isShow: Bool) {
        
        /// Close all light effect
        for light in lightArray {
            guard let lightNode = scnView.scene?.rootNode.childNode(withName: light, recursively: false) else {
                return
            }
            lightNode.isHidden = true
        }

        /// Then open one of the light effects
        guard let lightNode = scnView.scene?.rootNode.childNode(withName: lightName, recursively: true) else {
            return
        }
        
        guard let realLightNode = scnView.scene?.rootNode.childNode(withName: "lightNode", recursively: true) else {
            return
        }
        
        if isShow {
            lightNode.isHidden = false
            realLightNode.isHidden = true  // false
            print("\(lightName) light is ON")
        }
        else {
            lightNode.isHidden = true
            realLightNode.isHidden = true
            print("\(lightName) light is OFF")
        }
    }
    
    /// show the control button
    func showControlButton(show: Bool) {
        ///
        
        if show {
            audioButton.isHidden = false
            lightButton.isHidden =  false
            audioButton.superview?.isHidden = false
            
        } else {
            audioButton.isHidden = true
            lightButton.isHidden =  true
            audioButton.superview?.isHidden = true
        }
    }
    
    
    
    /// flash lights at random
    func flashLightsAtRandom(beats: TimeInterval) {
        
        if lightTimer == nil {
            
            lightTimer = Timer.scheduledTimer(withTimeInterval: beats, repeats: true, block: { (Timer) in
                
                let lightCount = self.lightArray.count
                let index = Int(arc4random()) % lightCount
                let name = self.lightArray[index]
                self.showLightNode(lightName: name, isShow: true)
            })
        }
        
    }
    
    /// Stop Flash lights
    func stopFlashLights() {
        
        guard let timer = lightTimer else {
            return
        }
        
        // invalid timer
        if timer.isValid {
            lightTimer?.invalidate()
            lightTimer = nil
        }
        
        // close all the lights
        self.showLightNode(lightName: lightArray[0], isShow: false)
    }
}

extension SceneController: UIPopoverPresentationControllerDelegate {
    
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    /// Dismisses the audio menu if visible.
    func dismissAudioMenu() {
        dismiss(animated: true, completion: nil)
    }
    
    func dismissLightMenu() {
        if let vc = presentedViewController as? LightMenuController {
            vc.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: Audio Delegate
extension SceneController: AudioMenuControllerDelegate, LightMenuControllerDelegate, AudioMenuMusicPickerDelegate{

    /// Audio
    func enableAudioMenuSelect(_ isEnabled: Bool) {
        liveLog("enableAudioMenuSelect")
        // Persist the choice.
        Persisted.isBackgroundAudioEnabled = isEnabled
        updateAudioButtonImage()
        
        self.isAudioOpen = isEnabled
        
        if isEnabled {
            let songName = songArray[Int(Persisted.backgroudAudioSelectedIndex)]
            if buildInSongArray.contains(songName) {
                self.play(songName: songName)
            } else {
                self.play(songName: songName, .MPmusicPlayer)
            }
            
            // when music starts playing, flash light at random
            stopFlashLights()
            flashLightsAtRandom(beats: lightFlashInterval)
            
        } else {
            
            self.stop()
            self.pause(.MPmusicPlayer)
            
            
            // when music stop playing, stop flashing light
            stopFlashLights()
        }
        
    }
    
    func audioTableviewCellisSelect(index: Int) {
        liveLog("audioTableviewCellisSelect \(index)")
        if self.isAudioOpen {
            
            let songName = songArray[index]
            
            if buildInSongArray.contains(songName) {
                self.play(songName: songName)
            } else {
                self.play(songName: songName, .MPmusicPlayer)
            }

        }

    }
    
    
    /// Light
    func enableLightMenuSelect(_ isEnabled: Bool) {
        //
        print("LightMenuSelect-------------")
        // Persist the choice.
        Persisted.isBackgroundLightEnabled = isEnabled
        updateLightButtonImage()
        
        self.isLightOn = isEnabled
    
        // show light node
        let lightName = lightArray[Persisted.backgroudLightSelectedIndex]
        showLightNode(lightName: lightName, isShow: isEnabled)
        
    }
    
    func lightTableviewCellisSelect(index: Int) {
        if self.isLightOn {
            let lightName = lightArray[Persisted.backgroudLightSelectedIndex]
            showLightNode(lightName: lightName, isShow: true)
        }
        
    }
    
    // AudioMenuMusicPickerDelegate
    func mediaPickerDidPickMediaItem(mediaItemCollection: MPMediaItemCollection) {
        //
        if let item = mediaItemCollection.items.first, let musicName = item.title {
            if self.songArray.count < buildInMusicCount + 1 {
                self.songArray.append(musicName)
            }
            else {
                self.songArray.removeLast()
                self.songArray.append(musicName)
            }
            
            musicPlayer.setQueue(with: mediaItemCollection)
            
            if Persisted.backgroudAudioSelectedIndex == buildInMusicCount {
                musicPlayer.play()
            }
        }
    }
}

// MARK: Audio
extension SceneController {
    
    /// Changes the audio button image when audio is disabled.
    func updateAudioButtonImage(on: Bool = Persisted.isBackgroundAudioEnabled) {
        let image: UIImage?
        if on {
            image = UIImage(named: "Images/music_on")
        }
        else {
            image = UIImage(named: "Images/music_off")
        }
        
        audioButton.setImage(image, for: .normal)
    }
    
    ///
    func playAudioIfAudioIsOpen() {
        if self.isAudioOpen {
            let index = (Persisted.backgroudAudioSelectedIndex < songArray.count) ? Persisted.backgroudAudioSelectedIndex : 0
            let songName = songArray[index]
            
            if buildInSongArray.contains(songName) {
                self.play(songName: songName)
            } else {
                self.play(songName: songName, .MPmusicPlayer)
            }
            
            // Along with light
            flashLightsAtRandom(beats: lightFlashInterval)
        }
    }
    
    func pauseAudioIfAppEnterBackground() {
        
        if self.isAudioOpen {
            let index = (Persisted.backgroudAudioSelectedIndex < songArray.count) ?Persisted.backgroudAudioSelectedIndex : 0
            let songName = songArray[index]
            
            if buildInSongArray.contains(songName) {
                self.pause()
            } else {
                self.pause(.MPmusicPlayer)
            }
        }
    }
}

// MARK: Light
extension SceneController {
    
    /// Changes the audio button image when audio is disabled.
    func updateLightButtonImage(on: Bool = Persisted.isBackgroundLightEnabled) {
        let image: UIImage?
        if on {
            image = UIImage(named: "Images/light_on")
        }
        else {
            image = UIImage(named: "Images/light_off")
        }
        
        lightButton.setImage(image, for: .normal)
    }
    
    ///
    func showLightIfLightIsOpen() {
        
        let lightName = lightArray[Int(Persisted.backgroudLightSelectedIndex)]
        showLightNode(lightName: lightName, isShow: self.isLightOn)
    }
    
}
