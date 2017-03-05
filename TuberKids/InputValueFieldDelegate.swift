//
//  InputValueFieldDelegate.swift
//  TuberKids
//
//  Created by 成沢淳史 on 2017/03/03.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

class InputFieldDelegate: NSObject, NSTextFieldDelegate
{
    override func controlTextDidEndEditing(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        let inputCheck : (_ : Double, _ : Double) -> Bool = { (a, b) in
            if a > b
            {
                soundAlert()
                return true
            } else {
                return false
            }
        }

        switch textField.identifier! {
        case "fromValue":
            CurrentOperation.effectIn = CMTimeMakeWithSeconds(textField.doubleValue, 600)
        case "toValue":
            CurrentOperation.effectOut = CMTimeMakeWithSeconds(textField.doubleValue, 600)
        default:
            CurrentOperation.focusedTextField = nil
            break
        }
    }
    
    func animationSpecified()
    {
        
        print("call")
    }
}

