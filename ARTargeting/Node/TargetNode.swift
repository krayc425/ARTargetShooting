//
//  TargetNode.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit

let targetRadius: CGFloat = 0.2

enum CollisionCategory: Int {
    case floor  = 1
    case target = 2
}

enum TargetNodeTypeNum: Int {
    case normal
    case high
    case demon
    
    func getUIImageName() -> String {
        var str = ""
        switch self {
        case .normal:
            str = "normal"
        case .high:
            str = "high"
        case .demon:
            str = "demon"
        }
        return "target-\(str)"
    }
}

struct TargetNodeType {
    var score: Int = 1
    var color: UIColor = .normal
    var typeNum: TargetNodeTypeNum = .normal
    
    init(typeNum: TargetNodeTypeNum) {
        self.typeNum = typeNum
        switch typeNum {
        case .normal:
            score = 1
            color = .normal
        case .high:
            score = 3
            color = .high
        case .demon:
            score = -5
            color = .demon
        }
    }
}

class TargetNode: SCNNode {
    
    var type: TargetNodeType?
    var hit: Bool = false
    var hitScore: Int {
        get {
            return hit ? 0 : (type?.score ?? 0) * scoreMultiple
        }
    }
    var typeColor: UIColor {
        get {
            return type?.color ?? UIColor.clear
        }
    }
    var radius: CGFloat = targetRadius
    var scoreMultiple: Int = 1
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func generateTarget() -> TargetNode {
        let targetNode = TargetNode()
        
        let cylinder = SCNCylinder(radius: CGFloat(arc4random() % 10) / 50.0 + 0.1, height: targetRadius / 10.0)
        targetNode.geometry = cylinder
        
        let shape = SCNPhysicsShape(geometry: cylinder, options: nil)
        targetNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        targetNode.physicsBody?.isAffectedByGravity = true
        targetNode.physicsBody?.mass = 0.15
        
        targetNode.physicsBody?.categoryBitMask = 1
        targetNode.physicsBody?.collisionBitMask = 0
//            CollisionCategory.target.rawValue
//        targetNode.physicsBody?.contactTestBitMask = CollisionCategory.floor.rawValue
        
        let material = SCNMaterial()
        let n = arc4random() % 10
        if n <= 1 {
            targetNode.type = TargetNodeType(typeNum: .high)
            material.diffuse.contents = UIImage(named: "target-high")
        } else if n >= 8 {
            targetNode.type = TargetNodeType(typeNum: .demon)
            material.diffuse.contents = UIImage(named: "target-demon")
        } else {
            targetNode.type = TargetNodeType(typeNum: .normal)
            material.diffuse.contents = UIImage(named: "target-normal")
        }
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = targetNode.typeColor
        targetNode.geometry?.materials = [whiteMaterial, material, material]
        
        return targetNode
    }
    
    static func getSingleTarget(isTutorial: Bool) -> TargetNode {
        let targetNode = TargetNode()
        
        let cylinder = SCNCylinder(radius: targetRadius, height: targetRadius / 10.0)
        targetNode.geometry = cylinder
        
        let shape = SCNPhysicsShape(geometry: cylinder, options: nil)
        targetNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        targetNode.physicsBody?.isAffectedByGravity = !isTutorial
        targetNode.physicsBody?.mass = 0.15
        
        targetNode.physicsBody?.categoryBitMask = CollisionCategory.target.rawValue
        targetNode.physicsBody?.contactTestBitMask = CollisionCategory.floor.rawValue
        
        targetNode.type = TargetNodeType(typeNum: .normal)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "target-normal")
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = targetNode.typeColor
        targetNode.geometry?.materials = [whiteMaterial, material, material]
        
        return targetNode
    }
    
    static func generateSmallTarget(oldTarget: TargetNode) -> TargetNode {
        let newRadius = oldTarget.radius * 0.8
        let targetNode = TargetNode()
        
        let cylinder = SCNCylinder(radius: newRadius, height: targetRadius / 10.0)
        targetNode.geometry = cylinder
        
        let shape = SCNPhysicsShape(geometry: cylinder, options: nil)
        targetNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        targetNode.physicsBody?.isAffectedByGravity = true
        targetNode.physicsBody?.mass = 0.15
        
        targetNode.physicsBody?.categoryBitMask = CollisionCategory.target.rawValue
        targetNode.physicsBody?.contactTestBitMask = CollisionCategory.floor.rawValue
        
        let material = SCNMaterial()
        
        let n = arc4random() % 10
        if n <= 1 {
            targetNode.type = TargetNodeType(typeNum: .high)
            material.diffuse.contents = UIImage(named: "target-high")
        } else if n >= 6 {
            targetNode.type = TargetNodeType(typeNum: .demon)
            material.diffuse.contents = UIImage(named: "target-demon")
        } else {
            targetNode.type = TargetNodeType(typeNum: .normal)
            material.diffuse.contents = UIImage(named: "target-normal")
        }
        
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = targetNode.typeColor
        targetNode.geometry?.materials = [whiteMaterial, material, material]
        
        targetNode.radius = newRadius
        targetNode.scoreMultiple = oldTarget.scoreMultiple * 2
        
        return targetNode
    }
    
}

