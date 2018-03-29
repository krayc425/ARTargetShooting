//
//  SoundHelper.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/22.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import Foundation
import SceneKit
import AudioToolbox

public enum SoundType: String {
    case shoot
    case hit
    case success
    case appear
}

public class SoundHelper: NSObject {
    
    public static let shared: SoundHelper = SoundHelper()
    
    private var soundIds: [SoundType: SystemSoundID] = [:]
    
    private override init() {
        for type in [SoundType.hit, SoundType.shoot, SoundType.success, SoundType.appear] {
            var soundID: SystemSoundID = 0
            let path = Bundle.main.path(forResource: type.rawValue, ofType: "wav")
            let baseURL = NSURL(fileURLWithPath: path!)
            AudioServicesCreateSystemSoundID(baseURL, &soundID)
            
            soundIds[type] = soundID
        }
    }
    
    public func playSound(of type: SoundType) {
        AudioServicesPlaySystemSound(soundIds[type]!)
    }
    
}


