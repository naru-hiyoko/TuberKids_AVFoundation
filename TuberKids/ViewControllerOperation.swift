//
//  ViewControllerEffect.swift
//  TuberKids
//
//  Created by 成沢淳史 on 2017/01/05.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

extension ViewController
{
    @IBAction func onSaveStateButton(_ sender : NSButton?)
    {
        guard let sourceURL = VideoDescription.sourceURL else { return }
        
        let sk = SaveCurrentEffect.init()
//        sk.saveState(sourceURL, effects: self.preview.effects)
    }
    
    @IBAction func onLoadStateButton(_ sender : NSButton?)
    {
        if VideoDescription.isNullSet{ return }
        
        let sk = SaveCurrentEffect.init()
        sk.loadState(preview: self.preview, editer: self.video_editer)
    }
    
    @IBAction func toolButtonDown(_ sender: NSButton?)
    {
        
    }
}
