//
//  RangeIndicaterView.swift
//  test
//
//  Created by 成沢淳史 on 10/31/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

fileprivate extension NSPoint
{
    static func * (l: NSPoint, r: CGFloat) -> NSPoint
    {
        return NSPoint.init(x: l.x * r, y: l.y * r)
    }
    
    static func / (l: NSPoint, r: CGFloat) -> NSPoint
    {
        return NSPoint.init(x: l.x / r, y: l.y / r)
    }
    
    
    func proportion(_ frame: CGRect) -> NSPoint
    {
        let x = self.x / frame.width
        let y = self.y / frame.height
        return NSPoint.init(x: x, y: y)   
    }
    
    func floatValue(_ v: RangeIndicatorView) -> CGFloat
    {
        let r = v.maxValue - v.minValue
        let _p = self.proportion(v.frame)
        return (_p.x * r) + v.minValue
   
    }
}

extension Double
{
    func constraint(lower: Double, upper: Double) -> Double
    {
        if self <= lower 
        {
            return lower
        }
        
        if self >= upper
        {
            return upper
        }
        
        return self
    }
    
    func isInsize(lower: Double, upper: Double) -> Bool
    {
        if lower <= self && self <= upper
        {
            return true
        } else {
            return false
        }
    }
   
}

extension CGFloat
{
    func constraint(lower: CGFloat, upper: CGFloat) -> CGFloat
    {
        if self <= lower 
        {
            return lower
        }
        
        if self >= upper
        {
            return upper
        }
        
        return self
    }
    
    func isInsize(lower: CGFloat, upper: CGFloat) -> Bool
    {
        if lower <= self && self <= upper
        {
            return true
        } else {
            return false
        }
    }
}

protocol RangeBarDelegate {
    func modified()
}


class RangeIndicatorView : NSView
{
    var delegate : RangeBarDelegate?
    
    private var _maxValue: CGFloat = 1.0
    private var _minValue: CGFloat = 0.0    
    
    var maxValue : CGFloat {
        get {
            return _maxValue
        }
        
        set(a) {
            _maxValue = a
        }
    }
    
    var minValue : CGFloat {
        get {
            return _minValue
        }
        
        set(a) {
            _minValue = a
        }
    }


    
    private var valueA: CGFloat = 0.0
    private var valueB: CGFloat = 1.0
    
    var range: CMTimeRange {
        let t1 = CMTimeMakeWithSeconds(Float64(valueA), 600)
        let t2 = CMTimeMakeWithSeconds(Float64(valueB), 600)
        
        if valueA.isLess(than: valueB)
        {
            return CMTimeRange.init(start: t1, end: t2)

        } else {
            return CMTimeRange.init(start: t2, end: t1)
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        self.layer!.backgroundColor = CGColor.init(gray: 0.4, alpha: 0.4)

    }
    
    func setLimit(lower: CGFloat, upper: CGFloat)
    {
        self._maxValue = upper
        self._minValue = lower
        self.valueA = self.minValue
        self.valueB = self.maxValue
        self.update()
    }
    
    
    override func mouseDragged(with theEvent: NSEvent) {
        guard let p = convert(theEvent.locationInWindow, limit: false) else { return }
        updateValue(p)
        update()
    }
    
    
    
    override func mouseDown(with theEvent: NSEvent) {
        guard let p = convert(theEvent.locationInWindow, limit: true) else { return }
        updateValue(p)
        update()
    }
    
    
    override func mouseUp(with theEvent: NSEvent) {

    }
    
    override func viewDidEndLiveResize() {

    }
    
    func updateValue(_ p: NSPoint)
    {
        if abs(p.floatValue(self) - valueA) > abs(p.floatValue(self) - valueB)
        {
            self.valueB = p.floatValue(self)
        } else {
            self.valueA = p.floatValue(self)
        }

    }
    
    func update()
    {
        let size = self.frame.size
        let bitmapInfo = CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedLast.rawValue
        let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                            bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo)!
        ctx.setFillColor(CGColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.4))
        let r = maxValue - minValue
        let x = ((min(valueA, valueB) - minValue) / r) * self.frame.width
        let width = ((max(valueA, valueB) - minValue) / r) * self.frame.width - x
        
        let rect = CGRect.init(x: x, y: 0, width: width, height: self.frame.height)
        ctx.fill(rect)
        
        textImageLayer().render(in: ctx)
        
        self.layer!.contents = ctx.makeImage()

    }

    private func textImageLayer() -> CATextLayer
    {
        let layer = CATextLayer()
        layer.fontSize = 16
        layer.foregroundColor = CGColor.black
        layer.string = self.displayString
        layer.alignmentMode = "center"
        layer.frame = self.frame
        return layer
    }
    
    
    fileprivate func formatTime(Time sec : CGFloat) -> String
    {
        let ss : Int = Int(sec) % 60
        let m : Int = Int(sec) / 60
        return String(format: "%d:%02d", m, ss)
    }
    
    var displayString: String {
        let a = formatTime(Time: valueA)
        let b = formatTime(Time: valueB)
        return "\(a) 〜 \(b)"
    }
    
    @available (*, introduced: 2.00)
    func convert(_ p: NSPoint, limit: Bool = false) -> NSPoint?
    {
        
        var _p = self.convert(p, from: self.superview!)
        
        if limit
        {
            return _p.x.isInsize(lower: 0.0, upper: self.frame.width) && _p.y.isInsize(lower: 0.0, upper: self.frame.height) ? _p : nil

        } else {
            _p.x = _p.x.constraint(lower: 0.0, upper: self.frame.width)
            _p.y = _p.y.constraint(lower: 0.0, upper: self.frame.height)
        }

         
        return _p
        
    }
    
    
    


    
}

