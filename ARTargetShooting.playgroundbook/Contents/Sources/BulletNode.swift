//
//  BulletNode.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit

public let bulletRadius: CGFloat = 0.075

public class BulletNode: SCNNode {
    
    public var hit: Bool = false
    
    public override init() {
        super.init()
        
        let sphere = SCNSphere(radius: bulletRadius)
        self.geometry = sphere
        
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.mass = 0.3
        self.physicsBody?.isAffectedByGravity = false
        
        self.physicsBody?.categoryBitMask = CollisionCategory.bullet.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.target.rawValue
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        self.geometry?.materials = [material]
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

