//
//  ExplosionNode.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit

class ExplosionNode: SCNNode {
    
    init(targetNode: TargetNode) {
        super.init()
        
        let particleSystem = SCNParticleSystem(named: "art.scnassets/Explode.scnp", inDirectory: nil)
        particleSystem?.particleColor = targetNode.typeColor
        
        self.addParticleSystem(particleSystem!)
        self.position = targetNode.presentation.position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

