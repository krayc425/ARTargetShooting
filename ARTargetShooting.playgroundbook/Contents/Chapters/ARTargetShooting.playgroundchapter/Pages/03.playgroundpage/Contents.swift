/*:
 ## Congratulations!
 Finally, we reach the final page: **Arcade** mode.
 
 Here, only the yellow target will appear. If you shoot one, it will break up into **2** smaller targets, and if you shoot the new target again, you will acquire double score!
 
 For example:
 
 1. You shoot a yellow target → get 1 point
 2. You shoot the smaller yellow target → get 2 points
 3. You shoot the even smaller target → get 4 points
 4. ...
 
 Isn't it exciting?!
 
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
