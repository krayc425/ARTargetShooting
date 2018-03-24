/*:
 ## Good Job!
 You have passed the tutorial, now let's try something cool. In **Classic** mode, multiple targets will appear, and they are affected by gravity, which means that you have to shoot them as soon as possible, otherwise they will just drop on the ground.
 
 And from now on, **3** kinds of target will show up, so make sure that you shoot the right target!
 
 ## Target Categories
 * Targets in different colors represent different scores.
 
 ![1 point](target-normal.png "1 point") 1 point
 
 ![3 point](target-high.png "3 point") 3 points
 
 ![-5 point](target-demon.png "-5 point") -5 points
 
 ## Parameters
 Should you find this game too easy, you can change the value to a bigger one so that the targets will drop faster. (Best range: `[1, 5]`)
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
