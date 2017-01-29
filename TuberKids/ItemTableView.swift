//
//  ItemTableView.swift
//  TuberKids
//
//  Created by 成沢淳史 on 10/21/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

class ItemTableView : NSTableView, NSTableViewDelegate, NSTableViewDataSource
{

    var items : [URL] = []
    var textInRow : [String] = []
    
    var controler : ViewController?
    var editor : VideoEditController?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
        self.dataSource = self
        self.register(forDraggedTypes: [NSFilenamesPboardType])
        self.backgroundColor = NSColor.clear
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        let cell = tableColumn?.dataCell(forRow: row) as! NSTextFieldCell
        
        if textInRow[row] == "" {
            cell.title = items[row].lastPathComponent
        } else {
            cell.title = textInRow[row]
        }
        cell.isEditable = true
        return cell
    }
    
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        // optional(***) まで String になるので注意!!!
        pboard.setString("\(rowIndexes.first!)", forType: NSStringPboardType)
        return true
    }
    
    
    override func textShouldEndEditing(_ textObject: NSText) -> Bool {
        let id = self.selectedRow
        let string = textObject.string!
        textInRow[id] = string
        return true
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if textInRow.count != self.items.count {
            //textInRow = [String].init(count: self.items.count, repeatedValue: "")
            textInRow.append("")
        }
        return items.count
    }
    
    
    func removeItemInRow(_ row : Int)
    {
        if row == -1 {
            return
        }
        self.items.remove(at: row)
        self.textInRow.remove(at: row)
        self.reloadData()
    }
    
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        for item in info.draggingPasteboard().pasteboardItems!
        {
            let propertyList = item.propertyList(forType: "public.file-url") as Any
            let url = NSURL.init(pasteboardPropertyList: propertyList, ofType: "public.file-url") as! URL
            
            if self.editor!.sourceURL == nil
            {
                self.editor!.loadSourceFile(url)
                self.controler?.syncItems([url])
                
                return true
            } else {
                self.items.append(url)
                while self.textInRow.count < self.items.count
                {
                    self.textInRow.append("")
                }
            }
        }
        self.reloadData()

        return true
    }
     
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let i = self.selectedRow
        if i == -1 { return }
        let s = self.textInRow[i]

        Swift.print(s)
    }
    

    
    
    
    
    
    
}
