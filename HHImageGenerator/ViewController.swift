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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        let delayTime = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
//            if let image = self.imageView.image {
//                self.imageView.image = HHImageGenerator.rotatedImage(image, rotationAngle: GLKMathDegreesToRadians(45.0))
//            }
        }
    }
}

