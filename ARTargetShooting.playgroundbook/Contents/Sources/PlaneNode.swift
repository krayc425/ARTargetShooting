//
//  PlaneNode.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

public class PlaneNode: SCNNode {

    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNBox!
    var planeNode: SCNNode!
    let planeHeight: Float = 0.01

    public init(withAnchor anchor: ARPlaneAnchor) {
        super.init()

        self.anchor = anchor
        planeGeometry = SCNBox(width: CGFloat(anchor.extent.x), height: CGFloat(planeHeight), length: CGFloat(anchor.extent.z), chamferRadius: 0)
        
        self.physicsBody?.categoryBitMask = CollisionCategory.floor.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.target.rawValue

        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor(white: 1, alpha: 0.2)
        planeGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial]

        planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3(0, -Float(planeHeight) / 2.0, 0)
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))

        addChildNode(planeNode)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(anchor: ARPlaneAnchor) {
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(planeHeight)
        planeGeometry.length = CGFloat(anchor.extent.z)
        
        position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
    }

}
