//
//  LiveView.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/23.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import PlaygroundSupport
import UIKit

let viewController = ViewController(gravityValue: 1)

PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true
