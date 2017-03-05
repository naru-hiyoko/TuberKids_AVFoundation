//
//  MenuOperations.swift
//  TuberKids
//
//  Created by 成沢淳史 on 2017/03/03.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController
{
    @IBAction func openFontPanel(_ sender : AnyObject?)
    {
        let font = NSFont.init(name: "HiraKakuProN-W3", size: 16)!
        let manager = NSFontManager.shared()
        let panel : NSFontPanel = manager.fontPanel(true)!
        manager.orderFrontFontPanel(panel)
        manager.setSelectedFont(font, isMultiple: false)
    }
    
    
    
    
    /**
     setup new project. 
     */
    
    @IBAction func newProject (_ sender : AnyObject?)
    {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ["mp4", "mov", "MOV"]
        let ret = panel.runModal()
        if ret == NSModalResponseCancel
        {
            return
        } else {
            let url = panel.url!
            self.video_editer.loadSourceVideoFromURL(url)
            self.preview.removeAllEffect()
            self.setupPreview(self.video_editer.composition!)
        }
        
        
    }

    
    
}
