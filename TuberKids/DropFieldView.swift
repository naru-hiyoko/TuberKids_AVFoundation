//
//  DDView.swift
//  TuberKids
//
//  Created by 成沢淳史 on 10/16/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import Cocoa
import Darwin


class DropFieldView : NSView
{
    var delegate : ViewController?
    
    var pathArray : [NSURL] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.register(forDraggedTypes: [NSFilenamesPboardType])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pb = sender.draggingPasteboard()

        for item in pb.pasteboardItems! {
            let path = item.propertyList(forType: item.types[0])
            let absPath = NSURL(pasteboardPropertyList: path!, ofType: item.types[0])
            self.pathArray.append(absPath!)
        }
        
//        self.notify(self.pathArray)        
        self.delegate?.itemDropped(items: self.pathArray)
        return true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.setFill()
        NSRectFill(dirtyRect) 
        
        
        self.alphaValue = 0.5
    }
    
    // Notification に変更予定
    var notify = { (arr : [NSURL]) in
        // override 
    }


}
