//
//  Common.swift
//  TuberKids
//
//  Created by 成沢淳史 on 11/4/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import AVFoundation

enum AnimationStyle : Int {
    case `default`, fade, scale, rotation, spring
}
 


open class EffectData : NSObject, NSCoding {
    
    public enum EffectType: Int {
        case image, audio, video
    }
    
    
    static var effects: [EffectData] = []
    
    var url : URL! 
    var rect: CGRect!
    var timeRange: CMTimeRange!
    
    var layer : CALayer!
    
    var player: AVPlayer?
    var audioPlayer: AVAudioPlayer?
    var volume: Float! = 1.0

    var type : EffectType!
    
    
    init(url: URL, rect: CGRect, timeRange range: CMTimeRange) {
        self.url = url
        self.rect = rect
        self.timeRange = range
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.url = aDecoder.decodeObject(forKey: "url") as! URL!

    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.url, forKey: "url")
    }
    
    func show()
    {
        if self.player != nil 
        {
            self.player!.play()
        }
        
        if self.audioPlayer != nil
        {
            self.audioPlayer!.play()
            self.audioPlayer!.volume = volume

        }
        
        self.layer.isHidden = false
    }
    
    func pause()
    {
        if self.player != nil 
        {
            self.player!.pause()
        }
        
        if self.audioPlayer != nil 
        {
            self.audioPlayer!.stop()
        }
        
        
    }
    
    func hidden()
    {
        if self.player != nil 
        {
            self.player!.pause()
            self.player!.seek(to: kCMTimeZero)
        }
        
        if self.audioPlayer != nil 
        {
            self.audioPlayer!.stop()
            self.audioPlayer?.currentTime = 0.0                                    
        }
        
        self.layer.isHidden = true
        
    }
    
    class func createWithImage(url: URL, rect: CGRect, timeRange range: CMTimeRange) -> EffectData
    {
        let datum = EffectData.init(url: url, rect: rect, timeRange: range)
        datum.type = EffectType.image
        return datum
    }
    
    class func createWithAudio(url: URL, rect: CGRect, timeRange range: CMTimeRange, player: AVAudioPlayer, volume: Double = 1.0) -> EffectData
    {
        let datum = EffectData.init(url: url, rect: rect, timeRange: range)
        datum.audioPlayer = player
        datum.volume = Float(volume)
        datum.type = EffectType.audio
        return datum
    }
    
    class func createWithVideo(url: URL, rect: CGRect, timeRange range: CMTimeRange, player: AVPlayer) -> EffectData
    {
        let datum = EffectData(url: url, rect: rect, timeRange: range)
        datum.type = EffectType.video
        datum.player = player
        return datum
    }
}
