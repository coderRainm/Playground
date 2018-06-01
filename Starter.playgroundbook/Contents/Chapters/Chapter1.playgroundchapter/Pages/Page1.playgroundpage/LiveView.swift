
/*This protocol enables you to display any type of object in a live view. For example, a playground that presents a simplified user interface programming environment can make its view-like type conform to PlaygroundLiveViewable and appear in the live view.

By default, UIView and UIViewController conform to this protocol on iOS and tvOS, and NSView and NSViewController conform to this protocol in macOS. Developers need to implement this protocol only for custom objects that do not inherit from UIView, UIViewController, NSView, or NSViewController.*/
import PlaygroundSupport

let vc = LiveViewController()
PlaygroundPage.current.liveView = vc

