//
//  SceneController+StateChange.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//
import SceneKit
import AVFoundation
import PlaygroundSupport
import MediaPlayer

enum MusicSong: String{
    
    case Intro = "Intro"
    case Bit_Bit_Loop = "Bit Bit Loop"
    case Spikey = "Spikey"
    case Pumped_up_kicks = "Pumped up kicks"
}

extension SceneController {

    enum PlayerType {
        case AVaudioPlayer
        case MPmusicPlayer
    }
    
    func getDurationFromBPM(_ BPM:UInt = 100,beats: Double = 1.0) -> Double {
        return ((60.0/Double(BPM)) * 1000) * Double(beats)
    }
    var bpm:UInt {
        liveLog("\(audioPlayer?.isPlaying)  \(isCurrentBuiltInMusic)  \(bpmOfMySong)")
        if isCurrentBuiltInMusic {
            return audioPlayer?.isPlaying ?? false ? curentBPM : 100
        }else{
            if let b = bpmOfMySong {
                return b
            }else{
                return 100
            }
        }
    }
    
    var music:String {
        return audioPlayer?.isPlaying ?? false ? curentMusic == nil ? "nil" : curentMusic! : "nil"
    }
    
    var isCurrentBuiltInMusic:Bool{
        if let c = curentMusic {
            return buildInSongArray.contains(c)
        }
        return false
    }
    
    func play(songName: String, _ type: PlayerType = .AVaudioPlayer) {
        
        switch type {
            
        case .AVaudioPlayer:
            
            let s = "Audios/" + songName
            let aacUrl = Bundle.main.url(forResource: s, withExtension: "aac")
            let m4aUrl = Bundle.main.url(forResource: s, withExtension: "m4a")
            let mp3Url = Bundle.main.url(forResource: s, withExtension: "mp3")
            
            // Support more audio format such as .acc, .m4a, .mp3
            if let url = (aacUrl != nil) ? aacUrl : ((m4aUrl != nil) ? m4aUrl :mp3Url){
                audioPlayer = try? AVAudioPlayer(contentsOf: url)
                
                // player rate
                audioPlayer?.enableRate = true
                audioPlayer?.rate = Float(1/timeScale)
                
                audioPlayer?.delegate = self
                audioPlayer?.play()
           
                // get current song by name
                let index = songArray.index(of: songName)
                
                if songName != musicApplause10s {
                    currentMusic = songName
                    
                    // Show BPM value
                    showBMPValueOfMusic(songName: songName)
                    
                    // Update bpm value
                    sendCommand(._notif, variables:["\(self.bpm)", "\(self.music)"])
                }
            }

            
        case .MPmusicPlayer:
            
            audioPlayer?.stop()
            
            // Get authorized first before playing those music from lib
            self.getAuthorizedBeforePlayingMusic(name:songName)
            
            // get current song by name
            let index = songArray.index(of: songName)
            print("song index = \(String(describing: index))")
            if songName != musicApplause10s {
                currentMusic = songName
            }
            
            // Show BPM value
            showBMPValueOfMusic(songName: songName)
                
            // Update bpm value
            sendCommand(._notif, variables:["\(self.bpm)", "\(self.music)"])
            
        }
        
    }
    
    func playMusic() {
        
        if self.isAudioOpen {
            if let music = currentMusic {
                if buildInSongArray.contains(music) {
                    self.play(songName: music)
                } else {
                    self.play(songName: music, .MPmusicPlayer)
                }
            }
        }
    }
    
    func pause(_ type: PlayerType = .AVaudioPlayer) {
        isPlaying = false

        switch type {
        case .AVaudioPlayer:
            
            audioPlayer?.pause()
            audioPlayer = nil
            
        case .MPmusicPlayer:
            musicPlayer.pause()
        }

        curentMusic = nil
        sendCommand(._notif, variables:["\(self.bpm)", "\(self.music)"])
    }
    
    func stop(_ type: PlayerType = .AVaudioPlayer) {
        isPlaying = false

        switch type {
        case .AVaudioPlayer:
            
            audioPlayer?.stop()
            audioPlayer = nil
            
        case .MPmusicPlayer:
            musicPlayer.stop()
        }

//        bmpViewContainer.isHidden = true
        curentMusic = nil
        sendCommand(._notif, variables:["\(self.bpm)", "\(self.music)"])
    }
    
    private func showBMPValueOfMusic(songName: String) {
        curentMusic = songName
        var shouldAnnouceBpm = true
        if songName == MusicSong.Intro.rawValue {
            curentBPM = 60
        } else if songName == MusicSong.Bit_Bit_Loop.rawValue {
            curentBPM = 120
        } else if songName == MusicSong.Spikey.rawValue {
            curentBPM = 140
        } else if songName == MusicSong.Pumped_up_kicks.rawValue {
            curentBPM = 100
        } else {
            curentBPM = Persisted.musicBPMFromLib   // music from lib
            shouldAnnouceBpm = false
        }
        
        //        bmpViewContainer.isHidden = false
        lesson4BPM.text = "BPM = "  + String(curentBPM)
        
        if shouldAnnouceBpm {
            var accessibilityString = String(format: NSLocalizedString("The BPM of currently playing music is %d", comment: "Accessibility announcement for current song BPM"), curentBPM)
            liveLog(accessibilityString)
            self.announce(speakableDescription: accessibilityString)
        }
    }

    
    
    /// Get authorized before playing music
    func getAuthorizedBeforePlayingMusic(name: String) {
        
        if MPMediaLibrary.authorizationStatus() == .authorized {
            // success:
            self.authorizedBlock(songName: name)
        } else {
            MPMediaLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized:
                    // success:
                    self.authorizedBlock(songName: name)
                    
                case .denied: fallthrough
                case .notDetermined: fallthrough
                case .restricted:
                    // failed
                    self.unAuthorizedBlock()
                }
            })
        }
    }
    
    func authorizedBlock(songName: String) {
        //
        // Make sure the music is still in music lib
        guard let items = getMediaItem() else { return }
        if isCurrentMusicInMusicLib(name: songName, items: items) {
            // exsit
            if isMusicPlayerPlaylistEmpty() {
                createMediaQuery(name: songName, items: items)
            }
        } else {
            // not exsit
            showMusicNotFoundException()
            // remove the music
            self.songArray.removeLast()
            
            return
        }
        
        if self.isAudioOpen {
            musicPlayer.skipToBeginning()
            musicPlayer.play()
        }
    }
    
    func unAuthorizedBlock() {
        //
        return
    }


}

extension SceneController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        sendCommand(._notif, variables:["\(self.bpm)", "\(self.music)"])
//        if userLesson == .lesson4 || userLesson == .lesson6 && curentBPM == 80 {
//            Persisted.isBackgroundAudioEnabled = true
//            self.isAudioOpen = true
//            self.play(songName:musicIntro)
//        }
//
//        send(PlaygroundValue.boolean(false))
        
        if flag == true {
            
            // loop playback
            guard let current = currentMusic else {
                return
            }
            let index = songArray.index(of: current)
            let next = (index! + 1) % songArray.count
            
            // update menu
            audioMenu?.updateSelectedCell(index: next)
            
            if self.isAudioOpen {
                // play next audio
                if next < buildInMusicCount {
                    play(songName: songArray[next])
                } else {
                    play(songName: songArray[next], .MPmusicPlayer)
                }
            }
        }

    }
}

extension SceneController {
    
    func isMusicPlayerPlaylistEmpty() -> Bool {
        
        if musicPlayer.indexOfNowPlayingItem == NSNotFound {
            return true
        }
        else {
            return false
        }
    }
    
    func getMediaItem() -> [MPMediaItem]? {
        //
        return MPMediaQuery.songs().items
    }
    
    func createMediaQuery(name: String, items: [MPMediaItem]) {
        //
        for item in items {
            
            if item.title == name {
                musicPlayer.setQueue(with: MPMediaItemCollection(items:[item]))
            }
        }
    }
    
    func isCurrentMusicInMusicLib(name: String, items: [MPMediaItem]) -> Bool {
        //
        for item in items {
            if item.title == name{
                return true
            }
        }
        
        return false
    }
    
    func showMusicNotFoundException() {
        //
        let alertTips = "Current music is not exist in music lib"
        
        let alert = UIAlertController(title: NSLocalizedString("Tip", comment: "提示"), message: alertTips, preferredStyle:.alert)
        let ac = UIAlertAction(title: NSLocalizedString("OK", comment: "确认"), style: .default, handler: nil)
        alert.addAction(ac)
        self.present(alert, animated: true, completion: nil)
    }
}





