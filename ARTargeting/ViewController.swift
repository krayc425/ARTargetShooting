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

let screenHeight = UIScreen.main.bounds.height
let screenWidth = UIScreen.main.bounds.width

private let rotateAction    = SCNAction.rotateTo(x: 0, y: .pi * 2, z: 0, duration: targetAnimationTime, usesShortestUnitArc: false)
private let fadeInAction    = SCNAction.fadeIn(duration: targetAnimationTime)
private let fadeOutAction   = SCNAction.fadeOut(duration: targetAnimationTime)
private let removeAction    = SCNAction.removeFromParentNode()

private let targetAnimationTime         : TimeInterval   = 1.0
private let targetRemainingTime         : Int            = 5
private let generationCycle             : TimeInterval   = 6.0

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    private let frontSightRadius            : CGFloat        = 25.0
    
    private var currentScore: Int = 0 {
        didSet {
            print("Current Score \(currentScore)")
        }
    }
    
    var targetNodes = Set<TargetNode>()
    var bulletNodes = Set<BulletNode>()
    
    lazy var generateTimer: Timer = {
        weak var weakSelf = self
        return Timer(timeInterval: generationCycle, repeats: true) { _ in
            print("Generate!")
            weakSelf?.generateTarget()
        }
    }()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.gravity = SCNVector3(0, -1, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading

//        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
//                                  ARSCNDebugOptions.showFeaturePoints]

        // Run the view's session
        sceneView.session.run(configuration)
        
        let frontSight = FrontSightView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: frontSightRadius * 2,
                                                      height: frontSightRadius * 2))
        frontSight.center = sceneView.center
        self.view.addSubview(frontSight)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
        
//        let retryButton = UIButton(frame: CGRect(origin: CGPoint(x: 25, y: screenHeight - 50),
//                                                 size: CGSize(width: 40, height: 40)))
//        retryButton.setImage(#imageLiteral(resourceName: "retry"), for: .normal)
//        self.view.addSubview(retryButton)
        
        RunLoop.main.add(generateTimer, forMode: .commonModes)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    deinit {
        generateTimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    private func generateTarget() {
        let count = Int(arc4random() % 5)
        for _ in 0..<count {
            guard targetNodes.count <= 10 else {
                return
            }
            
            let x: CGFloat = 4.0
            let y: CGFloat = (CGFloat(arc4random() % 10) / 5.0)
            let z: CGFloat = (CGFloat(arc4random() % 10) / 5.0) - 1.0
            
            let newPosition = SCNVector3(x, y, z)
            if targetNodes.filter({ (node) -> Bool in
                CGFloat(node.position.distance(from: newPosition)) <= frontSightRadius
            }).count > 0 {
                continue
            }
            
            let targetNode = TargetNode()
            targetNode.position = newPosition
            targetNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: .pi / 2.0)
            
            self.targetNodes.insert(targetNode)
            targetNode.physicsBody?.applyForce(SCNVector3(0, 0.25, 0), asImpulse: true)
            self.sceneView.scene.rootNode.addChildNode(targetNode)
        }
    }

    @objc private func handleTap(gestureRecognize: UITapGestureRecognizer) {
        let bulletNode = BulletNode()

        let (direction, position) = getUserVector()
        
        let originalX: Float = 3.0
        bulletNode.position = SCNVector3(originalX,
                                         position.y + (originalX - position.x) * direction.y / direction.x,
                                         position.z + (originalX - position.x) * direction.z / direction.x)
        bulletNode.rotation = SCNVector4(0, 0, 1, Double.pi / 2)

        let bulletDirection = direction
        bulletNode.physicsBody?.applyForce(SCNVector3(bulletDirection.x * 2, bulletDirection.y * 2, bulletDirection.z * 2),
                                           asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletNode)

        bulletNodes.insert(bulletNode)
    }
    
    private func getUserVector() -> (direction: SCNVector3, position: SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let direction = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let position = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (direction, position)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        var bulletToRemove: [BulletNode] = []
        for bullet in bulletNodes where bullet.presentation.position.distance(from: .zero) > 10 {
            bulletToRemove.append(bullet)
        }
        bulletToRemove.forEach {
            $0.removeFromParentNode()
            bulletNodes.remove($0)
        }
        
        var targetToRemove: [TargetNode] = []
        for target in targetNodes where target.presentation.position.y < -5 && !target.hit {
            targetToRemove.append(target)
        }
        targetToRemove.forEach {
            $0.removeFromParentNode()
            targetNodes.remove($0)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue {
            
            var targetNode = TargetNode()
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
            
            let particleSystem = SCNParticleSystem(named: "art.scnassets/Explode.scnp", inDirectory: nil)
            let particleSystemNode = SCNNode()
            particleSystemNode.addParticleSystem(particleSystem!)
            particleSystemNode.position = targetNode.position
            sceneView.scene.rootNode.addChildNode(particleSystemNode)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1),
                                          execute: { [unowned self] in
                                            self.targetNodes.remove(targetNode)
                                            targetNode.removeFromParentNode()
            })
        }
    }
    
}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let bullet = CollisionCategory(rawValue: 1 << 0) // 00...01
    static let target = CollisionCategory(rawValue: 1 << 1) // 00...10
}
