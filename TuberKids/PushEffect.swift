//
//  PushEffect.swift
//  TuberKids
//
//  Created by 成沢淳史 on 2017/01/27.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

extension AVPrevView
{
    
    /**
     region must be normalized to 0 ... 1.
     */
    func pushImageEffect(resourcePath path : URL, duration : CMTimeRange, region : CGRect? = nil,
                         options : Dictionary<String, AnyObject>?)
    {
        
        
        let layer = CALayer()
        layer.contents = NSImage(contentsOf: path)
        layer.frame = self.getSuitFrameSize(region)
        
        let datum : EffectData = EffectData(layer: layer, normalizedFrame: region, timeRange: duration, url: path,
                                            type: AVMediaTypeImage, trackId: nil, options: options)
        
        self.effects.append(datum)
        self.effectParentLayer.addSublayer(layer)
        
        self.layer?.insertSublayer(self.effectParentLayer, above: self.videoLayer)
        self.layer?.insertSublayer(self.selectedRigion!, above: self.effectParentLayer)
        
    }
    
    func pushTextEffect(text : String, resourcePath path : URL, duration : CMTimeRange, region : CGRect? = nil,
                        options: Dictionary<String, AnyObject>? = nil)
    {
        let layer = CALayer()
        
        var isVertical = false
        if options != nil {
            isVertical = options!["isVertical"] as! Bool
        }
        
        let font : NSFont? = options!["font"] as? NSFont
        
        if isVertical {
            let image = textImageVertical(text: text, font: font, texture: path)
            layer.contents = image!        
        } else {
            let image = textImage(text: text, font: font, texture: path)
            layer.contents = image!        
        }
        
        layer.frame = self.getSuitFrameSize(region)
        
        let datum : EffectData = EffectData(layer: layer, normalizedFrame: region, timeRange: duration,
                                            url: path, type: AVMediaTypeText, trackId: nil, options: options)
        self.effects.append(datum)
        self.effectParentLayer.addSublayer(layer)
        
        self.layer?.insertSublayer(self.effectParentLayer, above: self.videoLayer)
        self.layer?.insertSublayer(self.selectedRigion!, above: self.effectParentLayer)
        self.selectedRigion?.isHidden = true        
    }
    
    func pushAudioEffect(resourcePath path : URL, duration : CMTimeRange, region : CGRect? = nil,
                         trackId : CMPersistentTrackID, options: Dictionary<String, AnyObject>?)
    {
        let layer = CALayer()
        let image = NSImage(named: "sound")
        layer.contents = image!
        layer.frame = self.getSuitFrameSize(region)
        
        let datum : EffectData = EffectData(layer: layer, normalizedFrame: region, timeRange: duration,
                                            url: path, type: AVMediaTypeAudio, trackId: trackId, options: options)
        self.effects.append(datum)
        self.effectParentLayer.addSublayer(layer)
        
        self.layer?.insertSublayer(self.effectParentLayer, above: self.videoLayer)
        //self.layer?.insertSublayer(self.selectedRigion!, above: self.effectParentLayer)
        self.selectedRigion?.isHidden = true
        
    }
    
    func pushVideoEffect(resourcePath path : URL, timeRange : CMTimeRange, region : CGRect? = nil)
    {
        
        let player = AVPlayer(url: path)
        let layer = AVPlayerLayer(player: player)
        layer.frame = self.getSuitFrameSize(region)
        
        let options : Dictionary<String, AnyObject> = [
            "player" : player, 
            ]
        
        let datum = EffectData(layer: layer, normalizedFrame: region, timeRange: timeRange, url: path, type: AVMediaTypeVideo, trackId: nil, options: options)
        self.effects.append(datum)
        self.effectParentLayer.addSublayer(layer)
        self.layer?.insertSublayer(self.effectParentLayer, above: self.videoLayer)        
        self.selectedRigion?.isHidden = true        
        
    }
    
    
    
}
