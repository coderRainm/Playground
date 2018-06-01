import UIKit
import PlaygroundSupport

public class LiveViewController : UIViewController {
    public var questionField = UITextField()
    public var askBtn = UIButton(type: .custom)
    public var answerLabel = UILabel()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        questionField.placeholder = "input question"
        questionField.frame = CGRect(x: 50, y: 200, width: 100, height: 40)
        questionField.font = UIFont.systemFont(ofSize: 10)
//        questionField.backgroundColor = UIColor.black
        askBtn.addTarget(self, action: #selector(askQuestion), for: .touchUpInside)
        askBtn.setTitle("ask", for: .normal)
        askBtn.frame = CGRect(x: 50, y: 250, width: 50, height: 40)
        askBtn.backgroundColor = UIColor.red
        answerLabel.frame = CGRect(x: 50, y:300, width: 100, height: 40)
        answerLabel.backgroundColor = UIColor.white
        view.addSubview(questionField)
        view.addSubview(askBtn)
        view.addSubview(answerLabel)
    }
    
    @objc func askQuestion() {
        send(.string("Whatisyourname?"))
    }
}
