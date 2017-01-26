//
//  ViewControllerEX.swift
//  TuberKids
//
//  Created by 成沢淳史 on 2017/01/05.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

extension ViewController
{

    func rangeIndicatorModified()
    {
        DispatchQueue.main.async(execute: {
            self.seekBar.minValue = Double(self.rangeIndicaterView.minValueAorB)
            self.seekBar.maxValue = Double(self.rangeIndicaterView.maxValueAorB)
            self.seekBar.doubleValue = Double(self.rangeIndicaterView.minValueAorB)
            let t = CMTimeMakeWithSeconds(self.seekBar.minValue, 600)
            let tolerance = CMTimeMakeWithSeconds(0.05, 600)
            self.preview.avPlayer?.seek(to: t, toleranceBefore: tolerance, toleranceAfter: tolerance)
        })
    }
    
    func itemDropped(items : [NSURL])
    {
        if !self.video_editer.load(items.last! as URL) { return }
        if self.video_editer.resources.count == 0 {
            self.setupPreview(self.video_editer.composition!)
        }
        self.itemView.items = self.video_editer.resources
        self.itemView.reloadData()
    }
    
    func itemDropped(row : Int)
    {
        let from = self.fromValueField.doubleValue
        let to = self.toValueField.doubleValue
        let duration = CMTimeRangeMake(CMTimeMakeWithSeconds(from, 600), CMTimeMakeWithSeconds(to - from, 600))
        if duration.duration.seconds <= 0 {
            let alert = NSAlert.init()
            alert.messageText = "無効な指定範囲です"
            return
        }
        
        let path = self.itemView.items[row]
        let text = self.itemView.textInRow[row]
        let volume = self.volumeValueLabel.floatValue        
        
        switch path.pathExtension {
        case let ext where ext == "mp3" || ext == "m4a" :
            
            var muteState : Bool { 
                return self.mute_button!.state == NSOnState ? true : false
            }
            
            var trackId : CMPersistentTrackID?
            
            if self.restrict_button.state == NSOnState {
                trackId = self.video_editer.insertAudioEffect(resourcePath: path, duration: duration, mute: muteState, volume: volume)                     
            } else {
                trackId = self.video_editer.insertAudioEffect(resourcePath: path, atTime: duration.start, volume: volume)                    
            }
            
            self.preview.pushAudioEffect(resourcePath: path, duration: duration, region: self.preview.normalizedSelectedRegion, trackId: trackId!)
            self.setupPreview(self.video_editer.composition!)
            let tolerance = CMTimeMakeWithSeconds(0.0001, 600)
            self.preview.avPlayer?.seek(to: duration.start, toleranceBefore: tolerance, toleranceAfter: tolerance)
            self.preview.updateVisibleState(seconds: duration.start.seconds)                
            return 
            
        case let ext where ext == "png" || ext == "jpg" || ext == "PNG" :
            
            var options : Dictionary<String, AnyObject> = ["key" : self.animationTypePopUp.indexOfSelectedItem as AnyObject]
            
            
            options = ["key" : self.animationTypePopUp.indexOfSelectedItem as AnyObject,
                       "from" : self.controllerB.from as AnyObject,
                       "to" : self.controllerB.to as AnyObject, 
                       "duration" : self.controllerB.animationDuration as AnyObject]
            
            if text != "" {
                guard let selectedRegionAspect = self.preview.selectedRegionAspect else { return }
                
                options["isVertical"] = (selectedRegionAspect > 2.0 ? true : false) as AnyObject
                options["font"] = NSFontManager.shared().selectedFont
                self.preview.pushTextEffect(text: text, resourcePath: path, duration: duration, region: self.preview.normalizedSelectedRegion, options: options)
            } else {
                // 画像の差し込み
                self.preview.pushEffect(resourcePath: path, duration: duration, region: self.preview.normalizedSelectedRegion, options: options)
            }
            
            self.preview.updateVisibleState(seconds: duration.start.seconds)
            return
            
        case let ext where ext == "mp4" || ext.caseInsensitiveCompare("mov") == ComparisonResult.orderedSame:
            self.preview.pushVideoEffect(resourcePath: path, timeRange: duration, region: self.preview.normalizedSelectedRegion)
            
            
        default:
            self.setupPreview(self.video_editer.composition!)                
            return
        }
        
        


    }

    func extraSetups()
    {
        self.seekBar.rightDown = { _ in
            if self.fromValueField.doubleValue == 0 {
                self.fromValueField.doubleValue = self.timeAtCursor
            } else {
                self.toValueField.doubleValue = self.timeAtCursor
            }
        }
        
        self.controllerC.notifyA = { (sender : NSButton?) in
            self.insertButton(sender)
            self.setupPreview(self.video_editer.composition!)
        }
        
        self.controllerC.notifyB = { (audioOnly : Bool) in 
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    self.infoText.stringValue = "書き出し中..."
                }
            }
            self.exportVideoWithConstrain(audioOnly: audioOnly)
        }
        
        // プレビューの effect node が削除するよう操作された時
        self.preview.removeTrackRequirement = { (trackID : CMPersistentTrackID) in
            self.video_editer.removeTrackWithId(trackID)
        }
        
        self.video_editer.exportDelegate = { (session : AVAssetExportSession) in
            self.progress.doubleValue = 0.0
            self.progress.startAnimation(self)
            
            let queue = DispatchQueue.global()
            queue.async(execute: {
                while session.progress < 1.0 {
                    DispatchQueue.main.async {
                        self.infoText.stringValue = "書き出し中..."
                        self.progress.doubleValue = Double(session.progress) * 100.0
                    }
                }
                
                DispatchQueue.main.sync {
                    self.infoText.stringValue = "書き出し完了!"
                    let panel = NSAlert.init()
                    panel.messageText = "書き出し完了!"
                    panel.runModal()
                    self.progress.doubleValue = 0.0
                }
            })
        }
        
    }
    
    
    
    func exportVideoWithConstrain(audioOnly : Bool)
    {
        let start = CMTimeMakeWithSeconds(self.fromValueField.doubleValue, 600)
        let duration = CMTimeMakeWithSeconds(self.toValueField.doubleValue - self.fromValueField.doubleValue , 600)
        let range = CMTimeRangeMake(start, duration)
        
        if let region = self.preview.normalizedSelectedRegion
        {
            self.video_editer.exportWithConstrains(cropRectangle: region, timeRange: range)
        } else {
            let region = CGRect.init(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
            self.video_editer.exportWithConstrains(cropRectangle: region, timeRange: range, audioOnly: audioOnly)
        }
        
    }

}





