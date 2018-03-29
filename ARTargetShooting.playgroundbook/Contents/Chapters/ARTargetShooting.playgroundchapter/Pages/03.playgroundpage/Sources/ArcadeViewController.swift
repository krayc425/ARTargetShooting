//
//  ArcadeViewController.swift
//  ARTargeting
//
//  Created by 宋 奎熹 on 2018/3/19.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import PlaygroundSupport

public class ArcadeViewController: UIViewController, ARSCNViewDelegate, PlaygroundLiveViewSafeAreaContainer {
    
    private let generationCycle     : TimeInterval   = 5.0
    
    private var hasSucceeded: Bool = false
    private var currentScore: Int = 0 {
        didSet {
            if !hasSucceeded && currentScore >= 100 {
                hasSucceeded = true
                PlaygroundPage.current.assessmentStatus = .pass(message: "You've got **100** points in **Arcade** mode, hope you have had fun shooting targets down! 😆 Last but not the least, if you want a more challenging game, please adjust the gravity value on the 👈 left!")
                playSound(.success)
            }
            DispatchQueue.main.async { [unowned self] in
                self.scoreNode.update(score: self.currentScore)
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
    
    private var targetNodes = Set<TargetNode>()
    private var scoreNode = ScoreNode()
    
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
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.gravity = self.gravity
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        
        sceneView.session.run(configuration)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognize:)))
        self.view.addGestureRecognizer(tapGesture)
        
        let frontSight = FrontSightView(frame: CGRect(x: 0, y: 0, width: 50.0, height: 50.0))
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
        playSound(.shoot)
        
        let (direction, position) = getUserVector(in: self.sceneView.session.currentFrame)
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
                
                targetNode.hit = true
                break
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
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
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}
