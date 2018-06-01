
import Foundation
import PlaygroundSupport


public func say() {
    let page = PlaygroundPage.current
    if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
        PlaygroundPage.current.needsIndefiniteExecution = true
        proxy.send(.string("hi"))
    }
}
/**
 Instructs the character to collect a gem on the current tile.
 */
public func say(message: String) {
    let page = PlaygroundPage.current
    if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
        PlaygroundPage.current.needsIndefiniteExecution = true
        proxy.send(.string(message))
    }
}

/**
 Instructs the character to collect a gem on the current tile.
 */
public func work(message: String) {
    let page = PlaygroundPage.current
    if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
        PlaygroundPage.current.needsIndefiniteExecution = true
        proxy.send(.string(message))
    }
}

