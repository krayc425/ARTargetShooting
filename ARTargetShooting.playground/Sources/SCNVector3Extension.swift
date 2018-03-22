//
//  SCNVector3Extension.swift
//  PediAR
//
//  Created by 宋 奎熹 on 2017/11/4.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector3 {
    
    static var zero: SCNVector3 {
        return SCNVector3(0, 0, 0)
    }
    
    func distance(from anotherVector: SCNVector3) -> Float {
        return ((self.x - anotherVector.x).squared
            + (self.y - anotherVector.y).squared
            + (self.z - anotherVector.z).squared).squareRoot()
    }
    
    func yzDistance(from anotherVector: SCNVector3) -> Float {
        return ((self.y - anotherVector.y).squared
            + (self.z - anotherVector.z).squared).squareRoot()
    }
    
    var length: Float {
        return self.distance(from: SCNVector3(0, 0, 0))
    }
    
    func extended(by ratio: Float) -> SCNVector3 {
        return SCNVector3(self.x * ratio, self.y * ratio, self.z * ratio)
    }
    
}
