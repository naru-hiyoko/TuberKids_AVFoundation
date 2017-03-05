//
//  VideoEditControllerEX.swift
//  TuberKids
//
//  Created by 成沢淳史 on 11/9/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

/**
    AVAssetExportSession 用
    アニメーションの定義をここに書く
    func insertImageEffectsWithSet(effectData data : [EffectData]) 中の switch case を追加すること
 
 */

extension VideoEditController
{
    
    class func getDefaultAnimation(_ datum : EffectData) -> CABasicAnimation
    {
        let timeRange = datum.timeRange  
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.isRemovedOnCompletion = false
        animation.fromValue = 1.0
        animation.toValue = 1.0
        animation.beginTime = AVCoreAnimationBeginTimeAtZero + timeRange!.start.seconds
        animation.duration = timeRange!.end.seconds - timeRange!.start.seconds
        return animation
    }
    
    /*
    func getFadeAnimation(datum : EffectData) -> [CABasicAnimation]
    {
        let timeRange = datum.timeRange   
        
        let animationA = CABasicAnimation(keyPath: "opacity")
        animationA.isRemovedOnCompletion = false
        animationA.fromValue = datum.options!["from"] as! Double
        animationA.toValue = datum.options!["to"] as! Double                    
        animationA.duration = datum.options!["duration"] as! Double
        animationA.beginTime = datum.timeRange.start.seconds
        
        let animationB = CABasicAnimation(keyPath: "opacity")
        animationB.isRemovedOnCompletion = false
        animationB.fromValue = datum.options!["to"] as! Double                    
        animationB.toValue = datum.options!["to"] as! Double                                        
        animationB.duration = timeRange.duration.seconds - (datum.options!["duration"] as! Double)
        animationB.beginTime = datum.timeRange.start.seconds + (datum.options!["duration"] as! Double)
    
        return [animationA, animationB]
    }
    
    func getScaleAnimation(datum : EffectData) -> [CABasicAnimation]
    {
        let timeRange = datum.timeRange   
        
        let animationA = CABasicAnimation(keyPath: "transform.scale")
        animationA.isRemovedOnCompletion = false
        animationA.fromValue = datum.options!["from"] as! Double
        animationA.toValue = datum.options!["to"] as! Double                    
        animationA.duration = datum.options!["duration"] as! Double
        animationA.beginTime = datum.timeRange.start.seconds
        
        var animationB = CABasicAnimation(keyPath: "transform.scale")
        animationB.isRemovedOnCompletion = false
        animationB.fromValue = datum.options!["to"] as! Double                    
        animationB.toValue = datum.options!["to"] as! Double                                        
        animationB.duration = timeRange.duration.seconds - (datum.options!["duration"] as! Double)
        animationB.beginTime = datum.timeRange.start.seconds + (datum.options!["duration"] as! Double)
        
        let animationC = self.getDefaultAnimation(datum: datum)
        
        if animationB.duration < 0 {
          animationB = CABasicAnimation()  
        }
        
        return [animationA, animationB, animationC]
        
        
    }
    
    func getRotationAnimation(datum : EffectData) -> [CABasicAnimation]
    {
        let timeRange = datum.timeRange   
        
        let animationA = CABasicAnimation(keyPath: "transform.rotation")
        animationA.isRemovedOnCompletion = false
        animationA.fromValue = (datum.options!["from"] as! Double) / 180.0 * M_PI
        animationA.toValue = (datum.options!["to"] as! Double) / 180.0 * M_PI
        animationA.duration = datum.options!["duration"] as! Double
        animationA.beginTime = datum.timeRange.start.seconds
        
        var animationB = CABasicAnimation(keyPath: "transform.rotation")
        animationB.isRemovedOnCompletion = false
        animationB.fromValue = (datum.options!["to"] as! Double) / 180.0 * M_PI
        animationB.toValue = (datum.options!["to"] as! Double) / 180.0 * M_PI
        animationB.duration = timeRange.duration.seconds - (datum.options!["duration"] as! Double)
        animationB.beginTime = datum.timeRange.start.seconds + (datum.options!["duration"] as! Double)
        
        let animationC = self.getDefaultAnimation(datum: datum)
        
        if animationB.duration < 0 {
            animationB = CABasicAnimation()  
        }
        
        return [animationA, animationB, animationC]
        
        
    }    
    
    */
    
    
}
