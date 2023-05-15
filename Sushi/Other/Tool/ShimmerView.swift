//
//  ShimmerView.swift
//  iOS_ver2
//
//  Created by Hira on 2023/2/15.
//

import UIKit

class ShimmerView: UIView {

    var gradientColorOne : CGColor = UIColor(0xf0f0f0).cgColor
    var gradientColorTwo : CGColor = UIColor(0xfbfbfb).cgColor
    
    let gradientLayer = CAGradientLayer()
    
    func addGradientLayer() {
                
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        if let sublayers = self.layer.sublayers, !sublayers.contains(gradientLayer) {
            self.layer.addSublayer(gradientLayer)
        }
    }
    
    func addAnimation() -> CABasicAnimation {
       
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1.3
        return animation
    }
    
    func startAnimating() {
        
        addGradientLayer()
        let animation = addAnimation()
       
        gradientLayer.removeAllAnimations()
        gradientLayer.add(animation, forKey: animation.keyPath)
    }
    
    func stopAnimating() {
        gradientLayer.removeAllAnimations()
        gradientLayer.removeFromSuperlayer()
    }
}
