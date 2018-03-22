//
//  SoundHelper.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/22.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import Foundation
import SceneKit

enum SoundType: String {
    case shoot
    case hit
}

class SoundHelper: NSObject {
    
    static let shared: SoundHelper = SoundHelper()
    
    private var soundCache: [SoundType: SCNAudioSource] = [:]
    
    private override init() {
        
    }
    
    func loadSound(of type: SoundType) -> SCNAudioSource {
        if let sound = soundCache[type] {
            return sound
        } else {
            let sound = SCNAudioSource(fileNamed: type.rawValue + ".mp3")!
            soundCache[type] = sound
            sound.load()
            
            switch type {
            case .hit:
                sound.volume = 1.0
            case .shoot:
                sound.volume = 0.85
            }
            return sound
        }
    }
    
}
