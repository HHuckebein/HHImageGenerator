//
//  ViewController.swift
//  HHImageGenerator
//
//  Created by Bernd Rabe on 06.09.15.
//  Copyright (c) 2015 RABE_IT Services. All rights reserved.
//

import UIKit
import GLKit
class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = HHImageGenerator.imageWithSize(CGSize(width: 100.0, height: 100.0), color: UIColor.redColor(), backgroundColor: UIColor.whiteColor(), dashPattern: [50.0, 50,0], identifier: .RectangleWithStripesLeft) {
            let color = UIColor(patternImage: image)
            view.backgroundColor = color
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            if let image = self.imageView.image {
//                self.imageView.image = HHImageGenerator.rotatedImage(image, rotationAngle: GLKMathDegreesToRadians(45.0))
//            }
        }
    }
}

