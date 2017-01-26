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

protocol AVPrevViewProtocol {

    var avPlayer : AVPlayer? { get set }
    var videoLayer : AVPlayerLayer? { get set }
    var isPlaying : Bool { get set }
    var normalizedSelectedRegion : CGRect? { get }
    
    var effects : [EffectData] { get }
}

class AVPrevView : NSImageView, AVPrevViewProtocol
{
    var delegate : ViewController?
    
    var avPlayer : AVPlayer? = nil
    var videoLayer : AVPlayerLayer? = nil
    var isPlaying : Bool = false
    
    fileprivate var selectedRigion: CALayer? = CALayer()
    fileprivate var mouseDownPosition : CGPoint?
    fileprivate var mouseUpPosition : CGPoint?
    
    var effects : [EffectData] = []
    fileprivate var effectParentLayer : CALayer = CALayer()
    
    // selected index in effects.
    var selectedEffectIndex : Int? = nil
    
    // 
    var selectedRegionAspect : CGFloat?
    {
        guard let width = self.normalizedSelectedRegion?.width else {
            return nil
        }
        
        guard let height = self.normalizedSelectedRegion?.height else {
            return nil
        }
        
        return height / width
    }

    var notify : ((_ row : Int) -> Void) = { (row : Int) in
        // NSTableView の selected item の row 受け取ること
        Swift.print(row)
    }
    
    /**
    return of this regions are normalized by frame size itself.
 
    */
    var normalizedSelectedRegion : CGRect? {
        guard let downPos = self.mouseDownPosition else {
            return nil
        } 
        
        guard let upPos = self.mouseUpPosition else {
            return nil
        }
        
        let x = min(downPos.x, upPos.x) / self.frame.width
        let y = min(downPos.y, upPos.y) / self.frame.height
        let width = abs(downPos.x - upPos.x) / self.frame.width
        let height = abs(downPos.y - upPos.y) / self.frame.height
        
        return CGRect(x: x, y: y, width: width, height: height)
        
    }
    
    fileprivate func normalizedPoint (point p : CGPoint) -> CGPoint
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
        self.layer?.addSublayer(self.effectParentLayer)
        
        self.selectedRigion?.backgroundColor = NSColor.init(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.8).cgColor
        self.layer?.addSublayer(self.selectedRigion!)
        
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
//            self.notify(Int(str)!)
            self.delegate?.itemDropped(row: Int(str)!)
        }
        

        return true
    }
    
    /**
     calcutate the local position in self frame. 
     */
    fileprivate func locationInFrame(locationInWindow pos : NSPoint, inRect rect : NSRect) -> CGPoint
    {
        let dx = pos.x - rect.minX
        let dy = pos.y - rect.minY
        return CGPoint(x: dx, y: dy)
    }
    
    fileprivate func layerInPosition(locationInView pos : CGPoint) -> Int?
    {
        self.selectedEffectIndex = nil
        for (i, datum) in self.effects.enumerated()
        {
            if datum.layer.frame.contains(pos) && datum.layer.isHidden == false 
            {
                datum.layer.borderColor = NSColor.cyan.cgColor
                datum.layer.borderWidth = 2.5
                self.selectedEffectIndex = i
            } else {
                datum.layer.borderColor = NSColor.clear.cgColor
            }
        }
        return self.selectedEffectIndex
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)
        self.mouseDownPosition = self.locationInFrame(locationInWindow: theEvent.locationInWindow, inRect: self.frame)
        self.selectedRigion?.isHidden = true
        self.mouseUpPosition = nil 
        
        self.layerInPosition(locationInView: self.mouseDownPosition!)
        
   }
    
    
    override func mouseUp(with theEvent: NSEvent) {
        //
        let pos = self.locationInFrame(locationInWindow: theEvent.locationInWindow, inRect: self.frame)
        if self.selectedRigion!.contains(pos) {
            self.mouseUpPosition = pos
        } else {
            self.selectedRigion?.isHidden = true
        }
        
        
    }
    
    
    private func euc(p1 : CGPoint, p2 : CGPoint) -> CGFloat
    {
        let e = sqrt(pow(p1.x - p2.x, 2.0) + pow(p1.y - p2.y, 2.0))
//        Swift.print(e)
        return e
        
    }
    
    
    override func mouseDragged(with theEvent: NSEvent) {
        
        /**
         updated on Nov.12
        */
        if self.selectedEffectIndex != nil 
        {

            let effect = self.effects[self.selectedEffectIndex!]
            let p = self.locationInFrame(locationInWindow: theEvent.locationInWindow, inRect: self.frame)
            let np = self.normalizedPoint(point: p)
            
            if euc(p1: np, p2: CGPoint(x: effect.normalizedFrame!.minX, y: effect.normalizedFrame!.minY)) < 0.05
            {
                effect.normalizedFrame = CGRect(x: np.x, y: np.y, width: effect.normalizedFrame!.maxX - np.x, height: effect.normalizedFrame!.maxY - np.y)
                effect.layer.frame = CGRect(x: effect.normalizedFrame!.minX * self.frame.width, 
                                          y: effect.normalizedFrame!.minY * self.frame.height,
                                          width: effect.normalizedFrame!.width * self.frame.width, 
                                          height: effect.normalizedFrame!.height * self.frame.height)
                return
            }
            
            effect.layer.position = p
            effect.normalizedFrame = CGRect(x: np.x - effect.normalizedFrame!.width / 2.0,
                                                y: np.y - effect.normalizedFrame!.height / 2.0, width: effect.normalizedFrame!.width, height: effect.normalizedFrame!.height)
            return
        }
        
        
        self.selectedRigion?.isHidden = false
        let point = self.locationInFrame(locationInWindow: theEvent.locationInWindow, inRect: self.frame)
        
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
    
    /**
     region must be normalized to 0 ... 1.
     */
    func pushEffect(resourcePath path : URL, duration : CMTimeRange, region : CGRect? = nil,
                                 options : Dictionary<String, AnyObject>?)
    {
        
        
        let layer = CALayer()
        layer.contents = NSImage(contentsOf: path)
        layer.frame = self.getSuitFrameSize(region)
       
        let datum : EffectData = EffectData(layer: layer, normalizedFrame: region, timeRange: duration, url: path,
                                            type: AVMediaTypeImage, trackId: nil, options: options)

        self.effects.append(datum)
        self.effectParentLayer.addSublayer(layer)
        
        self.layer?.insertSublayer(self.effectParentLayer, above: self.videoLayer)
        self.layer?.insertSublayer(self.selectedRigion!, above: self.effectParentLayer)
        
    }
    
    func pushTextEffect(text : String, resourcePath path : URL, duration : CMTimeRange, region : CGRect? = nil,
                             options: Dictionary<String, AnyObject>? = nil)
    {
        let layer = CALayer()

        var isVertical = false
        if options != nil {
            isVertical = options!["isVertical"] as! Bool
        }
        
        let font : NSFont? = options!["font"] as? NSFont
        
        if isVertical {
            let image = textImageVertical(text: text, font: font, texture: path)
            layer.contents = image!        
        } else {
            let image = textImage(text: text, font: font, texture: path)
            layer.contents = image!        
        }
        
        layer.frame = self.getSuitFrameSize(region)
        
        let datum : EffectData = EffectData(layer: layer, normalizedFrame: region, timeRange: duration,
                                            url: path, type: AVMediaTypeText, trackId: nil, options: options)
        self.effects.append(datum)
        self.effectParentLayer.addSublayer(layer)
        
        self.layer?.insertSublayer(self.effectParentLayer, above: self.videoLayer)
        self.layer?.insertSublayer(self.selectedRigion!, above: self.effectParentLayer)
        self.selectedRigion?.isHidden = true        
    }
    
    func pushAudioEffect(resourcePath path : URL, duration : CMTimeRange, region : CGRect? = nil, trackId : CMPersistentTrackID)
    {
        let layer = CALayer()
        let image = NSImage(named: "sound")
        layer.contents = image!
        layer.frame = self.getSuitFrameSize(region)
        
        let datum : EffectData = EffectData(layer: layer, normalizedFrame: region, timeRange: duration,
                                            url: path, type: AVMediaTypeAudio, trackId: trackId, options: nil)
        self.effects.append(datum)
        self.effectParentLayer.addSublayer(layer)
        
        self.layer?.insertSublayer(self.effectParentLayer, above: self.videoLayer)
        //self.layer?.insertSublayer(self.selectedRigion!, above: self.effectParentLayer)
        self.selectedRigion?.isHidden = true
        
    }
    
    func pushVideoEffect(resourcePath path : URL, timeRange : CMTimeRange, region : CGRect? = nil)
    {
        
        let player = AVPlayer(url: path)
        let layer = AVPlayerLayer(player: player)
        layer.frame = self.getSuitFrameSize(region)
        
        let options : Dictionary<String, AnyObject> = [
            "player" : player, 
        ]
        
        let datum = EffectData(layer: layer, normalizedFrame: region, timeRange: timeRange, url: path, type: AVMediaTypeVideo, trackId: nil, options: options)
        self.effects.append(datum)
        self.effectParentLayer.addSublayer(layer)
        self.layer?.insertSublayer(self.effectParentLayer, above: self.videoLayer)        
        self.selectedRigion?.isHidden = true        
        
    }
    
    fileprivate func getSuitFrameSize (_ region : CGRect?) -> CGRect
    {
        if region != nil {
            return CGRect(x: region!.minX * self.frame.width, y: region!.minY * self.frame.height, 
                            width: region!.width * self.frame.width, height: region!.height * self.frame.height)
        } else {
            return CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        }
    }
    
    
    
    var removeTrackRequirement = { (trackId : CMPersistentTrackID) in
        Swift.print(" the composition track is not removed !. override this function and remove tracks in ViewController. ")
    }
    
    func removeEffect(index : Int?)
    {
        if index == nil || self.effects.count <= index {
            return
        }
        
        
        if self.effects[index!].type == AVMediaTypeAudio
        {
            // Audio Effect Node の場合には View Controller から AVComposition にアクセスし Track を消去させる. 
            let trackId = self.effects[index!].trackId!
            self.removeTrackRequirement(trackId)
        }
        
        let layer = self.effects[index!].layer
        layer.removeFromSuperlayer()
        self.effects.remove(at: index!)
    }
    
    func updateVisibleState(seconds time : Double)
    {
        for datum in self.effects {
            let timeRange = datum.timeRange
            let layer = datum.layer
            layer.frame = self.getSuitFrameSize(datum.normalizedFrame!)
            
            if timeRange.start.seconds <= time && timeRange.end.seconds >= time {
                
                guard let options = datum.options else {
                    layer.isHidden = false
                    return
                }
                
                if datum.type == AVMediaTypeAudio
                {
                    layer.isHidden = false
                }
                

                if datum.type == AVMediaTypeImage || datum.type == AVMediaTypeText 
                {

                    switch options["key"] as! Int {
                        case AnimationStyle.fade.rawValue :
                            if layer.animationKeys() != nil { continue }
                            let animation = self.getFadeAnimation(datum: datum)
                            CATransaction.begin()
                            CATransaction.setCompletionBlock({
                                layer.opacity = Float(animation.toValue as! Double)
                            })
                            layer.add(animation, forKey: "action")
                            CATransaction.commit()
                            layer.isHidden = false
                        
                        case AnimationStyle.scale.rawValue :
                            if layer.animationKeys() != nil { return }
                            let animation = self.getScaleAnimation(datum: datum)
                            layer.add(animation, forKey: "action")
                            CATransaction.begin()
                            CATransaction.setCompletionBlock({
                                let to = Float(animation.toValue as! Double)
                                let t = CGAffineTransform(a: CGFloat(to), b: 0, c: 0, d: CGFloat(to), tx: 0, ty: 0)
                                layer.setAffineTransform(t)
                            })
                            CATransaction.commit()
                            layer.isHidden = false
                        
                        case AnimationStyle.rotation.rawValue :
                            if layer.animationKeys() != nil { return }
                            let animation = self.getRotationAnimation(datum: datum)
                            layer.add(animation, forKey: "action")
                            CATransaction.setCompletionBlock({
                            let to = Float(animation.toValue as! Double)
                            let t1 = CGAffineTransform.identity
                            let t2 = t1.rotated(by: CGFloat(to))
                            layer.setAffineTransform(t2)
                            })
                            CATransaction.commit()
                            layer.isHidden = false
                        
                        case AnimationStyle.spring.rawValue :
                            let animation = self.getSpringAnimation(datum: datum)
                            layer.add(animation, forKey: "action")
                            CATransaction.commit()
                            layer.isHidden = false
                        
                        
                        default:
                            layer.isHidden = false                        
                    }
                }
                
                if datum.type == AVMediaTypeVideo {
                    let player = datum.options!["player"] as! AVPlayer
                    player.play()
                    layer.isHidden = false
                }

                
            } else {
                // 表示時間外に入ったレイヤー
                layer.removeAllAnimations()
                if datum.type == AVMediaTypeVideo {
                    let player = datum.options!["player"] as! AVPlayer
                    player.seek(to: kCMTimeZero)
                    player.pause()
                }
                layer.isHidden = true
            }
        }
        
        if self.isPlaying {
            self.layer?.insertSublayer(self.selectedRigion!, below: self.videoLayer)
            self.layer?.insertSublayer(self.effectParentLayer, above: self.videoLayer)
        } else {
            self.layer?.insertSublayer(self.effectParentLayer, above: self.videoLayer)
            self.layer?.insertSublayer(self.selectedRigion!, above: self.effectParentLayer)
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
        DispatchQueue.main.async {
            self.delegate?.playButton.title = "停止"
        }
    }
    
    func stop()
    {
        self.isPlaying = false
        self.avPlayer?.seek(to: CMTimeMakeWithSeconds(self.delegate!.seekBar.minValue, 600))
        self.avPlayer?.pause()
        
        self.delegate?.seekBar.doubleValue = Double(self.delegate!.rangeIndicaterView.minValueAorB)
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.delegate?.playButton.title = "再生"
            }
        }

    }
    
    func pause()
    {
        self.isPlaying = false
        self.avPlayer?.pause()

        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.delegate?.playButton.title = "再生"                
            }
        }
        
        for datum in effects
        {
            if datum.type == AVMediaTypeVideo
            {
                let player : AVPlayer = datum.options!["player"] as! AVPlayer
                player.pause()
            }
        }
        

    }

}


