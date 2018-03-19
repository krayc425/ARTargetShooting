//
//  TargetNode.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit

class TargetNode: SCNNode {

    override init() {
        super.init()
        
        let cylinder = SCNCylinder(radius: 0.2, height: 0.02)
        self.geometry = cylinder
        
        let shape = SCNPhysicsShape(geometry: cylinder, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.mass = 0.5
        
        self.physicsBody?.categoryBitMask = CollisionCategory.target.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.bullet.rawValue
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.random()
        self.geometry?.materials  = Array<SCNMaterial>(repeating: material, count: 6)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
