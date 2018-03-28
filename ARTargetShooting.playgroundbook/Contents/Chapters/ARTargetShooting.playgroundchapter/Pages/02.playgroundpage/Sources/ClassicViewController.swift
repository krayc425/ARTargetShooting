//
//  ClassicViewController.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import PlaygroundSupport

public class ClassicViewController: UIViewController, ARSCNViewDelegate, PlaygroundLiveViewSafeAreaContainer, ARSessionDelegate {
    
    private let generationCycle     : TimeInterval   = 3.0
    
    private var hasSucceeded: Bool = false
    private var currentScore: Int = 0 {
        didSet {
            if !hasSucceeded && currentScore >= 30 {
                hasSucceeded = true
                PlaygroundPage.current.assessmentStatus = .pass(message: "You've got **30** points in **Classic** mode! It seems that you have mastered your shooting skill. Do you want more? 😏 Go to the [**Next Page**](@next)!")
                playSound(.success)
            }
            DispatchQueue.main.async { [unowned self] in
                let node = self.scoreNode
                let text = node.geometry as! SCNText
                text.string = "\(self.currentScore)"
                
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.random()
                node.geometry?.materials = [material]
            }
        }
    }
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
    
    private lazy var scoreNode: SCNNode = {
        let text = SCNText(string: "0", extrusionDepth: 0.5)
        text.chamferRadius = 1.0
        text.flatness = 0.1
        text.font = UIFont.systemFont(ofSize: 30.0, weight: .bold)
        let node = SCNNode(geometry: text)
        node.scale = SCNVector3(0.05, 0.05, 0.05)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.random()
        node.geometry?.materials = [material]
        node.position = SCNVector3(0.0, 0.5, -10.0)
        let (minBound, maxBound) = text.boundingBox
        node.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x), 0, 0)
        return node
    }()
    
    private var targetNodes = Set<TargetNode>()
    private var planes: [UUID: PlaneNode] = [:]
    private lazy var generateTimer: Timer = {
        weak var weakSelf = self
        return Timer(timeInterval: generationCycle, repeats: true) { _ in
            weakSelf?.generateTarget()
        }
    }()

    public var sceneView: ARSCNView = ARSCNView()
    
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
        
        sceneView.clipsToBounds = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.trailingAnchor),
            sceneView.topAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor)
            ])
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.gravity = self.gravity
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.planeDetection = .horizontal
        
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
        
        let blurViewleftMarginConstraint = NSLayoutConstraint(item: self.blurView, attribute: .left, relatedBy: .equal, toItem: self.waitLabel, attribute: .left, multiplier: 1, constant: 0)
        let blurViewrightMarginConstraint = NSLayoutConstraint(item: self.blurView, attribute: .right, relatedBy: .equal, toItem: self.waitLabel, attribute: .right, multiplier: 1, constant: 0)
        let blurViewtopMarginConstraint = NSLayoutConstraint(item: self.blurView, attribute: .top, relatedBy: .equal, toItem: self.waitLabel, attribute: .top, multiplier: 1, constant: 0)
        let blurViewbottomMarginConstraint = NSLayoutConstraint(item: self.blurView, attribute: .bottom, relatedBy: .equal, toItem: self.waitLabel, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraints([blurViewleftMarginConstraint, blurViewrightMarginConstraint, blurViewtopMarginConstraint, blurViewbottomMarginConstraint])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [unowned self] in
            self.waitLabel.text = "Move around\nyour iPad"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) { [unowned self] in
            self.waitLabel.text = "Tap to Shoot!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) { [unowned self] in
            self.waitLabel.removeFromSuperview()
            self.blurView.removeFromSuperview()
            frontSight.alpha = 1.0
            self.sceneView.scene.rootNode.addChildNode(self.scoreNode)
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
            let x: Float = Float(arc4random() % 4) - 2.0
            let y: Float = Float(arc4random() % 2)
            let z: Float = -Float(arc4random() % 2) - 3.0
            
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
            targetNode.physicsBody?.applyForce(SCNVector3(0, 0.25, 0), asImpulse: true)
            self.sceneView.scene.rootNode.addChildNode(targetNode)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(i * 100)) { [unowned self] in
                self.playSound(.appear)
            }
            
            i += 1
        }
    }
    
    @objc private func handleTap(gestureRecognize: UITapGestureRecognizer) {
        let bulletNode = BulletNode()
        
        let (direction, position) = getUserVector()
        bulletNode.position = position + direction * 2.0
        
        bulletNode.physicsBody?.applyForce(SCNVector3(direction.x * 3.5,
                                                      direction.y * 3.5,
                                                      direction.z * 3.5),
                                           asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletNode)
        
        playSound(.shoot)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        for node in sceneView.scene.rootNode.childNodes where node is BulletNode &&  node.presentation.position.distance(from: .zero) > 20 {
            node.removeFromParentNode()
        }
        var targetToRemove: [TargetNode] = []
        for target in targetNodes where target.presentation.position.y < -20 && !target.hit {
            targetToRemove.append(target)
        }
        DispatchQueue.main.async { [unowned self] in
            targetToRemove.forEach {
                $0.removeFromParentNode()
                self.targetNodes.remove($0)
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }

        let plane = PlaneNode(withAnchor: anchor)
        planes[anchor.identifier] = plane
        node.addChildNode(plane)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let plane = planes[anchor.identifier] else {
            return
        }
        
        plane.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
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
    
    func getUserVector() -> (direction: SCNVector3, position: SCNVector3) {
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let direction = SCNVector3(-mat.m31, -mat.m32, -mat.m33)
            let position = SCNVector3(mat.m41, mat.m42, mat.m43)
            return (direction, position)
        }
        return (.zero, .zero)
    }
    
}

extension ClassicViewController: SCNPhysicsContactDelegate {
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue {
            
            var targetNode: TargetNode = TargetNode()
            var bulletNode: BulletNode = BulletNode()
            if contact.nodeA is TargetNode {
                targetNode = contact.nodeA as! TargetNode
                bulletNode = contact.nodeB as! BulletNode
            } else {
                bulletNode = contact.nodeA as! BulletNode
                targetNode = contact.nodeB as! TargetNode
            }
            
            guard !targetNode.hit && !bulletNode.hit else {
                return
            }
            
            currentScore += targetNode.hitScore
            
            targetNode.hit = true
            bulletNode.hit = true
            
            let particleSystem = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)
            particleSystem?.particleColor = targetNode.typeColor
            let particleSystemNode = SCNNode()
            particleSystemNode.addParticleSystem(particleSystem!)
            particleSystemNode.position = targetNode.presentation.position
            sceneView.scene.rootNode.addChildNode(particleSystemNode)
            
            playSound(.hit)
            
            self.targetNodes.remove(targetNode)
            targetNode.removeFromParentNode()
        }
    }
    
}
