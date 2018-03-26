/*:
 # ARTargetShooting
 
 Hi! I'm **Kuixi Song**, a junior student majored in Software Engineering from Nanjing University, China. I've devoted in iOS development since last year and this year, I made some digging into the newest `ARKit`, which is awesome and easy to use! So I created a little target shooting game for WWDC 2018 scholarship submission. Hope you like it! 😊
 
 # Tutorial
 
 In order to let you get familiar with the game quickly, I designed a simple tutorial for you. After tapping the `Run My Code` button, move your iPad around to initialize the `ARKit`. Once done, one target will show up in the center of the screen. Then, please use the front sight (in the center of screen) to aim at that target, and tap the screen to shoot it down!
 */

//: [Next Page](@next)

//#-hidden-code
import UIKit
import PlaygroundSupport

let viewController = TutorialViewController()

PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code
