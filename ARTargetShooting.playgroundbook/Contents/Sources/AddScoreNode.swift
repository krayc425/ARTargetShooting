//
//  AddScoreNode.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit

public class AddScoreNode: SCNNode {
    
    private var score: Int = 0
    
    private var isText: Bool = false
    
    public init(targetNode: TargetNode, text: String? = nil) {
        super.init()
        
        self.score = targetNode.hitScore
        
        var scnTextString = ""
        
        if text == nil {
            scnTextString = "\(score > 0 ? "+" : "")\(score)"
        } else {
            scnTextString = text!
            isText = true
        }
        
        let scnText = SCNText(string: scnTextString, extrusionDepth: 1.0)
        scnText.chamferRadius = 1.0
        scnText.flatness = 0.1
        scnText.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        
        self.geometry = scnText
        self.scale = SCNVector3(0.02, 0.02, 0.02)
        
        let material = SCNMaterial()
        material.diffuse.contents = targetNode.typeColor
        self.geometry?.materials = Array<SCNMaterial>(repeating: material, count: 5)
        self.position = targetNode.presentation.position + SCNVector3(-0.2, 0, 0)
        
        
        let (minBound, maxBound) = scnText.boundingBox
        self.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x) / 2, minBound.y, 0.5)
        
        move()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func move() {
        if isText {
            self.runAction(SCNAction.repeatForever(SCNAction.sequence([SCNAction.move(by: SCNVector3(0, 0.5, 0), duration: 1.0), SCNAction.move(by: SCNVector3(0, -0.5, 0), duration: 1.0)])))
        } else {
            self.runAction(SCNAction.sequence([SCNAction.group([SCNAction.move(by: SCNVector3(0, score >= 0 ? 0.5 : -0.5, 0), duration: 1.0), SCNAction.scale(by: 2.0, duration: 1.0)]), SCNAction.removeFromParentNode()]))
        }
    }
    
}

