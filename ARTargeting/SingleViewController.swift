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

class SingleViewController: UIViewController, ARSCNViewDelegate {

    private let generationCycle     : TimeInterval   = 3.0
    
    private var currentScore: Int = 0 {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.scoreNode.update(score: self.currentScore)
            }
        }
    }
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        return UIVisualEffectView(effect: blurEffect)
    }()
    private lazy var waitLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0,
                                          y: screenHeight / 2.0 - 100,
                                          width: screenWidth,
                                          height: 200))
        label.font = UIFont.systemFont(ofSize: 35.0, weight: .bold)
        label.textColor = .white
        label.text = "Move around\nyour device"
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private var targetNodes = Set<TargetNode>()
    private var scoreNode = ScoreNode()
    
    private lazy var generateTimer: Timer = {
        weak var weakSelf = self
        return Timer(timeInterval: generationCycle, repeats: true) { _ in
            weakSelf?.generateTarget()
        }
    }()
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var frontSight: FrontSightView!
    
    private var isStarted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.gravity = SCNVector3(0, -1, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        
        sceneView.session.run(configuration)
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
        
        self.blurView.frame = self.waitLabel.frame
        self.view.addSubview(self.blurView)
        self.view.addSubview(self.waitLabel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) { [unowned self] in
            self.waitLabel.text = "Tap to Shoot!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) { [unowned self] in
            self.waitLabel.removeFromSuperview()
            self.blurView.removeFromSuperview()
            self.sceneView.scene.rootNode.addChildNode(self.scoreNode)
            self.isStarted = true
            RunLoop.main.add(self.generateTimer, forMode: .commonModes)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    deinit {
        generateTimer.invalidate()
    }
    
    private func generateTarget() {
        let x: Float = Float(arc4random() % 4) - 2.0
        let y: Float = Float(arc4random() % 2) + 0.5
        let z: Float = -Float(arc4random() % 4) - 4.0
        
        let targetNode = TargetNode.getSingleTarget(isTutorial: false)
        targetNode.position = SCNVector3(x, y, z)
        targetNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: .pi / 2.0)
        
        self.targetNodes.insert(targetNode)
        targetNode.physicsBody?.applyForce(SCNVector3(0, 0.25, 0), asImpulse: true)
        self.sceneView.scene.rootNode.addChildNode(targetNode)
        
        playSound(.appear)
    }
    private func generateSmallTarget(oldTarget: TargetNode) {
        let oldPosition = oldTarget.presentation.position
        
        for i in 0...1 {
            let targetNode = TargetNode.generateSmallTarget(oldTarget: oldTarget)
            targetNode.position = oldPosition
            targetNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: .pi / 2.0)
            
            self.targetNodes.insert(targetNode)
            targetNode.physicsBody?.applyForce(SCNVector3((0.5 - Double(i)) * drand48(),
                                                          drand48() - 0.5,
                                                          drand48() - 0.5), asImpulse: true)
            self.sceneView.scene.rootNode.addChildNode(targetNode)
        }
    }
    
    @objc private func handleTap(gestureRecognize: UITapGestureRecognizer) {
        guard isStarted else {
            return
        }
        
        playSound(.shoot)
        let (direction, position) = getUserVector(in: self.sceneView.session.currentFrame)
        
        var endVector = position + direction * 10
        
        for targetNode in targetNodes {
            let targetVector = targetNode.presentation.position + position * (-1)
            if !targetNode.hit && fabs(targetVector.theta(from: direction)) <= fabs(atan(Float(targetNode.radius) / targetNode.presentation.position.distance(from: position))) {
                currentScore += targetNode.hitScore
                self.generateSmallTarget(oldTarget: targetNode)
                playSound(.hit)
                sceneView.scene.rootNode.addChildNode(ExplosionNode(targetNode: targetNode))
                
                let addNode = AddScoreNode(targetNode: targetNode)
                let pointOfViewRotation = sceneView.pointOfView?.rotation
                addNode.rotation = SCNVector4(0, pointOfViewRotation!.y, 0, pointOfViewRotation!.w)
                sceneView.scene.rootNode.addChildNode(addNode)
                
                endVector = targetNode.presentation.position
                
                targetNode.hit = true
                break
            }
        }
        
        let lineNode = SCNNode.lineFrom(from: endVector, to: position + direction * 0.1)
        lineNode.runAction(SCNAction.sequence([SCNAction.fadeOut(duration: 3.0), SCNAction.removeFromParentNode()]))
        sceneView.scene.rootNode.addChildNode(lineNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        var targetToRemove: [TargetNode] = []
        for target in targetNodes where target.hit || target.presentation.position.y < -10 {
            targetToRemove.append(target)
        }
        DispatchQueue.main.async { [unowned self] in
            targetToRemove.forEach {
                $0.removeFromParentNode()
                self.targetNodes.remove($0)
            }
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
    
}
