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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
        self.dataSource = self
        self.register(forDraggedTypes: [NSFilenamesPboardType])
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
    
}
