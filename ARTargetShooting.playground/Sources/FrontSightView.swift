//
//  FrontSightView.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit

let dotWidth: CGFloat = 5.0

class FrontSightView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let path = UIBezierPath(arcCenter: self.center,
                                radius: frame.width / 2.0,
                                startAngle: 0,
                                endAngle: 2 * .pi,
                                clockwise: true)
        path.lineWidth = 2.0
        
        let dot = UIBezierPath(roundedRect: CGRect(x: (frame.width - dotWidth) / 2.0,
                                                   y: (frame.width - dotWidth) / 2.0,
                                                   width: dotWidth,
                                                   height: dotWidth),
                               cornerRadius: dotWidth / 2.0)
        dot.lineWidth = dotWidth / 2.0
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        self.layer.addSublayer(layer)
        
        let dotLayer = CAShapeLayer()
        dotLayer.path = dot.cgPath
        dotLayer.fillColor = UIColor.white.cgColor
        dotLayer.strokeColor = UIColor.white.cgColor
        self.layer.addSublayer(dotLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
