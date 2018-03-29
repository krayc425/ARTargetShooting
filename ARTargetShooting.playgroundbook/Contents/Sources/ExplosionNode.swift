//
//  ExplosionNode.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit

public class ExplosionNode: SCNNode {
    
    public init(targetNode: TargetNode) {
        super.init()
        
        let particleSystem = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)
        particleSystem?.particleColor = targetNode.typeColor
        
        self.addParticleSystem(particleSystem!)
        self.position = targetNode.presentation.position
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

