//
//  SCNVector3Extension.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/22.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import Foundation
import SceneKit

public extension SCNVector3 {
    
    static var zero: SCNVector3 {
        return SCNVector3(0, 0, 0)
    }
    
    func distance(from anotherVector: SCNVector3) -> Float {
        return ((self.x - anotherVector.x).squared
            + (self.y - anotherVector.y).squared
            + (self.z - anotherVector.z).squared).squareRoot()
    }
    
}
