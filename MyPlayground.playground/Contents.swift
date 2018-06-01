//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

func eat(_ name: String) {
    
}

eat("")

let numbers = [1,5,1,8,8,8,8,8,8,8,8]
print(numbers)
// reduce 函数第一个参数是返回值的初始化值
let tel = numbers.reduce("", { _,_ in "($0)" + "($1)" })
// 15188888888
print(tel)
