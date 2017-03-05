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
    let tmp = URL.init(fileURLWithPath: "/Volumes/ramdisk/tmp")
    
    override init() {
        super.init()
        do {
            try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true, attributes: nil)
        } catch let e {
            let p = NSAlert.init(error: e)
            p.runModal()
            
        }
    }
    
    func saveState(_ source: URL, effects: [EffectData])
    {
        print("original file : \(source.path)")
        
        let panel = NSOpenPanel.init()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.message = "保存先のディレクトリを選んでください"
        switch panel.runModal() {
        case NSModalResponseOK:
            print("ok")
        case NSModalResponseCancel:
            print("cancel")
            return
        default:
            return
        }
        
        for (i, effect) in effects.enumerated()
        {
            print("item \(i) : \(effect.url!.path)")
            
            let data = NSKeyedArchiver.archivedData(withRootObject: effect)
            let s = URL.init(string: "item_\(i)", relativeTo: self.tmp)
            do {
                if FileManager.default.fileExists(atPath: s!.path) {
                    try FileManager.default.removeItem(at: s!)
                }
            } catch let e {
                let al = NSAlert.init(error: e)
                al.runModal()
            }

            do {
                try data.write(to: s!)
            } catch let e {
                let al = NSAlert.init(error: e)
                al.runModal()
            }
        }
        

    }
    
    func loadState(preview : AVPrevView, editer : VideoEditController)
    {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: self.tmp.path)
            for file in files {
                if file.contains("item")
                {
                    self.loadItem(file, preview: preview, editer: editer)
                }
            }
        } catch let err {
            let al = NSAlert.init(error: err)
            al.runModal()
        }
        
    }  
    
    private func loadItem(_ name : String, preview: AVPrevView, editer: VideoEditController)
    {
        let dataUrl = URL.init(string: name, relativeTo: self.tmp)
        let data = try! Data.init(contentsOf: dataUrl!)
        let effect = NSKeyedUnarchiver.unarchiveObject(with: data) as! EffectData
        let timeRange : CMTimeRange = effect.timeRange 
        let fSize : CGRect = effect.rect!
        

    }
        
}
