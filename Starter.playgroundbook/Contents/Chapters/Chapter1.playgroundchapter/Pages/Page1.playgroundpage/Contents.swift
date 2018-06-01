//#-hidden-code
/*
 Copyright (C) 2016 UBTech Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information.
 
 This is a second example page.
 */
//#-end-hidden-code

//#-hidden-code
import PlaygroundSupport
if let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
    PlaygroundPage.current.needsIndefiniteExecution = true
    commandManager = CommandManager()
    proxy.delegate = commandManager
}
//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, if, say(), say(message:), work(message:))
//#-editable-code Tap to enter code

//#-end-editable-code

