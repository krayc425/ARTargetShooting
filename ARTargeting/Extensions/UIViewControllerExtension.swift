//
//  UIViewControllerExtension.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/22.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import ARKit

extension UIViewController {
    
    func playSound(_ type: SoundType) {
        SoundHelper.shared.playSound(of: type)
    }
    
    func getUserVector(in frame: ARFrame?) -> (direction: SCNVector3, position: SCNVector3) {
        if let _ = frame {
            let mat = SCNMatrix4(frame!.camera.transform)
            let direction = SCNVector3(-mat.m31, -mat.m32, -mat.m33)
            let position = SCNVector3(mat.m41, mat.m42, mat.m43)
            return (direction, position)
        } else {
            return (.zero, .zero)
        }
    }
    
}
