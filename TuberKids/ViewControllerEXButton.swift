//
//  ViewControllerA_EX.swift
//  TuberKids
//
//  Created by 成沢淳史 on 11/9/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

extension ViewController
{
  
    @IBAction func insertButton(_ sender : NSButton?)
    {
        let from = self.fromValueField.doubleValue + 0.000001
        let to = self.toValueField.doubleValue

        let start = CMTimeMakeWithSeconds(from, 600)
        let duration = CMTimeMakeWithSeconds(to - from, 600)
        let range = CMTimeRangeMake(start, duration)


        if duration.seconds <= 0 {
            let alert = NSAlert.init()
            alert.messageText = "無効な指定範囲です"
            return
        }
        
        
        var alert = NSAlert()
        alert.messageText = "この操作は編集前に行ってください\n"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Reverb")
        if alert.runModal() == NSAlertSecondButtonReturn {
            return
        }
        
        
        
        if sender?.identifier == "emptyRange"
        {
            self.video_editer.composition!.insertEmptyTimeRange(range)
            return
        }
        
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["mp4", "mov", "MOV"]
        
        if sender?.identifier == "insert_vid_top"
        {
            panel.runModal()
            guard let url = panel.url else {
                return
            }
            
            self.video_editer.insertVideo(resourcePath: url, atTime: start)
            
        }
        
        if sender?.identifier == "rangeIn" 
        {
            panel.runModal()
            guard let url = panel.url else {
                return
            }
            
            self.video_editer.insertVideo(resourcePath: url, duration: range)
            
        }
        
        if sender?.identifier == "cut_button" 
        {
            self.video_editer.composition!.removeTimeRange(range)
            self.setupPreview(self.video_editer.composition!)
        }
        
        if sender?.identifier == "scale_button"
        {
            
            let toSeconds = self.controllerC.scaleValueLabel.doubleValue 

            self.video_editer.composition!.scaleTimeRange(range, toDuration: CMTimeMakeWithSeconds(toSeconds, 600))
            self.setupPreview(self.video_editer.composition!)
            
        }
        

        alert = NSAlert.init()
        alert.alertStyle = NSAlertStyle.informational
        alert.messageText = "完了しました"
        alert.runModal()
        
    }
    
    
    
    
    
}    
