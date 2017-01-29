//
//  Common.swift
//  TuberKids
//
//  Created by 成沢淳史 on 11/4/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Foundation
import AVFoundation

enum AnimationStyle : Int {
    case `default`, fade, scale, rotation, spring
}
 
 
class EffectData : NSObject, NSCoding {
    
    var layer : CALayer
    var normalizedFrame : CGRect?
    var timeRange : CMTimeRange
    var url : URL?
    var type : String?
    var trackId : CMPersistentTrackID?
    var options : Dictionary<String, AnyObject>?
    
    private var _start : Double?
    private var _end : Double?
    
    
    init(layer : CALayer, normalizedFrame : CGRect?, timeRange : CMTimeRange, url : URL?,
         type : String?, trackId : CMPersistentTrackID?, options : Dictionary<String, AnyObject>?) {
        self.layer = layer
        self.normalizedFrame = normalizedFrame
        self.timeRange = timeRange
       
        self.url = url
        self.type = type
        self.trackId = trackId
        self.options = options
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.layer = aDecoder.decodeObject(forKey: "layer") as! CALayer
        self.normalizedFrame = aDecoder.decodeObject(forKey: "normalizedFrame") as? CGRect        
        
        self._start = aDecoder.decodeObject(forKey: "_start") as? Double
        self._end = aDecoder.decodeObject(forKey: "_end") as? Double        
        let st = CMTimeMakeWithSeconds(self._start!, 600)
        let ed = CMTimeMakeWithSeconds(self._end!, 600)
        self.timeRange = CMTimeRangeMake(st, ed)
        
        self.url = aDecoder.decodeObject(forKey: "url") as? URL 
        self.type = aDecoder.decodeObject(forKey: "type") as? String
//        self.trackId = aDecoder.decodeObject(forKey: "trackId") as? CMPersistentTrackID
        self.options = aDecoder.decodeObject(forKey: "options") as! Dictionary<String, AnyObject>?
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.layer, forKey: "layer")
        aCoder.encode(self.normalizedFrame, forKey: "normalizedFrame")

        self._start = timeRange.start.seconds
        self._end = timeRange.end.seconds
 
        aCoder.encode(self._start, forKey: "_start")
        aCoder.encode(self._end, forKey: "_end")
        aCoder.encode(self.url, forKey: "url")        
        aCoder.encode(self.type, forKey: "type")        
//        aCoder.encode(self.trackId, forKey: "trackId")        
        aCoder.encode(self.options, forKey: "options")        
    }
    

}
