/*:
 # Arcade Mode
 
 # Goal: Get **100** points in **Arcade** mode!
 
 In **Arcade** mode, when you shoot a target, it will break up into **2 smaller** targets. And if you shoot the new target again, you will acquire **DOUBLE** score of the new target!
 
 However, the new target will be randomly selected from 1 of the 3 kinds of targets.
 
 ## For example
 
 1. You shoot a yellow target ![1 point](target-normal.png "1 point") → get `1` point
 2. You shoot a smaller blue ![3 point](target-high.png "3 point") target → get `2 * 3 = 6` points
 3. You shoot an even smaller red ![-5 point](target-demon.png "-5 point") target → get `4 * (-5) = -20` points
 4. ...
 
 Isn't it exciting?!
 
 ## Targets
 Targets in different colors represent different scores.
 
 #### 1 point
 
 ![1 point](target-normal.png "1 point")
 
 #### 3 points
 
 ![3 point](target-high.png "3 point")
 
 #### -5 points
 
 ![-5 point](target-demon.png "-5 point")
 
 ## Parameters
 Should you find this game too easy, you can change the value to a bigger one so that the targets will drop faster. (Best range: `[1, 5]`)
 */
let gravity: UInt = 1

//#-hidden-code
import UIKit
import PlaygroundSupport

let viewController = ArcadeViewController(gravityValue: gravity)

PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code
