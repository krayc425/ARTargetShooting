//
//  TutorialViewController.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import PlaygroundSupport

public class TutorialViewController: UIViewController, ARSCNViewDelegate, PlaygroundLiveViewSafeAreaContainer {
    
    private lazy var waitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 35.0, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var blurView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private lazy var targetNode: TargetNode = {
        let node = TargetNode.getTutorialTarget()
        node.position = SCNVector3(0, 0, -5)
        node.rotation = SCNVector4(x: 1, y: 0, z: 0, w: .pi / 2.0)
        return node
    }()
    private var bulletNodes = Set<BulletNode>()
    
    public var sceneView: ARSCNView = ARSCNView()
    
    private var gravity: SCNVector3 = SCNVector3(0, -1, 0)
    
    fileprivate var doneTutorial: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = sceneView
        
        sceneView.clipsToBounds = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.trailingAnchor),
            sceneView.topAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor)
            ])
        
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
                                                      width: 50.0,
                                                      height: 50.0))
        frontSight.translatesAutoresizingMaskIntoConstraints = false
        frontSight.alpha = 0.0
        self.view.addSubview(frontSight)
        let centerXConstraint = NSLayoutConstraint(item: frontSight, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: frontSight, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        self.view.addConstraints([centerXConstraint, centerYConstraint])
        
        self.blurView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.blurView)
        self.view.addSubview(self.waitLabel)
        
        let waitLabelleftMarginConstraint = NSLayoutConstraint(item: self.waitLabel, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
        let waitLabelrightMarginConstraint = NSLayoutConstraint(item: self.waitLabel, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
        let waitLabelcenterXConstraint = NSLayoutConstraint(item: self.waitLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let waitLabelcenterYConstraint = NSLayoutConstraint(item: self.waitLabel, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        let waitLabelheightConstraint = NSLayoutConstraint(item: self.waitLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 200)
        self.view.addConstraints([waitLabelleftMarginConstraint, waitLabelrightMarginConstraint, waitLabelcenterXConstraint, waitLabelcenterYConstraint, waitLabelheightConstraint])
        
        var blurViewleftMarginConstraint = NSLayoutConstraint(item: self.blurView, attribute: .left, relatedBy: .equal, toItem: self.waitLabel, attribute: .left, multiplier: 1, constant: 0)
        var blurViewrightMarginConstraint = NSLayoutConstraint(item: self.blurView, attribute: .right, relatedBy: .equal, toItem: self.waitLabel, attribute: .right, multiplier: 1, constant: 0)
        var blurViewtopMarginConstraint = NSLayoutConstraint(item: self.blurView, attribute: .top, relatedBy: .equal, toItem: self.waitLabel, attribute: .top, multiplier: 1, constant: 0)
        var blurViewbottomMarginConstraint = NSLayoutConstraint(item: self.blurView, attribute: .bottom, relatedBy: .equal, toItem: self.waitLabel, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraints([blurViewleftMarginConstraint, blurViewrightMarginConstraint, blurViewtopMarginConstraint, blurViewbottomMarginConstraint])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [unowned self] in
            self.waitLabel.text = "Move around\nyour iPad"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) { [unowned self] in
            self.waitLabel.text = "Tap to Shoot!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6)) { [unowned self] in
            self.waitLabel.isHidden = true
            self.blurView.isHidden = true
            frontSight.alpha = 1.0
            self.sceneView.scene.rootNode.addChildNode(self.targetNode)
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        if doneTutorial && self.blurView.isHidden && self.waitLabel.isHidden {
            self.blurView.isHidden = false
            self.waitLabel.isHidden = false
            self.waitLabel.text = "Good Job!\nTap 'Next Page' on the left to go on."
            
            self.sceneView.bringSubview(toFront: self.blurView)
            self.sceneView.bringSubview(toFront: self.waitLabel)
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

extension TutorialViewController: SCNPhysicsContactDelegate {
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue {
            
            var node: TargetNode = TargetNode()
            if contact.nodeA is TargetNode {
                node = contact.nodeA as! TargetNode
            } else {
                node = contact.nodeB as! TargetNode
            }
            
            guard !node.hit else {
                return
            }
            
            self.doneTutorial = true
        
            node.removeFromParentNode()
            
            let particleSystem = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)
            particleSystem?.particleColor = targetNode.type?.color ?? .clear
            let particleSystemNode = SCNNode()
            particleSystemNode.addParticleSystem(particleSystem!)
            particleSystemNode.position = targetNode.presentation.position
            sceneView.scene.rootNode.addChildNode(particleSystemNode)
            
            particleSystemNode.playSound(.hit)
        }
    }
    
}
