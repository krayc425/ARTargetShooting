//
//  ScoreNode.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/29.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit

class ScoreNode: SCNNode {
    
    override init() {
        super.init()
        
        let text = SCNText(string: "", extrusionDepth: 0.5)
        text.chamferRadius = 1.0
        text.flatness = 0.1
        text.font = UIFont.systemFont(ofSize: 40.0, weight: .bold)
        self.geometry = text
        self.scale = SCNVector3(0.05, 0.05, 0.05)
        self.position = SCNVector3(-0.5, 0, -10)
        let (minBound, maxBound) = text.boundingBox
        self.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x) / 2, minBound.y, 0.5 / 2)
        
        update(score: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(score: Int) {
        let text = self.geometry as! SCNText
        text.string = "\(score)"
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.random()
        self.geometry?.materials = [material]
    }
    
}
