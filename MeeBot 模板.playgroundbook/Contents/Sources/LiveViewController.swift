//
// Copyright © 2017 Apple Inc.  All rights reserved. 
// 

import UIKit

// Note: To use view controllers in a story board with Swift Playgrounds, 
// it currently requires the @objc declaration AND playgrounds requires the
// compiled storyboard, which this project automatically inserts into the 
// playground book's resource directory.

@objc(LiveViewController)
public class LiveViewController: UIViewController {
    
    public static func makeFromStoryboard() -> LiveViewController {
        let bundle = Bundle(for: LiveViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        return storyboard.instantiateInitialViewController() as! LiveViewController
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()        
    }

    public override var prefersStatusBarHidden: Bool {
        return true
    }
}

