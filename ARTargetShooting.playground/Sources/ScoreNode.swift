//
//  ScoreNode.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/21.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit

class ScoreNode: SCNNode {

    override init() {
        super.init()
    }
    
    convenience init(string: String) {
        self.init()

        let text = SCNText(string: string, extrusionDepth: 1.0)
        text.font = UIFont.systemFont(ofSize: 20.0, weight: .heavy)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        text.materials = [material]
        let textNode = SCNNode(geometry: text)
        textNode.position = .zero
        addChildNode(textNode)
        
        let upAction = SCNAction.move(by: SCNVector3(0, 1, 0), duration: 1.0)
        let removeAction = SCNAction.removeFromParentNode()
        self.runAction(SCNAction.sequence([upAction, removeAction]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
