//
//  ViewController.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

public class ViewController: UIViewController, ARSCNViewDelegate {
    
    private let frontSightRadius    : CGFloat        = 25.0
    private let generationCycle     : TimeInterval   = 3.0
    
    private var currentScore: Int = 0 {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.scoreLabel.text = "\(self.currentScore)"
            }
        }
    }
    private lazy var scoreLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 80))
        label.font = UIFont.systemFont(ofSize: 35.0, weight: .bold)
        label.textColor = .white
        label.text = "0"
        label.textAlignment = .center
        return label
    }()
    private lazy var waitLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: screenWidth / 2.0 - 150, y: screenHeight / 2.0 - 100, width: 300, height: 200))
        label.font = UIFont.systemFont(ofSize: 35.0, weight: .bold)
        label.textColor = .white
        label.text = "Move your\ndevice around"
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    private var blurView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private var targetNodes = Set<TargetNode>()
    private var bulletNodes = Set<BulletNode>()
    
    private lazy var generateTimer: Timer = {
        weak var weakSelf = self
        return Timer(timeInterval: generationCycle, repeats: true) { _ in
            weakSelf?.generateTarget()
        }
    }()
    
    private var sceneView: ARSCNView = ARSCNView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    
    private var gravity: SCNVector3 = SCNVector3(0, -1, 0)
    
    public convenience init(gravityValue: UInt) {
        self.init(nibName: nil, bundle: nil)
        
        if gravityValue > 0 {
            self.gravity = SCNVector3(0, -1 * Int(gravityValue), 0)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = sceneView
        
        sceneView.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.gravity = self.gravity
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        
        sceneView.session.run(configuration)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognize:)))
        self.view.addGestureRecognizer(tapGesture)
        
        let frontSight = FrontSightView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: 2 * frontSightRadius,
                                                      height: 2 * frontSightRadius))
        frontSight.center = sceneView.center
        self.view.addSubview(frontSight)
        
        self.blurView.frame = self.waitLabel.frame
        self.view.addSubview(self.blurView)
        self.view.addSubview(self.waitLabel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) { [unowned self] in
            self.waitLabel.text = "Tap to Shoot!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6)) { [unowned self] in
            self.waitLabel.removeFromSuperview()
            self.blurView.frame = self.scoreLabel.frame
            self.view.addSubview(self.scoreLabel)
            RunLoop.main.add(self.generateTimer, forMode: .commonModes)
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    deinit {
        generateTimer.invalidate()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func generateTarget() {
        let count = Int(arc4random() % 3) + 1
        
        var i = 0
        while i < count {
            guard targetNodes.count <= 10 else {
                return
            }
            
            let x: Float = (Float(arc4random() % 20) / 5.0) - 2.0
            let y: Float = (Float(arc4random() % 10) / 5.0) + 0.5
            let z: Float = -5.0
            
            let newPosition = SCNVector3(x, y, z)
            if targetNodes.filter({ (node) -> Bool in
                CGFloat(node.position.distance(from: newPosition)) <= targetRadius
            }).count > 0 {
                continue
            }
            
            let targetNode = TargetNode.generateTarget()
            targetNode.position = newPosition
            targetNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: .pi / 2.0)
            
            self.targetNodes.insert(targetNode)
            targetNode.physicsBody?.applyForce(SCNVector3(0, -0.25, 0), asImpulse: true)
            self.sceneView.scene.rootNode.addChildNode(targetNode)
            
            i += 1
        }
    }
    
    @objc private func handleTap(gestureRecognize: UITapGestureRecognizer) {
        let bulletNode = BulletNode()
        
        let (direction, position) = getUserVector()
        
        let originalZ: Float = Float(-5.0 + bulletRadius * 2.0)
        bulletNode.position = SCNVector3(position.x + (originalZ - position.z) * direction.x / direction.z,
                                         position.y + (originalZ - position.z) * direction.y / direction.z,
                                         originalZ)
        bulletNode.playSound(.shoot)
        
        let bulletDirection = direction
        bulletNode.physicsBody?.applyForce(SCNVector3(bulletDirection.x * 2, bulletDirection.y * 2, bulletDirection.z * 2),
                                           asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletNode)
        bulletNodes.insert(bulletNode)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        var bulletToRemove: [BulletNode] = []
        for bullet in bulletNodes where bullet.presentation.position.distance(from: .zero) > 20 {
            bulletToRemove.append(bullet)
        }
        DispatchQueue.main.async { [unowned self] in
            bulletToRemove.forEach {
                $0.removeFromParentNode()
                self.bulletNodes.remove($0)
            }
        }
        
        var targetToRemove: [TargetNode] = []
        for target in targetNodes where target.presentation.position.y < -5 && !target.hit {
            targetToRemove.append(target)
        }
        DispatchQueue.main.async { [unowned self] in
            targetToRemove.forEach {
                $0.removeFromParentNode()
                self.targetNodes.remove($0)
            }
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    private func getUserVector() -> (direction: SCNVector3, position: SCNVector3) {
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let direction = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            let position = SCNVector3(mat.m41, mat.m42, mat.m43)
            return (direction, position)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
}

extension ViewController: SCNPhysicsContactDelegate {
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue {
            
            var targetNode: TargetNode = TargetNode()
            if contact.nodeA is TargetNode {
                targetNode = contact.nodeA as! TargetNode
            } else {
                targetNode = contact.nodeB as! TargetNode
            }
            
            guard !targetNode.hit else {
                return
            }
            
            currentScore += targetNode.hitScore
            targetNode.hit = true
            
            let particleSystem = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)
            particleSystem?.particleColor = targetNode.type?.color ?? .clear
            let particleSystemNode = SCNNode()
            particleSystemNode.addParticleSystem(particleSystem!)
            particleSystemNode.position = targetNode.presentation.position
            sceneView.scene.rootNode.addChildNode(particleSystemNode)
            
            particleSystemNode.playSound(.hit)
            
            self.targetNodes.remove(targetNode)
            targetNode.removeFromParentNode()
        }
    }
    
}
