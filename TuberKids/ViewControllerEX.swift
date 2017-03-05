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


    
    func syncItems(_ items : [URL])
    {
        if self.video_editer.isResourcesEmpty
        {
            self.setupPreview(self.video_editer.composition!)
        } else {
            
        }
    }
    
    func extraSetups()
    {

        
        self.toolsViewController?.refreshRequire = { (sender : NSButton?) in
            self.insertButton(sender)
            self.setupPreview(self.video_editer.composition!)
        }
        
        self.toolsViewController?.exportRequire = { (audioOnly : Bool) in 
            self.exportVideoWithConstrain(audioOnly: audioOnly)
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
    
    
    

}





