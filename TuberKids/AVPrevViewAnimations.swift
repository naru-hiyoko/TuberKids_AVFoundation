//
//  AVPrevViewEX.swift
//  TuberKids
//
//  Created by 成沢淳史 on 11/9/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation


extension AVPreview
{
    /*
    func getFadeAnimation(datum : EffectData) -> CABasicAnimation
    {
        let options = datum.options!
        let from = options["from"] as! Double
        let to = options["to"] as! Double
        let duration = options["duration"] as! Double
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.isRemovedOnCompletion = false
        animation.beginTime = CACurrentMediaTime()
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        return animation
    }
    
    func getScaleAnimation(datum : EffectData) -> CABasicAnimation
    {
        let options = datum.options!
        let from = options["from"] as! Double
        let to = options["to"] as! Double
        let duration = options["duration"] as! Double
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.isRemovedOnCompletion = false
        animation.beginTime = CACurrentMediaTime()
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        return animation
    }
    
    func getRotationAnimation(datum : EffectData) -> CABasicAnimation
    {
        let options = datum.options!
        var from = options["from"] as! Double
        var to = options["to"] as! Double
        from = from / 180.0 / M_PI
        to = to / 180.0 * M_PI
        let duration = options["duration"] as! Double
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.isRemovedOnCompletion = false
        animation.beginTime = CACurrentMediaTime()
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        return animation
    }
    
    func getSpringAnimation(datum : EffectData) -> CASpringAnimation
    {
        let options = datum.options!
        let from = options["from"] as! Double
        let to = options["to"] as! Double
//        let duration = options["duration"] as! Double
        let animation = CASpringAnimation(keyPath: "transform.rotation")
        
        animation.isRemovedOnCompletion = false
        animation.fromValue = from
        animation.toValue = to
        animation.beginTime = CACurrentMediaTime()        
        animation.mass = 10
        animation.initialVelocity = -3.0
        animation.damping = 0.0
        animation.stiffness = 5
        animation.duration = animation.settlingDuration
        
        return animation
        
        
    }
 */
    
    
}
