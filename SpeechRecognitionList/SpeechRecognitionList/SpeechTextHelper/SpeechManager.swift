//
//  SpeechManager.swift
//  SpeechRecognitionList
//
//  Created by M Khalid Assiddiq on 03/06/24.
//

import Foundation
import Speech

class SpeechManager{
    public var isRecording = false
    
    private var audioEngine : AVAudioEngine!
    private var inputNote : AVAudioInputNode!
    private var audioSession : AVAudioSession!
    
    private var recognitionRequest : SFSpeechAudioBufferRecognitionRequest?
    
    func checkPermission(){
        SFSpeechRecognizer.requestAuthorization{(authStatus) in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized: break
                default :
                    print("Speech Recognize is not Available")
                }
            }
        }
    }
    
    func start(completion: @escaping (String?) -> Void){
        if isRecording {
            stopRecording()
        }else{
            startRecording(completion: completion)
        }
    }
    
    func startRecording(completion: @escaping (String?) -> Void){
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            print("Speech Recognize is not availabe")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest!.shouldReportPartialResults = true
        
        recognizer.recognitionTask(with: recognitionRequest!){ (result,error) in
            guard error == nil else {
                print("got error \(error!.localizedDescription)")
                return
            }
            
            guard let result = result else {
                return
            }
            
            if result.isFinal {
                completion(result.bestTranscription.formattedString)
            }
        }
        
        audioEngine = AVAudioEngine()
        inputNote = audioEngine.inputNode
        
        let recodingFormat = inputNote.outputFormat(forBus: 0)
        inputNote.installTap(onBus: 0, bufferSize: 1024, format: recodingFormat){ (buffer, _) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do{
            audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try audioEngine.start()
        }catch{
            print(error)
        }
    }
    
    func stopRecording(){
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        audioEngine.stop()
        inputNote.removeTap(onBus: 0)
        
        try? audioSession.setActive(false)
        audioSession = nil
    }
}
