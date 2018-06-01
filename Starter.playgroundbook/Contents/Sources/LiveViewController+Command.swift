import Foundation
import PlaygroundSupport

extension LiveViewController {
//    func onReceive(_ action:Action, variables:[String]? = nil) {
//        switch action {
//        case .start:
//
//        case .finish:
//
//        case .moveBody:
//
//        case .setBpmOfMySong:
//
//        default:
//
//        }
//    }
//
//    func sendCommand(_ action:Action, variables:[String]? = nil) {
//        send(Command(action, variables:variables).playgroundValue)
//    }
}

extension LiveViewController: PlaygroundLiveViewMessageHandler {
    
    //手动开始
    public func liveViewMessageConnectionOpened() {
//        liveLog("live opened")
//        dismissAudioMenu()
//        running = true
    }
    
    //手动结束
    public func liveViewMessageConnectionClosed() {
//        liveLog("live closed \(running)")
//        if running {
//            running = false
//            currentAction = nil
//            animationTimer?.invalidate()
//            animationTimer = nil
//            runCommonAnimation(.reset)
//            sendCommand(._cancel)
//        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        if case let .string(msg) = message {
            answerLabel.text = msg
        }
        
//        guard let cmd = Command(message) else {
//            return
//        }
//        if cmd.action == ._log {
//            if let arr = cmd.variables, arr.count >= 2 {
//                if let n = Int(arr[1]) {
//                    log(arr[0], line:n)
//                }
//            }
//        }else {
//            if running {
//                liveLog("recv act = \(cmd.action.rawValue)")
//                onReceive(cmd.action, variables:cmd.variables)
//            }
//        }
    }
}
