//
//  MovieStorage.swift
//  TuberKids
//
//  Created by 成沢淳史 on 10/17/16.
//  Copyright © 2016 naru. All rights reserved.
//

import Cocoa
import Foundation
import AVFoundation



class VideoDescription 
{
    static var sourceURL: URL?
    static var outputURL: URL?
    static var exportPresetName: String = AVAssetExportPreset640x480
    
    static func getAsset() -> AVAsset?
    {
        guard let url = sourceURL else {
            return nil
        }
        return AVAsset(url: url)
    }
    
    static var isNullSet: Bool {
        if VideoDescription.sourceURL == nil {
            return true
        } else {
            return false
        }
    }
}

class CurrentOperation
{
    static var effectIn: CMTime?
    static var effectOut: CMTime?
    static var effectResource: URL?    
    static var audioVolume: Double = 1.0
    
    static var focusedTextField: NSTextField? 
    

    static var timeRange: CMTimeRange? {
        let (_in, _out) = (effectIn, effectOut)
        let r = CMTimeMakeWithSeconds(_out!.seconds - _in!.seconds, 600)
        let t = CMTimeRange.init(start: _in!, duration: r)
        return t
        
    }
    
    class func debug()
    {
        print(effectIn!)
        print(effectOut!)
        print(audioVolume)
    }
    
}


extension AVAsset
{
    func isAudioTrackEmpty() -> Bool
    {
        return self.tracks(withMediaType: AVMediaTypeAudio).isEmpty
    }
    
}

class VideoEditController : NSObject
{

//    private var resources: [URL]! = []
    
    var preview: AVPreview!
    var itemView: ItemTableView!
    
    var composition: AVMutableComposition? = AVMutableComposition()
    
    var session : AVAssetExportSession?
    
    
    var isResourcesEmpty: Bool
    {
        return TableItems.items.isEmpty
    }
    
    public var exportDelegate : ((_ session : AVAssetExportSession) -> Void) = { (session : AVAssetExportSession) in 
        //
    }
    
    
    override init() {
        super.init()

    }
    
    
    public  func removeTimeRange(_ t: CMTimeRange)
    {
        self.composition!.removeTimeRange(t)
    }
    
    public func scaleTimeRange(_ from: CMTimeRange, to t: CMTime)
    {
        self.composition!.scaleTimeRange(from, toDuration: t)
    }
    
    public func insertEmptyRange(_ t: CMTimeRange)
    {
        self.composition!.insertEmptyTimeRange(t)
    }

    public func removeResourceAtSelectedRow()
    {
        if self.itemView.isExistsSelectedRow
        {
            let at = self.itemView.selectedRow
//            self.resources.remove(at: at)
            self.itemView.removeItemInRow(at)
        }
    }
    
    @available (*, deprecated: 2.00)
    func loadSourceFile(_ url : URL) 
    {
        var arr :[Bool] = []
        for s in ["mov", "mp4"] {
            if url.pathExtension.lowercased().contains(s) {
                arr.append(true)
            } else {
                arr.append(false)
            }
        }
        if !arr.contains(true) {
            return
        }

        
        VideoDescription.sourceURL = url
        let vTrack : AVMutableCompositionTrack = self.composition!.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: 0xAA)
        let svTrack = VideoDescription.getAsset()!.tracks(withMediaType: AVMediaTypeVideo)[0]
        try! vTrack.insertTimeRange(svTrack.timeRange, of: svTrack, at: kCMTimeZero)
        
        let aTrack = self.composition!.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0xAB)
        aTrack.preferredVolume = 1.0
        
        if VideoDescription.getAsset()!.isAudioTrackEmpty()
        {
            // audio track がない場合
            let path = Bundle.main.path(forSoundResource: "noSound.mp3")
            let url = NSURL(fileURLWithPath: path!) as URL
            let saTrack = AVAsset(url: url).tracks(withMediaType: AVMediaTypeAudio)[0]
            try! aTrack.insertTimeRange(saTrack.timeRange, of: saTrack, at: kCMTimeZero)
            // ビデオの再生時間分の長さを確保する
            let duration = CMTimeMakeWithSeconds(floor(vTrack.timeRange.end.seconds - aTrack.timeRange.end.seconds), 600)
            aTrack.insertEmptyTimeRange(CMTimeRangeMake(kCMTimeZero, duration))
            
        } else {
            let saTrack = VideoDescription.getAsset()!.tracks(withMediaType: AVMediaTypeAudio)[0] 
            try! aTrack.insertTimeRange(saTrack.timeRange, of: saTrack, at: kCMTimeZero)                
        }
        
        return 
    }
    
    @available(*, introduced: 2.00)
    private func prepareTracksForVideo()
    {
        assert(VideoDescription.sourceURL != nil)

        let mutableVideoTrack : AVMutableCompositionTrack = self.composition!.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: 0xAA)
        let sourceVideoTrack = VideoDescription.getAsset()!.tracks(withMediaType: AVMediaTypeVideo)[0]
        try! mutableVideoTrack.insertTimeRange(sourceVideoTrack.timeRange, of: sourceVideoTrack, at: kCMTimeZero)
        
        let mutableAudioTrack = self.composition!.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0xAB)
        mutableAudioTrack.preferredVolume = 1.0
        
        if VideoDescription.getAsset()!.isAudioTrackEmpty()
        {
            // audio track がない場合
            let path = Bundle.main.path(forSoundResource: "noSound.mp3")
            let url = NSURL(fileURLWithPath: path!) as URL
            
            let sourceAudioTrack = AVAsset(url: url).tracks(withMediaType: AVMediaTypeAudio)[0]
            try! mutableAudioTrack.insertTimeRange(sourceAudioTrack.timeRange, of: sourceAudioTrack, at: kCMTimeZero)
            // ビデオの再生時間分の長さを確保する
            let duration = CMTimeMakeWithSeconds(floor(mutableVideoTrack.timeRange.end.seconds - mutableAudioTrack.timeRange.end.seconds), 600)
            mutableAudioTrack.insertEmptyTimeRange(CMTimeRangeMake(kCMTimeZero, duration))
            
        } else {
            let sourceAudioTrack = VideoDescription.getAsset()!.tracks(withMediaType: AVMediaTypeAudio)[0] 
            try! mutableAudioTrack.insertTimeRange(sourceAudioTrack.timeRange, of: sourceAudioTrack, at: kCMTimeZero)                
        }

    }
    
    public func loadSourceVideoFromURL(_ url: URL, clearState: Bool = false)
    {
        if VideoDescription.isNullSet
        {
            VideoDescription.sourceURL = url            
            prepareTracksForVideo()
        } else {
            if clearState {
                initState()
                VideoDescription.sourceURL = url
                prepareTracksForVideo()
            }
            
        }
        
        setupPreview()
        
    }
    
    private func setupPreview()
    {
        guard let preview = self.preview else {
            print("preview was not set. @VideoEditor")
            return 
        }
        
        preview.videoEditor = self
        preview.setupPreview(composition: self.composition!)
    }
    

    private func initState()
    {
        VideoDescription.sourceURL = nil
        self.composition = nil
        self.composition = AVMutableComposition()
    }
    

    internal func removeTrackWithId(_ id : CMPersistentTrackID)
    {
        let track = self.composition!.track(withTrackID: id)
        self.composition!.removeTrack(track!)
    }
    
    
    
}



