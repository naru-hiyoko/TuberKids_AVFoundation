//
//  MovieStorage.swift
//  TuberKids
//
//  Created by 成沢淳史 on 10/17/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Cocoa
import Foundation
import AVFoundation

protocol VideoEditControllerProtocol {
    var sourceURL : URL? { get set }
    var outputURL : URL? { get set }
    var sourceAsset : AVAsset? { get }
    
    var composition : AVMutableComposition? { get set }

}

class VideoEditController : NSObject, VideoEditControllerProtocol
{
    var sourceURL : URL?
    var outputURL : URL?
    
    var resources: [URL]! = []
    
    var composition: AVMutableComposition? = AVMutableComposition()
    
    var session : AVAssetExportSession?
    
    var sourceAsset : AVAsset? {
        guard let url = self.sourceURL else {
            return nil
        }
        return AVAsset(url: url) 
    }
    
    var presetName : String? = nil
    
    
    override init() {
        super.init()
    }

    
    func loadSourceFile(_ url : URL) 
    {
        var arr :[Bool] = []
        for s in ["mov", "mp4"] {
            if url.pathExtension.lowercased().contains(s) {
                arr.append(true)
            } else {
                arr.append(false)
            }
        }
        if !arr.contains(true) {
            return
        }

        
        self.sourceURL = url
        let vTrack : AVMutableCompositionTrack = self.composition!.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: 0xAA)
        let svTrack = self.sourceAsset!.tracks(withMediaType: AVMediaTypeVideo)[0]
        try! vTrack.insertTimeRange(svTrack.timeRange, of: svTrack, at: kCMTimeZero)
        
        let aTrack = self.composition!.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0xAB)
        aTrack.preferredVolume = 1.0
        
        if self.sourceAsset!.tracks(withMediaType: AVMediaTypeAudio).count == 0 
        {
            // audio track がない場合
            let path = Bundle.main.path(forSoundResource: "noSound.mp3")
            let url = NSURL(fileURLWithPath: path!) as URL
            let saTrack = AVAsset(url: url).tracks(withMediaType: AVMediaTypeAudio)[0]
            try! aTrack.insertTimeRange(saTrack.timeRange, of: saTrack, at: kCMTimeZero)
            // ビデオの再生時間分の長さを確保する
            let duration = CMTimeMakeWithSeconds(floor(vTrack.timeRange.end.seconds - aTrack.timeRange.end.seconds), 600)
            try! aTrack.insertEmptyTimeRange(CMTimeRangeMake(kCMTimeZero, duration))
            
        } else {
            let saTrack = self.sourceAsset!.tracks(withMediaType: AVMediaTypeAudio)[0]                  
            try! aTrack.insertTimeRange(saTrack.timeRange, of: saTrack, at: kCMTimeZero)                
        }
        
        return 
    }
    
    func load(_ files : [URL]) -> Bool
    {
        for url in files {
            if self.sourceURL == nil 
            {
                self.loadSourceFile(url) 
                
            } else {
                print(url.path)
//                self.resources.append(url)
            }
        }
        return true        

    }
    
    func deleteData()
    {
        self.sourceURL = nil
        self.composition = nil
        self.composition = AVMutableComposition()
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
    
    func insertAudioEffect(resourcePath path : URL, duration : CMTimeRange, mute : Bool = false, volume : Float = 1.0) -> CMPersistentTrackID?
    {
        let asset = AVAsset(url: path)
        let _audioTrack = asset.tracks(withMediaType: AVMediaTypeAudio)[0]
        let __audioTrack = self.composition!.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        __audioTrack.preferredVolume = volume
        
        do {
            try __audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeMake(1, 600)), of: _audioTrack, at: kCMTimeZero)
            __audioTrack.insertEmptyTimeRange(CMTimeRangeMake(kCMTimeZero, duration.start))
            let r = CMTimeRangeMake(kCMTimeZero, duration.duration)
            try __audioTrack.insertTimeRange(r, of: _audioTrack, at: duration.start)

        } catch let e as NSError {
            let alert = NSAlert(error: e)
            alert.alertStyle = NSAlertStyle.critical
            alert.runModal()
            return nil
        }
        
        if mute {
            let ___audioTrack = self.composition!.track(withTrackID: 0xAB)
            ___audioTrack!.removeTimeRange(duration)
            ___audioTrack!.insertEmptyTimeRange(duration)
        }
        
        return __audioTrack.trackID
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
        imageLayer.contents = NSImage(contentsOf: path)
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
            
            
            if datum.type! == AVMediaTypeImage {
                imageLayer.contents = NSImage(contentsOf: datum.url!)
            }
            
            if datum.type! == AVMediaTypeText {
                imageLayer.contents = datum.layer.contents
            }


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

            
            
            if datum.type == AVMediaTypeImage || datum.type == AVMediaTypeText 
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
    
    func insertVideo(resourcePath path : URL, atTime time : CMTime)
    {
        let asset = AVAsset(url: path)
        let timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        do {
            try self.composition!.insertTimeRange(timeRange, of: asset, at: time)
        } catch let e as NSError {
            let panel = NSAlert(error: e)
            panel.runModal()
        }
        
    }
    
    
    func export(videoComposition : AVVideoComposition? = nil, audioMix : AVAudioMix? = nil,
                audioOnly : Bool = false, range : CMTimeRange? = nil, presetName: String = AVAssetExportPreset640x480)
    {
        
        func removeFile(url : URL)
        {
            if FileManager.default.fileExists(atPath: url.path)
            {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch let e {
                    print(e)
                }
            }
            
        }

        if audioOnly 
        {
            
            let panel = NSSavePanel()
            panel.allowedFileTypes = ["m4a"]
            
            if panel.runModal() == NSModalResponseOK {
                let url = panel.url!
                removeFile(url: url)
                self.session = AVAssetExportSession(asset: self.composition!, presetName: AVAssetExportPresetAppleM4A)
                session!.outputFileType = AVFileTypeAppleM4A
                session!.outputURL = url
                session!.shouldOptimizeForNetworkUse = true
                session!.timeRange = range!
                session!.exportAsynchronously(completionHandler: {
                    //
                })
                self.exportDelegate(session!)                
            } else {
                
            }

            
        } else {
        
            let panel = NSSavePanel()
            panel.allowedFileTypes = ["mp4"]
            if panel.runModal() == NSModalResponseOK {
                let url = panel.url!
                removeFile(url: url)
                self.session = AVAssetExportSession(asset: self.composition!, presetName: presetName)
                session!.outputFileType = AVFileTypeMPEG4
                session!.outputURL = url
                session!.shouldOptimizeForNetworkUse = true
                session!.videoComposition = videoComposition
                session!.audioMix = audioMix
                if range == nil {
                    session!.timeRange = CMTimeRangeMake(kCMTimeZero, self.composition!.duration)
                } else {
                    session!.timeRange = range!
                }
                session!.exportAsynchronously(completionHandler: {
                    //
                })
                self.exportDelegate(session!)
            } else {
                
            }
        }
        

    }
    
    
    
    func exportWithConstrains(cropRectangle rect : CGRect? = nil, timeRange range : CMTimeRange? = nil, audioOnly : Bool = false)
    {

        print(range!.start.seconds)
        print(range!.end.seconds)
        
        if audioOnly
        {
            self.export(videoComposition: nil, audioMix: nil, audioOnly: true, range: range)
            return
        }
        
        
        let preferedSize = CGRect(x: 0, y: 0, width: self.composition!.naturalSize.width, height: self.composition!.naturalSize.height)   
        
        let cropSize = CGRect(x: rect!.minX * preferedSize.width, y: preferedSize.height * (1.0 - rect!.maxY),
                                  width: rect!.width * preferedSize.width, height: rect!.height * preferedSize.height)

        let videoComposition = AVMutableVideoComposition(propertiesOf: self.composition!)
        let parentLayer = CALayer()
        let videoLayer = CALayer()

        parentLayer.frame = CGRect(x: 0, y: 0, width: cropSize.width, height: cropSize.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: cropSize.width, height: cropSize.height)
        parentLayer.addSublayer(videoLayer)

        
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.renderSize = cropSize.size

        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = self.composition!.track(withTrackID: 0xAA)!.timeRange
        instruction.enablePostProcessing = true
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: self.composition!.track(withTrackID: 0xAA)!)
        let t = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: -1 * cropSize.minX,  ty: -1 * cropSize.minY)
        layerInstruction.setTransform(t, at: kCMTimeZero)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        let audioMix = AVMutableAudioMix()
        let audioParam = AVMutableAudioMixInputParameters(track: self.composition!.track(withTrackID: 0xAB)!)
        audioParam.setVolume(1.0, at: kCMTimeZero)
        audioMix.inputParameters = [audioParam]
        
        self.export(videoComposition: videoComposition, audioMix: audioMix, range : range)
        
        
    }
    
    
    func removeTrackWithId(_ id : CMPersistentTrackID)
    {
        let track = self.composition!.track(withTrackID: id)
        self.composition!.removeTrack(track!)
    }
    
    var exportDelegate : ((_ session : AVAssetExportSession) -> Void) = { (session : AVAssetExportSession) in 
        //
    }

    
}



