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

class ViewControllerC : NSViewController
{

    var presented : Bool = false
    var rangeIndicaterView : RangeIndicatorView!
    var video_editer : VideoEditController!

    
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
    
    var notifyA : ((_ sender : NSButton?) -> Void) = { (sender : NSButton?) in
    
    }
    var notifyB : ((_ audioOnly : Bool) -> Void) = { (audioOnly : Bool) in
    
    }
    
    @IBAction func insertButton(_ sender : NSButton?)
    {
        self.notifyA(sender)
    }
    
    @IBAction func exportWithSelectRegion(_ sender : AnyObject?)
    {
        if self.audioOnly.state == NSOnState {
            self.notifyB(true)
        } else {
            self.notifyB(false)
        }
    }
    
}
