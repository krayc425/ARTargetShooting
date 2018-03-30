//
//  SCNNodeExtension.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/29.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import Foundation
import SceneKit

public extension SCNNode {
    
    public static func lineFrom(from: SCNVector3, to: SCNVector3, radius: CGFloat = 0.0001) -> SCNNode {
        let vector = to - from
        let height = vector.length
        let cylinder = SCNCylinder(radius: radius,
                                   height: CGFloat(height))
        cylinder.radialSegmentCount = 24
        let node = SCNNode(geometry: cylinder)
        node.position = (to + from) * 0.5
        node.eulerAngles = SCNVector3.lineEulerAngles(vector: vector)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
        cylinder.materials = [material, material, material]
        return node
    }
    
}
