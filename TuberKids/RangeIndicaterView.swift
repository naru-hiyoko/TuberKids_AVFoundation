//
//  RangeIndicaterView.swift
//  test
//
//  Created by 成沢淳史 on 10/31/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import Cocoa

protocol RangeIndicatorViewProtocol {
    var knobA : CALayer { get set }
    var knobB : CALayer { get set }    
    
    var valueOfA : CGFloat { get }
    var valueOfB : CGFloat { get }
    /**
     absolute distance A and B.
     */
    var distance : CGFloat { get }
    
    var minValueAorB : CGFloat { get }
    var maxValueAorB : CGFloat { get }
    
    var maxValue : CGFloat { get set }
    var minValue : CGFloat { get set }    
}


class RangeIndicatorView : NSView, RangeIndicatorViewProtocol
{
    var delegate : ViewController?
    
    var knobA : CALayer = CALayer()
    var knobB : CALayer = CALayer()
    
    var maxValue : CGFloat = 0.0
    var minValue : CGFloat = 0.0
    
    var valueOfA : CGFloat {
        return (self.knobA.frame.midX / self.frame.width)  * (self.maxValue - self.minValue) + self.minValue
    }
    
    var valueOfB: CGFloat {
        return (self.knobB.frame.midX / self.frame.width) * (self.maxValue - self.minValue) + self.minValue
    }
    
    var distance : CGFloat {
        return abs(self.valueOfA - self.valueOfB)
    }
    
    var minValueAorB: CGFloat {
        return Swift.min(self.valueOfA, self.valueOfB)
    }
    
    var maxValueAorB: CGFloat {
        return Swift.max(self.valueOfA, self.valueOfB)
    }
    
    
    fileprivate var draggingLayer : CALayer?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.gray.cgColor
        
        let width : CGFloat = 10
        
        self.knobA.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.height)
        self.knobA.backgroundColor = NSColor.black.cgColor
        
        self.knobB.frame = CGRect(x: self.frame.width - width, y: 0, width: width, height: self.frame.height)
        self.knobB.backgroundColor = NSColor.black.cgColor
        
        self.knobA.isHidden = true
        self.knobB.isHidden = true
        
        self.layer?.addSublayer(self.knobA)
        self.layer?.addSublayer(self.knobB)
        
        self.fillRegionBetweenAandB()
        
    }
    
    var minValKnob : CALayer {
        return self.valueOfA < self.valueOfB ? self.knobA : self.knobB
    }
    
    /**
     knobA の位置をセットします
 
    */
    
    func setValueOfA(_ val : CGFloat)
    {
        let midX = (val - self.minValue) / (self.maxValue - self.minValue) * self.frame.width
        self.knobA.frame = CGRect(x: midX, y: 0, width: 8, height: self.frame.height)
    }
    
    /**
     knobB の位置をセットします
    */

    func setValueOfB(_ val : CGFloat)
    {
        let midX = (val - self.minValue) / (self.maxValue - self.minValue) * self.frame.width
        self.knobB.frame = CGRect(x: midX, y: 0, width: 8, height: self.frame.height)
    }

    
    override func mouseDragged(with theEvent: NSEvent) {

        let location = locationInFrame(locationInWindow: theEvent.locationInWindow, inRect: self.frame)
        if theEvent.locationInWindow.x <= self.frame.maxX && theEvent.locationInWindow.x >= self.frame.minX
        {
            guard let _layer = self.draggingLayer else  { return }
            _layer.frame = CGRect(x: location.x - (_layer.frame.width / 2.0), y: 0, width: _layer.frame.width, height: _layer.frame.height)
            self.layer?.insertSublayer(_layer, below: self.layer)
            self.fillRegionBetweenAandB()
        }

    }
    
    
    
    override func mouseDown(with theEvent: NSEvent) {
        //super.mouseDown(theEvent)
        let location = self.locationInFrame(locationInWindow: theEvent.locationInWindow, inRect: self.frame)
        guard let _layer = self.knobOfPosition(locationInFrame: location) else { return }
        self.draggingLayer = _layer
    }
    
//    var mouseUpDelegate : (() -> Void)!
    
    override func mouseUp(with theEvent: NSEvent) {
        let location = self.locationInFrame(locationInWindow: theEvent.locationInWindow, inRect: self.frame)
        guard let _layer = self.knobOfPosition(locationInFrame: location) else { return }
        _layer.frame = CGRect(x: location.x - (_layer.frame.width / 2.0), y: 0.0, width: _layer.frame.width, height: _layer.frame.height)
        self.draggingLayer = nil
        self.delegate?.rangeIndicatorModified()
    }
    
    
    fileprivate func knobOfPosition(locationInFrame location : CGPoint) -> CALayer?
    {
        switch location {
        case location where self.knobA.frame.contains(location):
            return self.knobA
        case location where self.knobB.frame.contains(location):
            return self.knobB
        default:
            return nil
        }
    }
    
    override func viewDidEndLiveResize() {
        self.fillRegionBetweenAandB()
    }
    
    /**
     calcutate the local position in self frame. 
     */
    fileprivate func locationInFrame(locationInWindow pos : NSPoint, inRect rect : NSRect) -> CGPoint
    {
        let dx = pos.x - rect.minX
        let dy = pos.y - rect.minY
        let p = CGPoint(x: dx, y: dy)
        
        return p
    }
    
    /**
     Fill the region with color bitween knobA and knobB. 
    */
    
    func fillRegionBetweenAandB()
    {
        let font = NSFont(name: "HiraKakuProN-W3", size: 60)
        let infoImage = textImage(text: self.infoString, font: font!, strokeWidth: 0, strokeColor: NSColor.white.cgColor, 
                                  kern: 0, texture: nil, boarderColor: NSColor.clear.cgColor)
        
        let bitmapInfo = CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedLast.rawValue
        let ctx : CGContext? = CGContext(data: nil, width: Int(self.frame.width), height: Int(self.frame.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo)

        DispatchQueue.global().async {
            DispatchQueue.main.async {
                ctx!.setFillColor(red: 0, green: 0, blue: 0.7, alpha: 0.5)
                let minval = min(self.knobA.frame.midX, self.knobB.frame.midX)
                ctx!.fill(CGRect(x: minval, y: 0, width: abs(self.knobA.frame.midX - self.knobB.frame.midX), height: self.frame.height))
                ctx!.draw(infoImage!, in: CGRect(x: 150, y: 0, width: self.frame.width, height: self.frame.height))
                self.layer?.contents = ctx!.makeImage()
            }
        }
    }
    
    fileprivate var infoString : String {
        let timeA = formatTime(Time: self.minValueAorB)
        let timeB = formatTime(Time: self.maxValueAorB)
        let str = "\(timeA) ~ \(timeB)"
        return str
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
    
    /**
     knobA に minVal , knobB に maxVal をセットし リペイントする
 
    */
    
    func setInitState()
    {
        self.setValueOfA(self.minValue)
        self.setValueOfB(self.maxValue)
        self.fillRegionBetweenAandB()
    }
    
}

