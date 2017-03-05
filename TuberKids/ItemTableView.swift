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

class TableItems 
{
    static var items: [URL] = []
    static var textInRow: [String] = []
}

class ItemTableView : NSTableView, NSTableViewDelegate, NSTableViewDataSource
{
    var isExistsSelectedRow: Bool
    {
        return self.selectedRow == -1 ? false : true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
        self.dataSource = self
        self.register(forDraggedTypes: [NSFilenamesPboardType])
        self.backgroundColor = NSColor.clear
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        let cell = tableColumn?.dataCell(forRow: row) as! NSTextFieldCell
        
        if TableItems.textInRow[row] == "" {
            cell.title = TableItems.items[row].lastPathComponent
        } else {
            cell.title = TableItems.textInRow[row]
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
        TableItems.textInRow[id] = string
        return true
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if TableItems.textInRow.count != TableItems.items.count {
            //textInRow = [String].init(count: self.items.count, repeatedValue: "")
            TableItems.textInRow.append("")
        }
        return TableItems.items.count
    }
    
    
    func removeItemInRow(_ row : Int)
    {
        if row == -1 {
            return
        }
        TableItems.items.remove(at: row)
        TableItems.textInRow.remove(at: row)
        self.reloadData()
    }
    
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        for item in info.draggingPasteboard().pasteboardItems!
        {
            let propertyList = item.propertyList(forType: "public.file-url") as Any
            let url = NSURL.init(pasteboardPropertyList: propertyList, ofType: "public.file-url") as! URL
            
            TableItems.items.append(url)
            while TableItems.textInRow.count < TableItems.items.count
            {
                TableItems.textInRow.append("")
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
        let s = TableItems.textInRow[i]

        Swift.print(s)
    }
    

    
    
    
    
    
    
}
