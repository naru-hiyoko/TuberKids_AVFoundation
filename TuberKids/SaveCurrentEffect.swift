//
//  SaveCurrentEffect.swift
//  TuberKids
//
//  Created by 成沢淳史 on 2017/01/26.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa



class SaveCurrentEffect : NSObject
{
    let tmp = URL.init(string: "/Volumes/ramdisk/tmp")!
    override init() {
        super.init()
        do {
            try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true, attributes: nil)
        } catch let e {
            let p = NSAlert.init(error: e)
            p.runModal()
            
        }
    }
    
    func prepare(_ source: URL, effects: [EffectData])
    {
        print("original file : \(source.path)")
        
        

    }
        
}
