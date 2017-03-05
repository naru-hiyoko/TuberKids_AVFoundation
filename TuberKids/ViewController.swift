//
//  ViewController.swift
//  TuberKids
//
//  Created by 成沢淳史 on 10/13/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Cocoa
import AVFoundation
import AudioToolbox
import Darwin




class ViewController: NSViewController
{
    let video_editer : VideoEditController = VideoEditController()

    @IBOutlet weak var preview : AVPrevView!

    @IBOutlet weak var playButton : NSButton!    
    @IBOutlet weak var seekBar : SeekBar!
    @IBOutlet weak var rangeIndicaterView : RangeIndicatorView!
    
    
//    internal var timeAtCursor : Double = 0.0
    
    
   // 音声 or 動画 差し込み時に使う
    @IBOutlet weak var volumeValueLabel : NSTextField!
    
    @IBOutlet weak var infoText : NSTextField!

    var toolsViewController : ToolsViewController!
    
    @IBOutlet var progress : NSProgressIndicator!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.toolsViewController = self.storyboard?.instantiateController(withIdentifier: "toolsController") as! ToolsViewController
        

        self.view.acceptsTouchEvents = true
        self.view.wantsLayer = true
        
        self.extraSetups()
        
        let url = URL.init(fileURLWithPath: "/Volumes/MacintoshHD3/Video/hello.mov")
        self.video_editer.preview = self.preview        
        self.video_editer.loadSourceVideoFromURL(url)
        self.setupPreview(self.video_editer.composition!)

        return
    }
 
    func test(_ sender: NSPopUpButton)
    {
        print("call")

    }
    
    func setupPreview(_ asset : AVAsset?)
    {
        
        self.seekBar.setLimit(lower: 0.0, upper: self.video_editer.composition!.duration.seconds)
        self.rangeIndicaterView.setLimit(lower: 0.0, upper: CGFloat(self.video_editer.composition!.duration.seconds))
        

        let queue = DispatchQueue.main
        self.preview.avPlayer!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.01, 600),
                                                       queue: queue, using: previewTimeObservingFunction)
        

    }
    
    private func previewTimeObservingFunction(_ time: CMTime)
    {
        print(time.seconds)
        self.seekBar.setLimit(range: self.rangeIndicaterView.range)
        
        if self.rangeIndicaterView.range.containsTime(time)
        {
            self.seekBar.doubleValue = time.seconds
            self.preview.update(seconds: time.seconds)
            let str = formatTime(Time: CGFloat(time.seconds))
            self.infoText.stringValue = "At. \(str)"
        } else {
            self.preview.stop()
        }
        

    }
    
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        guard let indicater = self.rangeIndicaterView else {
            return
        }
        indicater.mouseUp(with: theEvent)
    }
    
    override func mouseDown(with theEvent: NSEvent) {

        self.rangeIndicaterView.mouseDown(with: theEvent)

    }
    
    
    override func mouseDragged(with theEvent: NSEvent) {
        guard let indicater = self.rangeIndicaterView else {
            return
        }
        indicater.mouseDragged(with: theEvent)
    }
    
    override func keyDown(with theEvent: NSEvent) {
        
        if theEvent.keyCode == 0x33 && preview.selectedEffectIndex != nil {
//            self.preview.removeEffect(index: self.preview.selectedEffectIndex)
            return
        }
        
        
        if theEvent.keyCode == 0x33 {
            self.video_editer.removeResourceAtSelectedRow()
            return
        }
        
        
    }
    
    /**
    response to button clicked.
     
    */
    
    @IBOutlet weak var presetNameButton : NSPopUpButton?
    
    private func setExportPresetName()
    {      
        guard let index = self.presetNameButton?.indexOfSelectedItem else { return }
        switch index {
        case 0:
            VideoDescription.exportPresetName = AVAssetExportPreset640x480
        case 1:
            VideoDescription.exportPresetName = AVAssetExportPreset1280x720
        case 2:
            VideoDescription.exportPresetName = AVAssetExportPreset1920x1080
        default:
            break
        }
        
    }
    
    @IBAction func onButton(_ sender : NSButton?) {
        
        if VideoDescription.sourceURL == nil { return }
        
        if sender?.identifier == "play_button" 
        {
            self.preview.play()
        }
        
       
        if sender?.identifier == "save_button"
        {
//            self.video_editer.insertImageEffectsWithSet(effectData: self.preview.effects)
            self.video_editer.export(EffectData.effects)
        }
        
        
    }
    
    @IBAction func saveButtonDown(_ sender: NSButton?)
    {
        self.setExportPresetName()
//        self.video_editer.insertImageEffectsWithSet(effectData: self.preview.effects)
    }
    
    @IBAction func cancelExport(_ sender: NSButton?)
    {
        self.video_editer.cancelExport()
        let panel = NSAlert.init()
        panel.messageText = "中止しました"
        panel.runModal()
        
    }
    

    @IBAction func onRangeButton(_ sender : NSButton?)
    {

        if VideoDescription.sourceURL == nil { return }


        if sender?.identifier == "set"
        {
            let _from = CurrentOperation.effectIn!.seconds
            let _to = CurrentOperation.effectOut!.seconds

            self.seekBar.minValue = _from
            self.seekBar.maxValue = _to
            self.seekBar.doubleValue = _from
            
            
            let tolerance = CMTimeMakeWithSeconds(0.0001, 600)
            self.preview.avPlayer?.seek(to: CMTimeMakeWithSeconds(_from, 600), toleranceBefore: tolerance, toleranceAfter: tolerance)
        }
        
        if sender?.identifier == "reset"
        {
            self.setupPreview(self.video_editer.composition!)
            
        }

        

    }
    
    @IBAction func audioVolumeChanged(_ sender: NSSlider?)
    {
        CurrentOperation.audioVolume = sender!.doubleValue
    }
    
   
    @IBAction func seekBarClicked(_ sender : AnyObject?)
    {
        guard let player = self.preview.avPlayer else { return }
        player.seek(to: CMTimeMakeWithSeconds(self.seekBar.doubleValue, 600),
                          toleranceBefore: CMTimeMakeWithSeconds(0.0001, 600), toleranceAfter: CMTimeMakeWithSeconds(0.0001, 600))
    }
    
    

    @IBAction func openControllerC(_ sender : NSButton?)
    {
        let edge = NSRectEdge(rawValue: 0)
        
        if self.toolsViewController.presented {
            self.dismissViewController(self.toolsViewController)
        } else {
            self.presentViewController(self.toolsViewController, asPopoverRelativeTo: NSRect.init(),
                                       of: self.preview, preferredEdge: edge!, behavior: NSPopoverBehavior.transient)
        }

        
    }

    
}   






