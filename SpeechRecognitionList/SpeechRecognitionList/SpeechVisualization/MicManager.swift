//
//  MicMonitor.swift
//  SpeechRecognitionList
//
//  Created by M Khalid Assiddiq on 03/06/24.
//

import Foundation
import AVFoundation

class MicManager: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    private var currentSample: Int
    private let numberOfSamples: Int
    
    @Published public var soundSamples: [Float]
    
    init(numberOfSamples: Int) {
        self.numberOfSamples = numberOfSamples > 0 ? numberOfSamples : 10
        self.soundSamples = [Float](repeating: .zero, count: numberOfSamples)
        self.currentSample = 0
        
        self.checkPermissions()
        self.setupRecorder()
    }
    
    private func checkPermissions() {
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission { granted in
                if !granted {
                    fatalError("We need audio recording permission to visualize audio levels.")
                }
            }
        }
    }
    
    private func setupRecorder() {
        let url = URL(fileURLWithPath: "/dev/null", isDirectory: true)
        let recorderSettings: [String: Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recorderSettings)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            audioRecorder?.isMeteringEnabled = true
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    public func startMonitoring() {
        audioRecorder?.record()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { [weak self] _ in
            self?.audioRecorder?.updateMeters()
            if let currentSample = self?.currentSample, let audioRecorder = self?.audioRecorder, let numberOfSamples = self?.numberOfSamples {
                self?.soundSamples[currentSample] = audioRecorder.averagePower(forChannel: 0)
                self?.currentSample = (currentSample + 3) % numberOfSamples
            }
        }
    }
    
    public func stopMonitoring() {
        audioRecorder?.stop()
        timer?.invalidate()
    }
    
    deinit {
        timer?.invalidate()
        audioRecorder?.stop()
    }
}
