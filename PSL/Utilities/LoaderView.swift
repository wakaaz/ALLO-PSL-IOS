//
//  LoaderView.swift
//  PSL
//
//  Created by MacBook on 29/03/2021.
//

import UIKit

class LoaderView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = .pi * 2.0 * 2 * 60.0
        rotationAnimation.duration = 200.0
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float.infinity
        self.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
}
