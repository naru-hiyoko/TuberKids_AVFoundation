//
//  NSSliderEX.swift
//  TuberKids
//
//  Created by 成沢淳史 on 11/8/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

class SeekBar : NSSlider
{
    var delegate : ViewController?
    
    fileprivate var asset : AVAsset?
    fileprivate var generator : AVAssetImageGenerator?
    var thumbnail : CALayer?
    var textLayer : CATextLayer?
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let f = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let area = NSTrackingArea(rect: f, options: [.mouseMoved, .activeAlways, .inVisibleRect, .mouseEnteredAndExited], owner: self, userInfo: [:])
        self.addTrackingArea(area)
        self.isContinuous = true
        self.wantsLayer = true
        
        self.textLayer = CATextLayer()
        self.textLayer?.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
        self.textLayer?.backgroundColor = CGColor.init(gray: 0.7, alpha: 0.5)
        self.textLayer?.foregroundColor = NSColor.black.cgColor
        self.textLayer?.fontSize = 16
        self.textLayer?.alignmentMode = "center"
        
        self.thumbnail = CALayer.init()

    }
    
    var leftDown : ((_ time : CMTime) -> Void) = { _ in
        
    }
    var rightDown : (() -> Void) = { _ in
        
    }
   
    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)

        let x = (theEvent.locationInWindow.x - self.frame.minX) / self.frame.width
        let time = CMTimeMakeWithSeconds(self.maxValue * Double(x), 600)
        self.leftDown(time)

    }
    
    
    override func mouseExited(with theEvent: NSEvent) {
        self.thumbnail?.isHidden = true
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        self.thumbnail?.isHidden = false
    }
    
    override func rightMouseDown(with theEvent: NSEvent) {
//        let x = (theEvent.locationInWindow.x - self.frame.minX) / self.frame.width
//        let time = CMTimeMakeWithSeconds(self.maxValue * Double(x), 600)
        self.rightDown()
    }
    


        
    override func mouseMoved(with theEvent: NSEvent) {

        guard let _generator = self.generator else { return }
        let x = (theEvent.locationInWindow.x - self.frame.minX) / self.frame.width
        let t = (self.delegate!.rangeIndicaterView.maxValueAorB - self.delegate!.rangeIndicaterView.minValueAorB) * CGFloat(x) + self.delegate!.rangeIndicaterView.minValueAorB
        let time = CMTimeMakeWithSeconds(Double(t), 600)
        do {
//            let image = try _generator.copyCGImage(at: time, actualTime: nil)
            self.thumbnail?.frame = CGRect(x: theEvent.locationInWindow.x, y: theEvent.locationInWindow.y, width: 120, height: 80)
//            self.thumbnail?.contents = image
        } catch let e {
            Swift.print(e)
        }
        
        let text = String(NSString.init(format: "%0.2f(s)", time.seconds))
        self.textLayer?.string = text
        self.thumbnail?.addSublayer(self.textLayer!)
        self.thumbnail?.isHidden = false
        self.delegate?.view.layer!.insertSublayer(self.thumbnail!, above: self.delegate!.itemView.layer)
    }
    
    func load(_ asset : AVAsset)
    {
        self.generator = AVAssetImageGenerator(asset: asset)
    }
    
    
    
}
