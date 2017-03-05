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
    private var posA: Double = 0.0
    private var posB: Double = 0.0
    private let rangeLayer = CALayer()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let f = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let area = NSTrackingArea(rect: f, options: [.mouseMoved, .activeAlways, .inVisibleRect, .mouseEnteredAndExited], owner: self, userInfo: [:])
        self.addTrackingArea(area)
        self.isContinuous = true
        self.wantsLayer = true
        
        rangeLayer.frame = CGRect.init(x: 0, y: 0, width: 5, height: self.frame.height)
        rangeLayer.backgroundColor = CGColor.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.4)
        rangeLayer.isHidden = true
        self.layer!.addSublayer(rangeLayer)
        

    }
    
   
    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)

        let x = (theEvent.locationInWindow.x - self.frame.minX) / self.frame.width
        let time = CMTimeMakeWithSeconds(self.maxValue * Double(x), 600)

    }
    
    
    override func mouseExited(with theEvent: NSEvent) {
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
    }
    
    override func rightMouseDown(with theEvent: NSEvent) {
        Swift.print("set: \(self.doubleValue)")
        update(self.doubleValue)
    }
    
    private func updateValues(_ p: Double)
    {
        posA = posA.constraint(lower: self.minValue, upper: self.maxValue)
        posB = posB.constraint(lower: self.minValue, upper: self.maxValue)        
        
        if abs(posA - p) > abs(posB - p)
        {
            self.posB = p
        } else {
            self.posA = p
        }
        
        if posB.isLessThanOrEqualTo(posA)
        {
            CurrentOperation.effectIn = CMTimeMakeWithSeconds(posB, 600)
            CurrentOperation.effectOut = CMTimeMakeWithSeconds(posA, 600)
        } else {
            CurrentOperation.effectIn = CMTimeMakeWithSeconds(posA, 600)
            CurrentOperation.effectOut = CMTimeMakeWithSeconds(posB, 600)
         }
    }
    
    private func update(_ p: Double)
    {
        self.updateValues(p)
        let r = self.maxValue - self.minValue
        Swift.print("\(min(self.posA, self.posB)) \(max(self.posA, self.posB))")
        let x = ((min(self.posA, self.posB) - self.minValue) / r) * Double(self.frame.width)
        let width = ((max(self.posA, self.posB) - self.minValue) / r) * Double(self.frame.width) - x
        
        let delta = Double(self.frame.height / 2.0)
        rangeLayer.frame = CGRect.init(x: x + delta, y: 0, width: width - delta, height: Double(self.frame.height))
        rangeLayer.isHidden = false
        
    }


        
    override func mouseMoved(with theEvent: NSEvent) {
        
    }
    
    func setLimit(lower: Double, upper: Double)
    {
        self.minValue = lower
        self.maxValue = upper
        self.doubleValue = self.minValue

    }

    // used for live updating constraint.
    func setLimit(range: CMTimeRange)
    {
        self.minValue = range.start.seconds
        self.maxValue = range.end.seconds
    }

    var range: CMTimeRange {
        let t1 = CMTimeMakeWithSeconds(posA, 600)
        let t2 = CMTimeMakeWithSeconds(posB, 600)        
        if t1.seconds.isLess(than: t2.seconds)
        {
            return CMTimeRange.init(start: t1, end: t2)

        } else {
            return CMTimeRange.init(start: t2, end: t1)
        }
    }
    
    
}
