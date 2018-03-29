//
//  AddScoreNode.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit

class AddScoreNode: SCNNode {
    
    private var score: Int = 0
    
    init(targetNode: TargetNode) {
        super.init()
        
        self.score = targetNode.hitScore
        
        let text = SCNText(string: "\(score > 0 ? "+" : "")\(score)", extrusionDepth: 1.0)
        text.chamferRadius = 1.0
        text.flatness = 0.1
        text.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        
        self.geometry = text
        self.scale = SCNVector3(0.02, 0.02, 0.02)
        
        let material = SCNMaterial()
        material.diffuse.contents = targetNode.typeColor
        self.geometry?.materials = Array<SCNMaterial>(repeating: material, count: 5)
        self.position = targetNode.presentation.position + SCNVector3(-0.2, 0, 0)
        
        move()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func move() {
        self.runAction(SCNAction.sequence([SCNAction.move(by: SCNVector3(0, score > 0 ? 1 : -1, 0), duration: 1.0), SCNAction.removeFromParentNode()]))
    }
    
}

