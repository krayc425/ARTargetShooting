/*:
 # ARTargetShooting
 Hi! I'm Kuixi Song from Nanjing University, China. I love iOS development and this year, I made some digging into the newest `ARKit`. So I made a little target shooting game to submit for WWDC 2018. Hope you like it! 😊
 */

import PlaygroundSupport
import SceneKit
import ARKit

let screenHeight    = UIScreen.main.bounds.height
let screenWidth     = UIScreen.main.bounds.width

class ViewController: UIViewController, ARSCNViewDelegate {
    
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
    
    private var targetNodes = Set<TargetNode>()
    private var bulletNodes = Set<BulletNode>()
    
    private lazy var generateTimer: Timer = {
        weak var weakSelf = self
        return Timer(timeInterval: generationCycle, repeats: true) { _ in
            weakSelf?.generateTarget()
        }
    }()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.gravity = SCNVector3(0, -1, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        sceneView.session.run(configuration)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
        
        let frontSight = FrontSightView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: frontSightRadius * 2,
                                                      height: frontSightRadius * 2))
        frontSight.center = sceneView.center
        self.view.addSubview(frontSight)
        
        //        let retryButton = UIButton(frame: CGRect(origin: CGPoint(x: 25, y: screenHeight - 50),
        //                                                 size: CGSize(width: 40, height: 40)))
        //        retryButton.setImage(#imageLiteral(resourceName: "retry"), for: .normal)
        //        self.view.addSubview(retryButton)
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = scoreLabel.frame
        self.view.addSubview(blurView)
        self.view.addSubview(scoreLabel)
        
        RunLoop.main.add(generateTimer, forMode: .commonModes)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    deinit {
        generateTimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func generateTarget() {
        let count = Int(arc4random() % 4)
        var i = 0
        while i < count {
            guard targetNodes.count <= 10 else {
                return
            }
            
            let x: Float = 4.0
            let y: Float = (Float(arc4random() % 10) / 5.0)
            let z: Float = (Float(arc4random() % 10) / 5.0) - 1.0
            
            let newPosition = SCNVector3(x, y, z)
            if targetNodes.filter({ (node) -> Bool in
                CGFloat(node.position.distance(from: newPosition)) <= targetRadius
            }).count > 0 {
                continue
            }
            
            let targetNode = TargetNode.generateTarget()
            targetNode.position = newPosition
            targetNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: .pi / 2.0)
            
            self.targetNodes.insert(targetNode)
            targetNode.physicsBody?.applyForce(SCNVector3(0, 0.25, 0), asImpulse: true)
            self.sceneView.scene.rootNode.addChildNode(targetNode)
            
            i += 1
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
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
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
            
            let particleSystem = SCNParticleSystem(named: "art.scnassets/Explode.scnp", inDirectory: nil)
            particleSystem?.particleColor = targetNode.type?.color ?? .clear
            let particleSystemNode = SCNNode()
            particleSystemNode.addParticleSystem(particleSystem!)
            particleSystemNode.position = targetNode.presentation.position
            sceneView.scene.rootNode.addChildNode(particleSystemNode)
            
            let scoreNode = ScoreNode(string: "\(targetNode.hitScore)")
            scoreNode.position = targetNode.presentation.position
            sceneView.scene.rootNode.addChildNode(scoreNode)
            
            self.targetNodes.remove(targetNode)
            targetNode.removeFromParentNode()
        }
    }
    
    static func loadFromSB() -> ViewController {
        let mainSB = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainSB.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        return vc
    }
    
}

PlaygroundPage.current.liveView = ViewController.loadFromSB()
