//
//  extensionUiView.swift
//  Tour Manager
//
//  Created by SHREDDING on 06.05.2023.
//

import Foundation
import UIKit

extension UIView{
    func rotate(angle:CGFloat, duration:Int,repeatCount:Int) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: angle )
        rotation.duration = CFTimeInterval(duration)
        rotation.isCumulative = true
        rotation.repeatCount = Float(repeatCount)
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}
