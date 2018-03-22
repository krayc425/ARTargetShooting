//
//  SCNNodeExtension.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/22.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    func playSound(_ type: SoundType) {
        self.runAction(SCNAction.playAudio(SoundHelper.shared.loadSound(of: type), waitForCompletion: false))
    }
    
}
