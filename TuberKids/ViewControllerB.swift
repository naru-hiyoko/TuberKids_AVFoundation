//
//  ViewControllerB.swift
//  TuberKids
//
//  Created by 成沢淳史 on 11/9/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import Cocoa

protocol ViewControllerBProtocol {
    var onLoad : Bool { get }
}

class ViewControllerB : NSViewController, NSTextFieldDelegate
{
    // 画像テキスト オプション
    @IBOutlet weak var _fromValField : NSTextField!
    @IBOutlet weak var _toValField : NSTextField!
    @IBOutlet weak var _durationField : NSTextField!
    var presented : Bool = false
    var onLoad : Bool = false

    var from = 0.0
    var to = 0.0 
    var animationDuration = 1.0
    
    override func viewDidAppear() {
        super.viewDidLoad()
        self.presented = true
        self._fromValField.delegate = self
        self._toValField.delegate = self

    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.presented = false

    }
    
    override func viewDidLoad() {
        self.onLoad = true
    }
    
    func checkState() -> Bool
    {
        return self.onLoad
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        self.from = self._fromValField.doubleValue 
        self.to = self._toValField.doubleValue
        self.animationDuration = self._durationField.doubleValue
    }
    
}
