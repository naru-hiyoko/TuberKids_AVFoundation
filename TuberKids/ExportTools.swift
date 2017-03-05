//
//  ExportTools.swift
//  TuberKids
//
//  Created by 成沢淳史 on 2017/03/02.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa


fileprivate func removeFile(url: URL)
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

}

extension VideoEditController
{
    
    func export(videoComposition : AVVideoComposition? = nil, audioMix : AVAudioMix? = nil,
                audioOnly : Bool = false, range : CMTimeRange? = nil, presetName: String = AVAssetExportPreset640x480)
    {
        
        
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
    
    
    func cancelExport()
    {
        self.session!.cancelExport()
    }
   


    
}
