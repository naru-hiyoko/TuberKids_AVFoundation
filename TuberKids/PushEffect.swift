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
    func pushImageEffect(resourcePath url : URL, timeRange range: CMTimeRange, region : CGRect)
    {
        
        let layer = CALayer()
        layer.contents = NSImage(contentsOf: url)!.layerContents(forContentsScale: 1.0)
        layer.frame = self.convertToLayer(region)
        
        let datum = EffectData.createWithImage(url: url, rect: region, timeRange: range)
        datum.layer = layer
        
        EffectData.effects.append(datum)

        self.effectParentLayer.addSublayer(layer)
        
    }

    
    func pushAudioEffect(resourcePath url: URL, timeRange range: CMTimeRange, region: CGRect, volume: Double = 1.0)
    {
        let layer = CALayer()
        let image = NSImage(named: "sound")
        layer.contents = image!.layerContents(forContentsScale: 1.0)
        layer.frame = self.convertToLayer(region)
        let player = try! AVAudioPlayer.init(contentsOf: url)
        
        let datum = EffectData.createWithAudio(url: url, rect: region, timeRange: range, player: player, volume: volume)
        datum.layer = layer
        EffectData.effects.append(datum)
        
        self.effectParentLayer.addSublayer(layer)
        
    }
    
    func pushVideoEffect(resourcePath url : URL, timeRange : CMTimeRange, region : CGRect, volume: Double = 1.0)
    {
        
        let player = AVPlayer(url: url)
        let layer = AVPlayerLayer(player: player)
        layer.frame = self.convertToLayer(region)
        let datum = EffectData.createWithVideo(url: url, rect: region, timeRange: timeRange, player: player)
        datum.layer = layer
        datum.volume = Float(volume)
        EffectData.effects.append(datum)
        
        self.effectParentLayer.addSublayer(layer)


        
    }
    
    
    
}
