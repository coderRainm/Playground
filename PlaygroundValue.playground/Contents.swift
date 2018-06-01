//: Playground - noun: a place where people can play

import UIKit

enum PlaygroundValue {
    case array(Array<Any>)
    case dictionary(Dictionary<String, Any>)
    case string(String)
    case data(Data)
    case date(Date)
    case integer(Int)
    case floatingPoint(Float)
    case boolean(Bool)
}

let v: PlaygroundValue = .array([1])
let key: PlaygroundValue = .dictionary(["1": ""])



