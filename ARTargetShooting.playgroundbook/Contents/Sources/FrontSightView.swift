//
//  FrontSightView.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit

public class FrontSightView: UIView {
    
    private let dotWidth: CGFloat = 5.0
    
    private func setupViews() {
        let path = UIBezierPath(arcCenter: CGPoint(x: 0.0, y: 0.0),
                                radius: frame.width / 2.0,
                                startAngle: 0,
                                endAngle: 2 * .pi,
                                clockwise: true)
        path.lineWidth = 2.0
        
        let dot = UIBezierPath(roundedRect: CGRect(x: -dotWidth / 2.0,
                                                   y: -dotWidth / 2.0,
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
}
