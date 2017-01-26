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
        self.timeRange = aDecoder.decodeObject(forKey: "timeRange") as! CMTimeRange                
        self.url = aDecoder.decodeObject(forKey: "url") as? URL 
        self.type = aDecoder.decodeObject(forKey: "type") as? String
//        self.trackId = aDecoder.decodeObject(forKey: "trackId") as? CMPersistentTrackID
        self.options = aDecoder.decodeObject(forKey: "options") as! Dictionary<String, AnyObject>?
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.layer, forKey: "layer")
        aCoder.encode(self.normalizedFrame, forKey: "normalizedFrame")
        aCoder.encode(self.timeRange, forKey: "timeRange")
        aCoder.encode(self.url, forKey: "url")        
        aCoder.encode(self.type, forKey: "type")        
//        aCoder.encode(self.trackId, forKey: "trackId")        
        aCoder.encode(self.options, forKey: "options")        
    }
    

}
