//
//  ViewControllerC.swift
//  TuberKids
//
//  Created by 成沢淳史 on 11/9/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

class ToolsViewController: NSViewController
{

    public var presented : Bool = false
    
    var refreshRequire : ((_ sender : NSButton?) -> Void)!
    var exportRequire : ((_ audioOnly : Bool) -> Void)!
    
    @IBOutlet var scaleValueLabel : NSTextField!
    @IBOutlet var audioOnly : NSButton!
    

    override func viewDidLoad() {
        self.audioOnly.state = NSOffState
    }
    
    override func viewDidAppear() {
        super.viewDidLoad()
        self.presented = true
        
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.presented = false
        
    }
    

    
    @IBAction func insertButton(_ sender : NSButton?)
    {
        self.refreshRequire(sender)
    }
    
    @IBAction func exportWithSelectRegion(_ sender : AnyObject?)
    {
        if self.audioOnly.state == NSOnState {
            self.exportRequire(true)
        } else {
            self.exportRequire(false)
        }
    }
    
}

extension ViewController
{
 
    func exportVideoWithConstrain(audioOnly : Bool)
    {
        
        let range = CurrentOperation.timeRange!
        
        if let region = self.preview.normalizedSelectedRegion
        {
            self.video_editer.exportWithConstrains(cropRectangle: region, timeRange: range)
        } else {
            let region = CGRect.init(x: 0.0, y: 0.0, width: 0.99, height: 0.99)
            self.video_editer.exportWithConstrains(cropRectangle: region, timeRange: range, audioOnly: audioOnly)
        }
        
    }
    
    @available (*, deprecated: 2.00)
    @IBAction func insertButton(_ sender : NSButton?)
    {
        let alert = NSAlert()
        alert.messageText = "この操作は編集前に行ってください\n"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Reverb")
        if alert.runModal() == NSAlertSecondButtonReturn {
            return 
        }
        
        applyButtonDown(sender)
        
    }
    
    
    func applyButtonDown(_ sender: NSButton?)
    {
        let from = CurrentOperation.effectIn!.seconds + 0.000001
        let to = CurrentOperation.effectOut!.seconds
        
        let (_, range) = double2TimeRangeSet(from, to)
        
        switch sender!.identifier! {
        case "insertEmptyRange":
            self.video_editer.insertEmptyRange(range)
        case "cutRange":
            self.video_editer.removeTimeRange(range)
        case "scaleRange":
            let toSeconds = self.toolsViewController.scaleValueLabel.doubleValue 
            self.video_editer.scaleTimeRange(range, to: CMTimeMakeWithSeconds(toSeconds, 600))            
        default:
            print("ignore")
        }
        
        openCompleteDialog()
        
        
    }


    
    
}

