//
//  InsertEffectMethods.swift
//  TuberKids
//
//  Created by 成沢淳史 on 2017/03/02.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

extension VideoEditController
{
    
    func convert(_ rect: CGRect,  to: CGRect) -> CGRect
    {
        return CGRect.init(x: rect.minX * to.width, y: rect.minY * to.height,
                           width: rect.width * to.width, height: rect.height * to.height)
        
    }


    func insertAudioEffect(resourcePath path : URL, atTime time : CMTime, volume : Float = 1.0) -> CMPersistentTrackID
    {
    
        let asset : AVAsset = AVAsset(url: path)
        let _audioTrack = asset.tracks(withMediaType: AVMediaTypeAudio)[0]
        let __audioTrack = self.composition!.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        __audioTrack.preferredVolume = volume
    
        try! __audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeMake(1, 600)), of: _audioTrack, at: kCMTimeZero)
        __audioTrack.insertEmptyTimeRange(CMTimeRangeMake(kCMTimeZero, time))
        try! __audioTrack.insertTimeRange(_audioTrack.timeRange, of: _audioTrack, at: time)
    
        __audioTrack.preferredVolume = volume        
        return __audioTrack.trackID
    }

    func insertAudioEffect(resourcePath path : URL, timeRange t: CMTimeRange, mute : Bool = false, volume : Float = 1.0) -> CMPersistentTrackID?
    {
        
        let asset = AVAsset(url: path)
        let _audioTrack = asset.tracks(withMediaType: AVMediaTypeAudio)[0]
        let __audioTrack = self.composition!.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        __audioTrack.preferredVolume = volume
    
        do {
            try __audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeMake(1, 600)), of: _audioTrack, at: kCMTimeZero)
            __audioTrack.insertEmptyTimeRange(CMTimeRangeMake(kCMTimeZero, t.start))
            let r = CMTimeRangeMake(kCMTimeZero, t.duration)
            try __audioTrack.insertTimeRange(r, of: _audioTrack, at: t.start)
        } catch let e as NSError {
            popWarnPanel(e)
            return nil
        }

    
        return __audioTrack.trackID
    }
    
    
    private func cutRangeVolume(range t: CMTimeRange)
    {
        let _track = self.composition!.track(withTrackID: 0xAB)
        _track!.removeTimeRange(t)
        _track!.insertEmptyTimeRange(t)
    }

    /**
     inFrame is a rect which the image layer should draw in. 
     */

    func insertImageEffect(resourcePath path : URL, duration : CMTimeRange, inFrame : CGRect? = nil)
    {
        let videoComposition : AVMutableVideoComposition = AVMutableVideoComposition(propertiesOf: self.composition!)
    
        let preferedSize = CGRect(x: 0, y: 0, width: self.composition!.naturalSize.width, height: self.composition!.naturalSize.height)
        let parentLayer = CALayer()
        parentLayer.frame = preferedSize
        
        let videoLayer = CALayer()
        videoLayer.frame = preferedSize
    
        let imageLayer = CALayer()
        if inFrame == nil {
            imageLayer.frame = preferedSize
        } else {
            imageLayer.frame = CGRect(x: inFrame!.minX * preferedSize.width, y: inFrame!.minY * preferedSize.height,
                                      width: inFrame!.width * preferedSize.width,  height: inFrame!.height * preferedSize.height)
        }
        //warn
        imageLayer.contents = NSImage(contentsOf: path)!.layerContents(forContentsScale: 1.0)
        imageLayer.opacity = 0.0
    
    
        let anim : CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 1.0
        anim.toValue = 1.0
        anim.beginTime = AVCoreAnimationBeginTimeAtZero + duration.start.seconds
        anim.duration = duration.end.seconds - duration.start.seconds
        anim.isRemovedOnCompletion = false
    
        imageLayer.add(anim, forKey: nil)
    
    
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(imageLayer)
    
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        videoComposition.frameDuration = CMTimeMake(1, 30)        
        videoComposition.renderSize = self.composition!.naturalSize
    
    
        let videoCompositionInstruction = AVMutableVideoCompositionInstruction()
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: self.composition!.track(withTrackID: 0xAA)!)
    
        videoCompositionInstruction.enablePostProcessing = true
        videoCompositionInstruction.timeRange = self.composition!.track(withTrackID: 0xAA)!.timeRange
    
    
        videoCompositionInstruction.layerInstructions = [layerInstruction]        
    
        videoComposition.instructions = [videoCompositionInstruction]                
    
        export(videoComposition: videoComposition)
    
    }

    func export(_ effects: [EffectData])
    {
        let videoComposition = AVMutableVideoComposition(propertiesOf: self.composition!)
        var layerInstructions: [AVMutableVideoCompositionLayerInstruction] = []
        let naturalSize = self.composition!.naturalSize

        let preferedSize = CGRect.init(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
        
        let audioMix = AVMutableAudioMix()
        var audioParams: [AVMutableAudioMixInputParameters] = []
        
        let parentLayer = CALayer()
        parentLayer.frame = preferedSize
        
        let videoLayer = CALayer()
        videoLayer.frame = preferedSize
        
        parentLayer.addSublayer(videoLayer)
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.renderSize = preferedSize.size

        print("operating \(effects.count) items")


        for datum in effects
        {
            switch datum.type! {
            case EffectData.EffectType.image:
                print("image")
                let layer = CALayer()
                layer.opacity = 0.0
                layer.frame = convert(datum.rect, to: preferedSize)
                layer.contents = NSImage.init(contentsOf: datum.url)!.layerContents(forContentsScale: 1.0)
                let basicAnimation = VideoEditController.getDefaultAnimation(datum)
                layer.add(basicAnimation, forKey: nil)
                parentLayer.addSublayer(layer)

            case EffectData.EffectType.audio:
                print("audio")
                let trackId = insertAudioEffect(resourcePath: datum.url, atTime: datum.timeRange.start, volume: datum.volume!)
                let track = self.composition!.track(withTrackID: trackId)!
                let params = AVMutableAudioMixInputParameters.init(track: track)
                params.setVolume(datum.volume, at: kCMTimeZero)
                audioParams.append(params)
            case EffectData.EffectType.video:
                print("video")
                let _asset = AVAsset(url: datum.url! as URL)
                let rect = datum.rect!
                
                let _videoTrack = _asset.tracks(withMediaType: AVMediaTypeVideo)[0]
                let _audioTrack = _asset.tracks(withMediaType: AVMediaTypeAudio)[0]
                
                var track: AVMutableCompositionTrack!
                track = self.composition!.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
                do {
                    try track.insertTimeRange(_videoTrack.timeRange, of: _videoTrack, at: kCMTimeZero)
                } catch let e {
                    popWarnPanel(e as NSError)
                    return
                }
                
                track.insertEmptyTimeRange(CMTimeRangeMake(kCMTimeZero, datum.timeRange.start))
                track.removeTimeRange(CMTimeRangeMake(datum.timeRange.end, track.timeRange.end))
                
                let _videoInstructionLayer = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
                _videoInstructionLayer.setOpacity(0.0, at: kCMTimeZero)
                _videoInstructionLayer.setOpacity(1.0, at: datum.timeRange.start)                
                _videoInstructionLayer.setOpacity(0.0, at: datum.timeRange.end)  
                
                let sx = preferedSize.width / _videoTrack.naturalSize.width
                let sy = preferedSize.height / _videoTrack.naturalSize.height  
                
//                let cropSize = CGRect(x: rect.minX * preferedSize.width , y: (1.0 - rect.maxY) * preferedSize.height,
//                                      width: sx * rect.width * preferedSize.width, height: sy * rect.height * preferedSize.height)
                

                var t = CGAffineTransform.identity
                t = t.translatedBy(x: rect.minX * preferedSize.width, y: (1.0 - rect.maxY) * preferedSize.height)                
                t = t.scaledBy(x: sx * rect.width, y: sy * rect.height)                


                _videoInstructionLayer.setTransform(t, at: kCMTimeZero)
                
                layerInstructions.append(_videoInstructionLayer)
                
                
                track = self.composition!.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
                do {
                    try track.insertTimeRange(_audioTrack.timeRange, of: _audioTrack, at: kCMTimeZero)
                } catch let e {
                    popWarnPanel(e as NSError)
                    return
                }
                track.insertEmptyTimeRange(CMTimeRangeMake(kCMTimeZero, datum.timeRange.start))
                track.removeTimeRange(CMTimeRangeMake(datum.timeRange.end, track.timeRange.end))
                
                let audioParam = AVMutableAudioMixInputParameters(track: track) 
                audioParam.setVolumeRamp(fromStartVolume: datum.volume, toEndVolume: datum.volume, timeRange: datum.timeRange)
                audioParams.append(audioParam)
            }
            
        }
        
        let videoInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        videoInstruction.enablePostProcessing = true
        videoInstruction.timeRange = self.composition!.track(withTrackID: 0xAA)!.timeRange
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: self.composition!.track(withTrackID: 0xAA)!)
        layerInstruction.setOpacity(1.0, at: kCMTimeZero)
        
        
        layerInstructions.append(layerInstruction)
        videoInstruction.layerInstructions = layerInstructions
        
        videoComposition.instructions = [videoInstruction]
        
        
        let audioParam = AVMutableAudioMixInputParameters(track: self.composition!.track(withTrackID: 0xAB)!)
        audioParam.setVolume(1.0, at: kCMTimeZero)
        audioParams.append(audioParam)
        
        audioMix.inputParameters = audioParams
        
        let start = kCMTimeZero
        let end = CMTimeMakeWithSeconds(floor(self.composition!.duration.seconds), 600)
        let range = CMTimeRangeMake(start, end)
        
        export(videoComposition: videoComposition, audioMix: audioMix, range : range)
        
        
    }


    func insertImageEffectsWithSet(effectData data : [EffectData])
    {
        let videoComposition = AVMutableVideoComposition(propertiesOf: self.composition!)
        var layerInstructions : [AVMutableVideoCompositionLayerInstruction] = []
        let preferedSize = CGRect(x: 0, y: 0, width: self.composition!.naturalSize.width, height: self.composition!.naturalSize.height)
        
        let audioMix = AVMutableAudioMix()   
        var audioParams : [AVAudioMixInputParameters] = []
        
        let parentLayer = CALayer()
        parentLayer.frame = preferedSize
        
        let videoLayer = CALayer()
        videoLayer.frame = preferedSize
        
        parentLayer.addSublayer(videoLayer)        
        
        for datum in data 
        {
        
            let imageLayer = CALayer()
            imageLayer.opacity = 0.0
        
        
//            if datum.type! == AVMediaTypeImage {
//                imageLayer.contents = NSImage(contentsOf: datum.url!)
//            }
        
        /*
        if datum.normalizedFrame != nil {
            imageLayer.frame = CGRect(x: datum.normalizedFrame!.minX * preferedSize.width, y: datum.normalizedFrame!.minY * preferedSize.height, 
                                      width: datum.normalizedFrame!.width * preferedSize.width, height: datum.normalizedFrame!.height * preferedSize.height) 
        } else {
            imageLayer.frame = preferedSize
        }
        
        
        if datum.type == AVMediaTypeAudio
        {
            let track = self.composition?.track(withTrackID: datum.trackId!)
            track?.removeTimeRange(CMTimeRangeMake(datum.timeRange.end, track!.timeRange.end))
            let audioMixparam = AVMutableAudioMixInputParameters(track: track)
            audioMixparam.setVolume(track!.preferredVolume, at: kCMTimeZero)
            audioParams.append(audioMixparam)
            continue
        }
        
        

        if datum.type == AVMediaTypeImage 
        {
            
            switch datum.options!["key"] as! Int {
            case AnimationStyle.fade.rawValue:
                let animations = self.getFadeAnimation(datum: datum)
                let animationA = animations[0]
                let animationB = animations[1]
                
                if animationB.duration < 0 {
                    imageLayer.add(animationA, forKey: nil)
                } else {
                    imageLayer.add(animationA, forKey: nil)
                    imageLayer.add(animationB, forKey: nil)
                }
                
            case AnimationStyle.scale.rawValue :
                let animations = self.getScaleAnimation(datum: datum)
                let animationA = animations[0]
                let animationB = animations[1]
                let animationC = animations[2]
                
                imageLayer.add(animationA, forKey: nil)
                imageLayer.add(animationB, forKey: nil)
                imageLayer.add(animationC, forKey: nil)
                
                
                
            case AnimationStyle.rotation.rawValue :
                let animations = self.getRotationAnimation(datum: datum)
                let animationA = animations[0]
                let animationB = animations[1]
                let animationC = animations[2]
                
                imageLayer.add(animationA, forKey: nil)
                imageLayer.add(animationB, forKey: nil)
                imageLayer.add(animationC, forKey: nil)
                
                
                
            default:
                let animation = self.getDefaultAnimation(datum: datum)
                imageLayer.add(animation, forKey: nil)
                
            }
            
            parentLayer.addSublayer(imageLayer)                
            
        }
 
        
        
        if datum.type == AVMediaTypeVideo
        {
            let _asset = AVAsset(url: datum.url! as URL)
            let nFrame = datum.normalizedFrame!
            let cropSize = CGRect(x: nFrame.minX * preferedSize.width , y: (1.0 - nFrame.maxY) * preferedSize.height,
                                  width: nFrame.width * preferedSize.width, height: nFrame.height * preferedSize.height)
            
            
            let _videoTrack = _asset.tracks(withMediaType: AVMediaTypeVideo)[0]
            let _audioTrack = _asset.tracks(withMediaType: AVMediaTypeAudio)[0]
            
            
            let track = self.composition!.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try track.insertTimeRange(_videoTrack.timeRange, of: _videoTrack, at: kCMTimeZero)
            } catch let e {
                let al = NSAlert.init(error: e)
                al.runModal()
                return
            }
            
            track.insertEmptyTimeRange(CMTimeRangeMake(kCMTimeZero, datum.timeRange.start))
            track.removeTimeRange(CMTimeRangeMake(datum.timeRange.end, track.timeRange.end))
            
            let _videoInstructionLayer = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
            _videoInstructionLayer.setOpacity(0.0, at: kCMTimeZero)
            _videoInstructionLayer.setOpacity(1.0, at: datum.timeRange.start)                
            _videoInstructionLayer.setOpacity(0.0, at: datum.timeRange.end)  
            
            let t = CGAffineTransform(a: nFrame.width, b: 0, c: 0, d: nFrame.height, tx: cropSize.minX, ty: cropSize.minY)
            _videoInstructionLayer.setTransform(t, at: kCMTimeZero)
            
            layerInstructions.append(_videoInstructionLayer)
            
            
            let _track = self.composition!.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try _track.insertTimeRange(_audioTrack.timeRange, of: _audioTrack, at: kCMTimeZero)
            } catch let e {
                let al = NSAlert.init(error: e)
                al.runModal()
                return
            }
            _track.insertEmptyTimeRange(CMTimeRangeMake(kCMTimeZero, datum.timeRange.start))
            _track.removeTimeRange(CMTimeRangeMake(datum.timeRange.end, track.timeRange.end))
            
            let audioParam = AVMutableAudioMixInputParameters(track: _track) 
            audioParam.setVolumeRamp(fromStartVolume: 1.0, toEndVolume: 1.0, timeRange: datum.timeRange)
            audioParams.append(audioParam)
            continue
        }
        
        */
        
    }
    

    
    
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.renderSize = self.composition!.naturalSize
        
        let videoInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        videoInstruction.enablePostProcessing = true
        videoInstruction.timeRange = self.composition!.track(withTrackID: 0xAA)!.timeRange
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: self.composition!.track(withTrackID: 0xAA)!)
        layerInstruction.setOpacity(1.0, at: kCMTimeZero)
        
        
        layerInstructions.append(layerInstruction)
        videoInstruction.layerInstructions = layerInstructions
        
        videoComposition.instructions = [videoInstruction]
        
        
        let audioParam = AVMutableAudioMixInputParameters(track: self.composition!.track(withTrackID: 0xAB)!)
        audioParam.setVolume(1.0, at: kCMTimeZero)
        audioParams.append(audioParam)
        audioMix.inputParameters = audioParams
        
        let start = kCMTimeZero
        let end = CMTimeMakeWithSeconds(floor(self.composition!.duration.seconds), 600)
        let range = CMTimeRangeMake(start, end)
        
        export(videoComposition: videoComposition, audioMix: audioMix, range : range)
        
    }
    
    func insertVideo(resourcePath path: URL, at: CMTime, duration: CMTime)
    {
        let asset = AVAsset(url: path)  
        do 
        {
            let t = CMTimeRange(start: kCMTimeZero, duration: duration)
            try self.composition!.insertTimeRange(t, of: asset, at: at)
        } catch let e {
            popWarnPanel(e as NSError)
        }
    }
    
    @available (*, deprecated: 2.00)
    func insertVideo(resourcePath path : URL, duration : CMTimeRange)
    {
        let asset = AVAsset(url: path)
        let timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(duration.end.seconds - duration.start.seconds, 600))
        do {
            try self.composition!.insertTimeRange(timeRange, of: asset, at: duration.start)
        } catch let e as NSError {
            let panel = NSAlert(error: e)
            panel.runModal()
        }
    }
    


}
