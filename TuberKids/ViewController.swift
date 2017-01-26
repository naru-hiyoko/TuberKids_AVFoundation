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
    
    @IBOutlet weak var dropFieldView : DropFieldView!
    @IBOutlet weak var preview : AVPrevView!
    @IBOutlet weak var itemView : ItemTableView!
    @IBOutlet weak var itemViewScroll : NSScrollView!    
    @IBOutlet weak var playButton : NSButton!    
    @IBOutlet weak var seekBar : SeekBar!
    @IBOutlet weak var rangeIndicaterView : RangeIndicatorView!
    
    @IBOutlet weak var mute_button : NSButton!
    @IBOutlet weak var restrict_button : NSButton!    

    // レンジバーが表示するタイムレンジ
    @IBOutlet weak var fromValueField : NSTextField!
    @IBOutlet weak var toValueField : NSTextField!
    
    var timeAtCursor : Double = 0.0
    
    
   // 音声 or 動画 差し込み時に使う
    @IBOutlet weak var volumeValueLabel : NSTextField!
    
    @IBOutlet weak var animationTypePopUp : NSPopUpButton!
    
    @IBOutlet weak var infoText : NSTextField!
    
    var controllerB : ViewControllerB!
    var controllerC : ViewControllerC!
    
    @IBOutlet var progress : NSProgressIndicator!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.controllerB = self.storyboard?.instantiateController(withIdentifier: "controllerB") as! ViewControllerB
        self.controllerC = self.storyboard?.instantiateController(withIdentifier: "controllerC") as! ViewControllerC
        

        self.view.acceptsTouchEvents = true
        self.view.wantsLayer = true
        
        
        self.dropFieldView.delegate = self
        self.rangeIndicaterView.delegate = self
        self.seekBar.delegate = self
        self.view.layer?.addSublayer(self.seekBar.thumbnail!)
        self.preview.delegate = self
        self.extraSetups()
    
        return
    }
 

    
    
    func setupPreview(_ asset : AVAsset?)
    {
        
        guard let _asset = asset else { return }
        
        let item = AVPlayerItem(asset: _asset)
        self.preview.avPlayer = AVPlayer(playerItem: item)
        self.preview.videoLayer = AVPlayerLayer(player: self.preview.avPlayer)
        self.preview.videoLayer?.frame = CGRect(x: 0, y: 0, width: self.preview.frame.width, height: self.preview.frame.height)
        if let subLayers = self.preview.layer!.sublayers {
            for layer in subLayers
            {
                layer.removeFromSuperlayer()
            }
        }
        
        
        self.preview.layer?.addSublayer(self.preview.videoLayer!)
        self.seekBar.minValue = 0.0
        self.seekBar.maxValue = self.video_editer.composition!.duration.seconds
        self.seekBar.doubleValue = 0.0
        
        self.rangeIndicaterView.minValue = CGFloat(0.0)
        self.rangeIndicaterView.maxValue = CGFloat(self.seekBar.maxValue)
        self.rangeIndicaterView.setInitState()
        
        
        let queue = DispatchQueue.main
        self.preview.avPlayer!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.01, 600), queue: queue, using: { (time : CMTime) in 
            if (self.video_editer.composition?.duration.seconds)! - 0.05 < time.seconds
            {
                self.preview.pause()
            }
            
            if self.seekBar.maxValue <= time.seconds
            {
                self.preview.pause()
            }
            
            self.seekBar.doubleValue = time.seconds
            self.timeAtCursor = time.seconds
            let str = self.formatTime(Time: CGFloat(time.seconds))
            self.infoText.stringValue = "At. \(str)"
            self.preview.updateVisibleState(seconds: time.seconds)   
        })
        
        self.seekBar.load(self.video_editer.composition!)

    }
    
    fileprivate func formatTime(Time sec : CGFloat) -> String
    {
        //        let ms : Int = Int(sec - CGFloat(sec))
        let ss : Int = Int(sec) % 60
        let m : Int = Int(sec) / 60
        //        let mm : Int = m % 60
        //        let h : Int = m / 60
        return String(format: "%d:%02d", m, ss)
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

        if self.itemView.selectedRow != -1 {
            self.itemView.deselectRow(self.itemView.selectedRow)
        }
        
        guard let indicater = self.rangeIndicaterView else {
            return
        }
        indicater.mouseDown(with: theEvent)
    }
    
    
    override func mouseDragged(with theEvent: NSEvent) {
        guard let indicater = self.rangeIndicaterView else {
            return
        }
        indicater.mouseDragged(with: theEvent)
    }
    
    override func keyDown(with theEvent: NSEvent) {
        
        if theEvent.keyCode == 0x33 && preview.selectedEffectIndex != nil {
            self.preview.removeEffect(index: self.preview.selectedEffectIndex)
            return
        }
        
        
        if theEvent.keyCode == 0x33 {
            if self.itemView.selectedRow != -1 
            {
                self.video_editer.resources.remove(at: self.itemView.selectedRow)
                self.itemView.removeItemInRow(self.itemView.selectedRow)
            }
            
            return
        }
        
        
    }
    
    /**
    response to button clicked.
     
    */
    
    @IBOutlet weak var presetNameButton : NSPopUpButton?
    
    @IBAction func onButton(_ sender : NSButton?) {
        
        if self.video_editer.sourceURL == nil { return }
        
        if sender?.identifier == "play_button" 
        {
            self.preview.toggleSwitch()
        }
        
       
        if sender?.identifier == "save_button"
        {
            guard let index = self.presetNameButton?.indexOfSelectedItem else { return }
            switch index {
            case 0:
                self.video_editer.presetName = AVAssetExportPreset640x480
            case 1:
                self.video_editer.presetName = AVAssetExportPreset1280x720
            case 2:
                self.video_editer.presetName = AVAssetExportPreset1920x1080
            default:
                break
            }
            self.video_editer.insertImageEffectsWithSet(effectData: self.preview.effects)
        }
        
        if sender?.identifier == "cancel_button"
        {
//            return
            guard let s = self.video_editer.session else { return }
            s.cancelExport()
            let panel = NSAlert.init()
            panel.messageText = "中止しました"
            panel.runModal()
        }
        
    }
    
    var funkSound : AVAudioPlayer!
    
    @IBAction func onRangeButton(_ sender : NSButton?)
    {

        if self.video_editer.sourceURL == nil { return }
        
        if self.fromValueField.floatValue > self.toValueField.floatValue {
            let path = Bundle.main.path(forResource: "Funk", ofType: "aiff")
            let url = NSURL(string: path!)
            self.funkSound = try! AVAudioPlayer(contentsOf: url!.absoluteURL!)
            self.funkSound.play()
            return
        }


        if sender?.identifier == "set"
        {
            let _from = self.fromValueField.doubleValue
            let _to = self.toValueField.doubleValue

            self.seekBar.minValue = _from
            self.seekBar.maxValue = _to
            self.seekBar.doubleValue = _from
            
            self.rangeIndicaterView.setValueOfA(CGFloat(_from))
            self.rangeIndicaterView.setValueOfB(CGFloat(_to))
            self.rangeIndicaterView.fillRegionBetweenAandB()
            
            let tolerance = CMTimeMakeWithSeconds(0.0001, 600)
            self.preview.avPlayer?.seek(to: CMTimeMakeWithSeconds(_from, 600), toleranceBefore: tolerance, toleranceAfter: tolerance)
        }
        
        if sender?.identifier == "reset"
        {
            self.setupPreview(self.video_editer.composition!)
            
        }

        
        self.rangeIndicaterView.fillRegionBetweenAandB()
        
    }
    
   
    @IBAction func seekBarClicked(_ sender : AnyObject?)
    {
        guard let player = self.preview.avPlayer else { return }
        player.seek(to: CMTimeMakeWithSeconds(self.seekBar.doubleValue, 600),
                          toleranceBefore: CMTimeMakeWithSeconds(0.0001, 600), toleranceAfter: CMTimeMakeWithSeconds(0.0001, 600))
    }
    

    
    
    @IBOutlet weak var item : NSMenuItem!
    
    @IBAction func openFontPanel(_ sender : AnyObject?)
    {
        if self.video_editer.sourceURL == nil { return }
        let font = NSFont.init(name: "HiraKakuProN-W3", size: 16)!
        let manager = NSFontManager.shared()
        let panel : NSFontPanel = manager.fontPanel(true)!
        manager.orderFrontFontPanel(panel)
        manager.setSelectedFont(font, isMultiple: false)
    }
    

    
    
    
    
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
            self.video_editer.deleteData()
            if !self.video_editer.load(url) {
                return
            }
            self.setupPreview(self.video_editer.composition!)
        }
        
        
    }
    
    
    @IBAction func openControllerB(_ sender : NSButton?)
    {
        let edge = NSRectEdge(rawValue: 0)

        if self.controllerB.presented {
            self.dismissViewController(self.controllerB)
        } else {
            self.presentViewController(self.controllerB, asPopoverRelativeTo: NSRect.init(),
                                       of: self.preview, preferredEdge: edge!, behavior: NSPopoverBehavior.transient)
        }

    }
    
    @IBAction func openControllerC(_ sender : NSButton?)
    {
        let edge = NSRectEdge(rawValue: 0)
        
        if self.controllerC.presented {
            self.dismissViewController(self.controllerC)
        } else {
            self.controllerC.rangeIndicaterView = self.rangeIndicaterView
            self.controllerC.video_editer = self.video_editer
            self.presentViewController(self.controllerC, asPopoverRelativeTo: NSRect.init(),
                                       of: self.preview, preferredEdge: edge!, behavior: NSPopoverBehavior.transient)
        }

        
    }

    
}   






