//
//  textImage.swift
//  TuberKids
//
//  Created by 成沢淳史 on 11/2/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import Cocoa

extension String 
{
    subscript(a : Int) -> String?
    {
        if a >= self.count {
            return nil
        } else {
            return String(self[self.characters.index(self.startIndex, offsetBy: a)])
        }
    }
    
    subscript(r : Range<Int>) -> String? {
        let st = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
        let end = self.characters.index(self.startIndex, offsetBy: r.upperBound)
        if self.characters.distance(from: self.startIndex, to: end) > self.count 
        {
            return nil
        } else {
            return String(self[st..<end])            
        }
    }
    
    var count : Int {
        return self.characters.distance(from: self.startIndex, to: self.endIndex)
    }
    
    var reverse : String {
        var ret : String = ""
        for i in 1...self.count
        {
            let c = self[self.characters.index(self.endIndex, offsetBy: -1 * i)]
            ret.append(c)
        }
        return ret
    }
    
}



func textImage(text string : String, font : NSFont? = nil, strokeWidth : Int = 5,
                    strokeColor : CGColor = NSColor.black.cgColor, 
                    kern : Int = 18, texture : URL?, boarderColor : CGColor = NSColor.white.cgColor) -> CGImage?
{
    
    var fontName : String = "HiraKakuProN-W3" 
    var fontSize : CGFloat = 128
    
    if font != nil {
        fontName = font!.fontName
        fontSize = font!.pointSize
    }
    
    
    let preferWidth = CGFloat((Int(fontSize) + kern) * string.count - kern)
    let preferHeight = CGFloat(fontSize)
    let frame = CGRect(x: 10,y: 200, width: preferWidth, height: preferHeight) 
    
    
    let textLayer : CATextLayer = CATextLayer()
    textLayer.string = NSAttributedString(string: string, attributes: [
        NSFontAttributeName : NSFont(name: fontName, size: fontSize)!,
        NSStrokeWidthAttributeName : strokeWidth,
        NSKernAttributeName : kern,
        NSForegroundColorAttributeName : strokeColor,
        ])
    textLayer.frame = frame
    textLayer.backgroundColor = NSColor.clear.cgColor
    
    
    let c = CGContext(data: nil, width: Int(preferWidth), height: Int(preferHeight),
                      bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                      bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedLast.rawValue)
    
    textLayer.render(in: c!)
    let cgA : CGImage! = c!.makeImage()
    
    // 切り抜きたい画像
    if texture == nil {
        return cgA
    }
    
    guard let dataB = try? Data.init(contentsOf: texture!) else {
        print("No file B")
        return cgA
    }
    let cgB : CGImage! = NSBitmapImageRep(data: dataB)!.cgImage
    
    // グレイスケールのアルファマスク画像を生成
    let ctx = CGContext(data: nil, width: cgA.width, height: cgA.height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(),
                                    bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.alphaOnly.rawValue)
    ctx!.draw(cgA, in: CGRect(x: 0, y: 0, width: CGFloat(cgA.width), height: CGFloat(cgA.height)))
    let mask : CGImage! = ctx!.makeImage()

    assert(mask.isMask)
    let crop : CGImage! = cgB.masking(mask)

    
    // 枠線
    let textBackLayer : CATextLayer = CATextLayer()
    textBackLayer.backgroundColor = NSColor.clear.cgColor
    textBackLayer.frame = frame
    
    textBackLayer.string = NSAttributedString.init(string: string, attributes: [
        NSFontAttributeName : NSFont(name: fontName, size: fontSize)!,
        NSStrokeWidthAttributeName : strokeWidth + 5,
        NSKernAttributeName : kern,
        NSForegroundColorAttributeName : boarderColor,
        ])
    
    // to CGImage
    
    let __ctx = CGContext(data: nil, width: cgA.width, height: cgA.height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedLast.rawValue)
    textBackLayer.render(in: __ctx!)
    __ctx!.draw(crop, in: CGRect(x: 0, y: 0, width: preferWidth, height: preferHeight))
    let out = __ctx!.makeImage()

    return out
    
    
}

func textImageVertical (text string : String, font : NSFont? = nil, strokeWidth : Int = 5,
                                           strokeColor : CGColor = NSColor.black.cgColor, 
                                           kern : Int = 18, texture : URL?, boarderColor : CGColor = NSColor.white.cgColor) -> CGImage?

{

    var fontSize : CGFloat = 50
    
    if font != nil {
        fontSize = font!.pointSize
    }
    

    let preferedWidth = CGFloat(fontSize)
    let preferedHeight = CGFloat((Int(fontSize) + kern) * string.count - kern)
    
    let bitmapInfo = CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedLast.rawValue
    let _ctx = CGContext(data: nil, width: Int(preferedWidth), height: Int(preferedHeight), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo)

    for i in 0..<string.count
    {

        let _image : CGImage? = textImage(text: string.reverse[i]!, font: font, strokeWidth: strokeWidth, strokeColor: strokeColor,
                                                           kern: 0, texture: texture, boarderColor: boarderColor)
        assert(_image != nil)
        
        _ctx?.draw(_image!, in: CGRect(x: 0, y: (fontSize + CGFloat(kern)) * CGFloat(i), width: fontSize, height: fontSize))

    }
    
    let _out = _ctx?.makeImage()
    
    return _out
    
}
