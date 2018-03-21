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

    private var score: Int = 1
    var hit: Bool = false
    var hitScore: Int {
        get {
            return hit ? 0 : score
        }
    }
    
    override init() {
        super.init()
        
        let cylinder = SCNCylinder(radius: 0.2, height: 0.02)
        self.geometry = cylinder
        
        let shape = SCNPhysicsShape(geometry: cylinder, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = true
//        self.physicsBody.
        self.physicsBody?.mass = 0.15
        
        self.physicsBody?.categoryBitMask = CollisionCategory.target.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.bullet.rawValue
        
        let material = SCNMaterial()
        let n = arc4random() % 5
        if n == 1 {
            score = 3
            material.diffuse.contents = #imageLiteral(resourceName: "target-high")
        } else {
            score = 1
            material.diffuse.contents = #imageLiteral(resourceName: "target")
        }
        let anotherMaterial = SCNMaterial()
        anotherMaterial.diffuse.contents = UIColor.clear
        self.geometry?.materials = [material, material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
