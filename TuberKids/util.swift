//
//  util.swift
//  TuberKids
//
//  Created by 成沢淳史 on 2017/03/02.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa



extension CMTimeRange
{
    func ContainsTime(_ t: Double) -> Bool
    {
        if self.start.seconds <= t && t <= self.end.seconds
        {
            return true
        } else {
            return false
        }
    }
}

func euc(p1 : CGPoint, p2 : CGPoint) -> CGFloat
{
    let e = sqrt(pow(p1.x - p2.x, 2.0) + pow(p1.y - p2.y, 2.0))
    return e
    
}

public func double2TimeRangeSet(_ a: Double, _ b: Double) -> (CMTimeRange, CMTimeRange)
{
    let rangeA = CMTimeRangeMake(CMTimeMakeWithSeconds(a, 600), CMTimeMakeWithSeconds(b, 600))
    let rangeB = CMTimeRangeMake(CMTimeMakeWithSeconds(a, 600), CMTimeMakeWithSeconds(b - a, 600))
    return (rangeA, rangeB)
}

public func formatTime(Time sec : CGFloat) -> String
{
    //        let ms : Int = Int(sec - CGFloat(sec))
    let ss : Int = Int(sec) % 60
    let m : Int = Int(sec) / 60
    //        let mm : Int = m % 60
    //        let h : Int = m / 60
    return String(format: "%d:%02d", m, ss)
}

public func soundAlert()
{
    let path = Bundle.main.path(forResource: "Funk", ofType: "aiff")
    let url = NSURL(string: path!)
    let funkSound = try! AVAudioPlayer(contentsOf: url!.absoluteURL!)
    funkSound.play()
}

internal func popWarnPanel(_ e: NSError)
{
    let alert = NSAlert(error: e)
    alert.alertStyle = NSAlertStyle.critical
    alert.runModal()        
}


func openSelectPanelForMovie() -> URL?
{
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = false
    for type in ["mp4", "mov"]
    {
        panel.allowedFileTypes?.append(type)
        panel.allowedFileTypes?.append(type.uppercased())
    }
    
    panel.runModal()
    
    return panel.url
}

func openCompleteDialog()
{
    
    let alert = NSAlert.init()
    alert.alertStyle = NSAlertStyle.informational
    alert.messageText = "完了しました"
    alert.runModal()

}

