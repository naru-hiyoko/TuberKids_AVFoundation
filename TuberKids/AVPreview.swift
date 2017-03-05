//
//  ItemView.swift
//  TuberKids
//
//  Created by 成沢淳史 on 10/17/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


let AVMediaTypeImage = "image"

@available(*, renamed: "AVPreview")
typealias AVPrevView = AVPreview
class AVPreview : NSImageView
{
    weak var videoEditor: VideoEditController!
    
    weak var avPlayer : AVPlayer? = nil
    weak var videoLayer : AVPlayerLayer? = nil
    var isPlaying : Bool = false
    
    private var selectedRigion: CALayer? = CALayer()
    private var mouseDownPosition : CGPoint?
    private var mouseUpPosition : CGPoint?
    
//    var effects : [EffectData] = []
    var effectParentLayer : CALayer = CALayer()
    
    // selected index in effects.
    var selectedEffectIndex : Int? = nil
    
    // 
    var selectedRegionAspect : CGFloat?
    {
        guard let width = self.normalizedSelectedRegion?.width else { return nil }
        guard let height = self.normalizedSelectedRegion?.height else { return nil }
        
        return height / width
    }

  
    /**
    return of this regions are normalized by frame size itself.
 
    */
    var normalizedSelectedRegion : CGRect? {
        guard let downPos = self.mouseDownPosition else { return nil } 
        guard let upPos = self.mouseUpPosition else { return nil }
        
        let x = min(downPos.x, upPos.x) / self.frame.width
        let y = min(downPos.y, upPos.y) / self.frame.height
        let width = abs(downPos.x - upPos.x) / self.frame.width
        let height = abs(downPos.y - upPos.y) / self.frame.height
        
        return CGRect(x: x, y: y, width: width, height: height)
        
    }
    
    // 0 ... 1
    var selectedRect: CGRect?
    {
        guard let downPos = self.mouseDownPosition else { return nil } 
        guard let upPos = self.mouseUpPosition else { return nil }
        
        let x = min(downPos.x, upPos.x) / self.frame.width
        let y = min(downPos.y, upPos.y) / self.frame.height
        let width = abs(downPos.x - upPos.x) / self.frame.width
        let height = abs(downPos.y - upPos.y) / self.frame.height
        
        return CGRect(x: x, y: y, width: width, height: height)
        
    }
    
    func normalizedPoint (point p : CGPoint) -> CGPoint
    {
        return CGPoint(x: p.x / self.frame.width, y: p.y / self.frame.height)
    }
    
    private func convert(_ p: CGPoint) -> CGPoint
    {
        return CGPoint(x: p.x / self.frame.width, y: p.y / self.frame.height)        
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.acceptsTouchEvents = true
        self.register(forDraggedTypes: [NSStringPboardType])
        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor(gray: 0.5, alpha: 0.7)
        
        self.effectParentLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.layer!.addSublayer(self.effectParentLayer)
        
        self.selectedRigion?.backgroundColor = NSColor.init(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.8).cgColor
        self.layer!.addSublayer(self.selectedRigion!)
        
    }
    
    
    
    override func viewDidEndLiveResize() {
        self.videoLayer?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        if self.layer!.sublayers != nil {
            for layer in self.layer!.sublayers!
            {
                layer.removeFromSuperlayer()
            }
        }
        guard let videoLayer = self.videoLayer else {
            return
        }
        self.layer?.addSublayer(videoLayer)
        
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        for item in sender.draggingPasteboard().pasteboardItems!
        {
            if item.data(forType: "public.utf8-plain-text") == nil {
                return NSDragOperation()
            }
        }
        return NSDragOperation.copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        for item in sender.draggingPasteboard().pasteboardItems!
        {
            guard let data = item.data(forType: "public.utf8-plain-text") else { return false }
            
            let str : String! = String(data: data, encoding: String.Encoding.utf8)
            insertEffect(Int(str)!)
        }
        

        return true
    }
    
    func insertEffect(_ id: Int)
    {
        let resourceURL = TableItems.items[id]
        CurrentOperation.effectResource = resourceURL
        let region = self.selectedRect!
        let range = CurrentOperation.timeRange!

        
        let ext = resourceURL.pathExtension
        switch ext.lowercased() {
        case let a where a == "jpg" || a == "png":
            pushImageEffect(resourcePath: resourceURL, timeRange: range, region: region)
        case let a where a == "mp3" || a == "m4a":
            pushAudioEffect(resourcePath: resourceURL, timeRange: range, region: region, volume: CurrentOperation.audioVolume)
        case let a where a == "mov" || a == "mp4":            
            pushVideoEffect(resourcePath: resourceURL, timeRange: range, region: region, volume: CurrentOperation.audioVolume)
        default:
            Swift.print("unkown: \(ext)")
        }

    }
    
    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)

        self.mouseDownPosition = self.convert(theEvent.locationInWindow, from: self.superview!)
        self.selectedRigion?.isHidden = true
        self.mouseUpPosition = nil 
        

   }
    
    
    override func mouseUp(with theEvent: NSEvent) {

        let pos = self.convert(theEvent.locationInWindow, from: self.superview!)
        if self.selectedRigion!.contains(pos) {
            self.mouseUpPosition = pos
        } else {
            self.selectedRigion?.isHidden = true
        }
        
        
    }
    
    
   
    
    override func mouseDragged(with theEvent: NSEvent) {
        
        /**
         updated on Nov.12
        */
        
        
        self.selectedRigion?.isHidden = false
        let point = self.convert(theEvent.locationInWindow, from: self.superview!)
        
        self.selectedRigion?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.selectedRigion?.opacity = 0.6
        self.selectedRigion?.backgroundColor = NSColor.gray.cgColor
        let ctx = CGContext(data: nil, width: Int(self.frame.width), height: Int(self.frame.height),
                                        bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedLast.rawValue)

        
        ctx?.setStrokeColor(NSColor.cyan.cgColor)
        ctx?.setLineWidth(2.0)
        let old = self.mouseDownPosition!
        
        let p1 = CGPoint(x: point.x, y: point.y)
        let p2 = CGPoint(x: point.x, y: old.y)
        let p3 = CGPoint(x: old.x, y: old.y)        
        let p4 = CGPoint(x: old.x, y: point.y)


        
//        CGContextAddLines(ctx, [p1, p2, p3, p4, p1], 5)
        ctx!.addLines(between: [p1, p2, p3, p4, p1])
        ctx?.strokePath()

        
        let image = ctx?.makeImage()
        self.selectedRigion?.contents = image!
        
        self.selectedRigion?.isHidden = false
        
        self.layer?.insertSublayer(self.selectedRigion!, above: self.videoLayer)

        

    }
    
    
    override func convertToLayer(_ region: CGRect) -> CGRect
    {
        return CGRect(x: region.minX * self.frame.width, y: region.minY * self.frame.height, 
                      width: region.width * self.frame.width, height: region.height * self.frame.height)
        
    }
    
    
    
    var removeTrackRequirement = { (trackId : CMPersistentTrackID) in
        Swift.print(" the composition track is not removed !. override this function and remove tracks in ViewController. ")
    }
    
    
    @available(*, introduced: 2.00)
    func update(seconds t: Double)
    {
        self.selectedRigion?.isHidden = true
        
        for datum in EffectData.effects
        {
            if datum.timeRange.ContainsTime(t)
            {
                datum.show()
                self.videoLayer!.addSublayer(self.effectParentLayer)                
            } else {
                datum.hidden()
            }
        }
    }
    
    
    func removeAllEffect()
    {
        for i in 0..<EffectData.effects.count
        {
//            self.removeEffect(index: i)
        }
    }
    
    
    /**
     if video is not playing, play video. Or pause playing.  
    */
    func toggleSwitch()
    {
        if self.isPlaying {
            self.isPlaying = false
            self.pause()
        } else {
            self.isPlaying = true            
            self.play()            
        }
    }
    
    func play()
    {
        self.isPlaying = true
        self.avPlayer?.play()

    }
    
    func stop()
    {
        self.isPlaying = false
        self.avPlayer?.pause()

    }
    
    func pause()
    {
        self.isPlaying = false
        self.avPlayer?.pause()
        for datum in EffectData.effects
        {
            datum.pause()
        }
        

    }
    
    func setupPreview(composition: AVComposition)
    {
        let item = AVPlayerItem.init(asset: composition)
        self.avPlayer = AVPlayer.init(playerItem: item)
        self.videoLayer = AVPlayerLayer.init(player: self.avPlayer!)
        self.videoLayer!.frame = self.frame
        
        if let subLayers = self.layer!.sublayers {
            for layer in subLayers
            {
                layer.removeFromSuperlayer()
            }
        }

        self.layer!.addSublayer(self.videoLayer!)
    }
    

}


