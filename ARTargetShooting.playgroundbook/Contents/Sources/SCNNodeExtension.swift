//
//  SCNNodeExtension.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/22.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import Foundation
import SceneKit

public extension SCNNode {
    
    func playSound(_ type: SoundType) {
        SoundHelper.shared.playSound(of: type)
    }
    
}
