//
//  Persisted.swift
//  PlaygroundScene
//
//  Created by Chao He on 2017/3/1.
//  Copyright © 2017年 UBTech Inc. All rights reserved.
//

import PlaygroundSupport
import Foundation

enum Persisted {
    
    enum Key {
        
        static let backgroundAudio = "BackgroundAudioKey"
        
        static let backgroundLight = "BackgroundLightKey"
        
        static let backgroundAudioSelectedIndex = "BackgroundAudioSelectedIndex"
        
        static let backgroundLightSelectedIndex = "BackgroundLightSelectedIndex"
        
        static let musicFromLib = "musicFromLib"
        
        static let musicBPMFromLib = "musicBPMFromLib"
        
        static let lastLesson = "LastLesson"
    }
    
    static let store = PlaygroundKeyValueStore.current
    
    
    static func integer(forKey key: String) -> Int? {
        guard case let .integer(i)? = store[key] else { return nil }
        return i
    }
    
    static func string(forKey key: String) -> String? {
        guard case let .string(str)? = store[key] else { return nil }
        return str
    }
    
    static func bool(forKey key: String) -> Bool? {
        guard case let .boolean(i)? = store[key] else { return nil }
        return i
    }
    
    // MARK: Properties
    static var isBackgroundAudioEnabled: Bool {
        get {
            let enabled = Persisted.bool(forKey: Persisted.Key.backgroundAudio)
            return enabled ?? true
        }
        set {
            Persisted.store[Persisted.Key.backgroundAudio] = .boolean(newValue)
        }
    }
    
    static var backgroudAudioSelectedIndex: Int {
        get {
            let index = Persisted.integer(forKey: Persisted.Key.backgroundAudioSelectedIndex)
            return index ?? 0
        }
        set {
            Persisted.store[Persisted.Key.backgroundAudioSelectedIndex] = .integer(newValue)
        }
    }
    
    static var isBackgroundLightEnabled: Bool {
        get {
            let enabled = Persisted.bool(forKey: Persisted.Key.backgroundLight)
            return enabled ?? false
        }
        set {
            Persisted.store[Persisted.Key.backgroundLight] = .boolean(newValue)
        }
    }
    
    static var backgroudLightSelectedIndex: Int {
        get {
            let index = Persisted.integer(forKey: Persisted.Key.backgroundLightSelectedIndex)
            return index ?? 0
        }
        set {
            Persisted.store[Persisted.Key.backgroundLightSelectedIndex] = .integer(newValue)
        }
    }
    
    static var musicNameFromLib: String? {
        get {
            return Persisted.string(forKey: Persisted.Key.musicFromLib)
        }
        set {
            if let value = newValue {
                Persisted.store[Persisted.Key.musicFromLib] = .string(value)
            }
        }
    }
    
    static var musicBPMFromLib: UInt {
        get {
            if let v = Persisted.integer(forKey: Persisted.Key.musicBPMFromLib){
                if v < 0 {
                    return 100
                }
                return UInt(v)
            }
            return 100
        }
        set {
            var v = newValue
            if v > 1000 {
                v = 1000
            }
            Persisted.store[Persisted.Key.musicBPMFromLib] = .integer(Int(v))
        }
    }
    
    static var isLastLesson: Bool {
        get {
            let enabled = Persisted.bool(forKey: Persisted.Key.lastLesson)
            return enabled ?? false
        }
        set {
            Persisted.store[Persisted.Key.lastLesson] = .boolean(newValue)
        }
    }
    
}
