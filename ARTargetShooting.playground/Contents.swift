/*:
 # ARTargetShooting
 Hi! I'm **Kuixi Song**, a junior student majored in Software Engineering from Nanjing University, China. I've devoted in iOS development since last year and this year, I made some digging into the newest `ARKit`, which is awesome and easy to use! So I created a little target shooting game for WWDC 2018 submitting. Hope you like it! 😊
 
 ## How to play?
 After tapping the `Run my code` button, move your iPad around to initialize the `ARKit`. Once done, some targets will show up in the screen. Using the front sight (in the center of screen) to aim at these targets, and shoot them down!
 
 ### Notice
 Targets in different colors represents different scores. Be sure to shoot the right target!
 
 ![1 point](target-normal.png "1 point") 1 point
 
 ![3 point](target-high.png "3 point") 3 points

 ![-5 point](target-demon.png "-5 point") -5 points
 
 Good luck!
 
 */

//#-hidden-code
import UIKit
import PlaygroundSupport
//#-end-hidden-code

//#-hidden-code
let viewController = ViewController()
viewController.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code
