//
//  EZAudioManager.swift
//  SoundRecorder
//
//  Created by TangYunfei on 2017/2/23.
//  Copyright © 2017年 dtstack.com. All rights reserved.
//

import Foundation
import AVFoundation

public protocol EZAudioManagerDelegate: class {
    func audioPlayerDidFinishPlaying(successfully flag: Bool)
}

private enum State {
    case play
    case record
    case none
}

public class EZAudioManager:NSObject,AVAudioPlayerDelegate {

    public weak var delegate:EZAudioManagerDelegate?
    public var sampleRate = 44100.0
    public var channel = 1
    public var format = kAudioFormatMPEG4AAC
    public var quality = AVAudioQuality.medium
    
    private var audioRecorder:AVAudioRecorder?
    private var audioPlayer:AVAudioPlayer?
    private var state: State = .none
    private let serialQueue = DispatchQueue(label: "audio.clouder.com")
    
    override init() {
        super.init()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch {
        }
    }
    
    private func directoryURL() -> URL? {
        let currentDateTime = Date()
        let recordingName = currentDateTime.toString() + ".caf"
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent(recordingName)
        return soundURL
    }
    
    private func createAudioRecorder() -> AVAudioRecorder {
        var result: AVAudioRecorder?
        
        let recordSettings = [
            AVSampleRateKey : NSNumber(value: Float(self.sampleRate)),
            AVFormatIDKey : NSNumber(value: Int32(self.format)),
            AVNumberOfChannelsKey : NSNumber(value: self.channel),
            AVEncoderAudioQualityKey : NSNumber(value: Int32(self.quality.rawValue))
        ]
        
        do {
            try result = AVAudioRecorder(url: self.directoryURL()!,
                                                     settings: recordSettings)
            result?.prepareToRecord()
        } catch {
        }
        
        return result!
    }
    
    private func createAudioPlayer(with url:URL) -> AVAudioPlayer {
        var result: AVAudioPlayer?
        
        do {
            try result = AVAudioPlayer(contentsOf: url)
            result?.delegate = self
        } catch {
        }
        
        return result!
    }
    
    public func startRecord () {
        
        if self.state == .none {
            self.serialQueue.async {
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setActive(true)
                    self.audioRecorder = self.createAudioRecorder()
                    self.audioRecorder?.record()
                    self.state = .record
                    print("record!")
                } catch {
                }
            }
        }
    }
    
    public func stopRecord () -> URL? {
        if self.state == .record {
            self.audioRecorder?.stop()
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setActive(false)
                self.state = .none
                print("stop!!")
            } catch {
            }
        }
        
        return self.audioRecorder?.url
    }
    
    public func startPlay(with url:URL?) {
        if self.state != .record {
            self.serialQueue.async {
                var audioUrl:URL?
                
                if url != nil {
                    audioUrl = url!
                } else {
                    audioUrl = self.audioRecorder?.url
                }
                
                if audioUrl == nil {
                    return
                }
                
                self.audioPlayer = self.createAudioPlayer(with: audioUrl!)
                self.audioPlayer?.play()
                self.state = .play
                print("play!!")
            }
        }
    }
    
    
    public func stopPlay () {
        
        if self.state == .play {
            self.serialQueue.async {
                self.audioPlayer?.pause()
                self.state = .none
            }
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.delegate?.audioPlayerDidFinishPlaying(successfully: flag)
        self.state = .none
    }
}


extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
