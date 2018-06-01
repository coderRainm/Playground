import Foundation
import PlaygroundSupport

public var commandManager: CommandManager?

public class CommandManager: NSObject, PlaygroundRemoteLiveViewProxyDelegate {
    
    public func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
        PlaygroundPage.current.assessmentStatus = .pass(message: "lose")
        PlaygroundPage.current.finishExecution()
    }
    
    public func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received value: PlaygroundValue) {
        
        let playgroundValue = PlaygroundValue.string("zhangsan")
        PlaygroundPage.current.assessmentStatus = .pass(message: "You did it!")
        
        if let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
            proxy.send(playgroundValue)
        }
    }
}


