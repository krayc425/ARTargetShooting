/*:
 # Classic Mode
 
 # Goal: Get **30** points in **Classic** mode!
 
 You have passed the tutorial, now let's try something cool. In **Classic** mode, multiple targets will appear randomly, and they are affected by gravity, which means that you have to shoot them as soon as possible, otherwise they will drop on the ground.
 
 From now on, **3** kind of targets will show up, and make sure that you shoot the right target, some of them have **NEGATIVE** scores!
 
 ## Targets
 Targets in different colors represent different scores.
 
 #### 1 point
 
 ![1 point](target-normal.png "1 point")
 
 #### 3 points
 
 ![3 point](target-high.png "3 point")
 
 #### -5 points
 
 ![-5 point](target-demon.png "-5 point")
 
 ## Parameters
 Should you find this game too easy, you can change the gravity value to a bigger one so that the targets will drop faster. (Best range: `[1, 5]`)
 */
let gravity: UInt = 1

//: [Next Page](@next)

//#-hidden-code
import UIKit
import PlaygroundSupport

let viewController = ClassicViewController(gravityValue: gravity)

PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code
