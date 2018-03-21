//
//  UIColorExtension.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func random() -> UIColor {
        let r: CGFloat = CGFloat(arc4random() % 255) / 255.0
        let g: CGFloat = CGFloat(arc4random() % 255) / 255.0
        let b: CGFloat = CGFloat(arc4random() % 255) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
}
