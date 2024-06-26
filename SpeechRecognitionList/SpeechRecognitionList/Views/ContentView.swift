//
//  ContentView.swift
//  SpeechRecognitionList
//
//  Created by M Khalid Assiddiq on 03/06/24.
//

import SwiftUI
import CoreData
import AVFoundation

struct ContentView: View {
    
    @State var helloText: String = "Hello... I'm Khalid, Can you say 'Fuck You' to me"
    @State var animatedText: String = ""
    @State var audioPlayer: AVAudioPlayer?
    @State var animationTimer: Timer?
    @State var isMicEnabled: Bool = false
    
    @State var isPlaying: Bool = false
    
    @State var textSetelahNgomong: String = "Fuck you"
    @State var textColor: Color = .black
    @State var offset: CGFloat = 0
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.created , ascending: true)],
        animation: .default) private var todos: FetchedResults<Item>
    
    @State private var recording = false
    @ObservedObject private var mic = MicManager(numberOfSamples: 8)
    private var speechManager = SpeechManager()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(todos) { item in
                        Text(item.text ?? " - ")
                    }
                    .onDelete(perform: deleteItems)
                }.navigationTitle("List MySpeech")
                
                Text(animatedText)
                    .font(.title)
                    .frame(alignment: .center)
                    .foregroundColor(.black)
                    .onAppear {
                        playSoundAndAnimateText()
                    }
                    .padding()
                
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.2))
                    .frame(width: 120, height: 70)
                    .padding()
                    .overlay(
                        visualizerView()
                    )
                    .opacity(recording ? 1 : 0)
                
                HStack {
                    Text(textSetelahNgomong)
                        .font(.title2)
                        .foregroundColor(textColor)
                        .offset(y: offset)
                        .animation(.easeInOut(duration: 0.5), value: offset)
                    recordButton()
                }
                
                resetButton()
                
            }.onAppear {
                speechManager.checkPermission()
            }
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func recordButton() -> some View {
        Button(action: addItem) {
            Image(systemName: recording ? "stop.fill" : "mic.fill")
                .font(.system(size: 40))
                .padding()
                .cornerRadius(10)
        }.foregroundColor(.red)
    }
    
    private func addItem() {
        if speechManager.isRecording {
            self.recording = false
            mic.stopMonitoring()
            speechManager.stopRecording()
        } else {
            self.recording = true
            mic.startMonitoring()
            speechManager.start { (speechText) in
                guard let text = speechText, !text.isEmpty else {
                    self.recording = false
                    return
                }
                
                DispatchQueue.main.async {
                    withAnimation {
                        let newItem = Item(context: viewContext)
                        newItem.id = UUID()
                        newItem.created = Date()
                        newItem.text = text
                        
                        // Check if the full sentence is contained in the recognized text
                        if text.localizedCaseInsensitiveContains(self.textSetelahNgomong) {
                            textColor = .red
                            performJumpAnimation()
                        } else {
                            textColor = .black
                        }
                        
                        do {
                            try viewContext.save()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        
        speechManager.isRecording.toggle()
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { todos[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2
        return CGFloat(level * (100 / 25))
    }
    
    private func visualizerView() -> some View {
        VStack {
            HStack(spacing: 8) {
                ForEach(mic.soundSamples, id: \.self) { level in
                    VisualBarView(value: self.normalizeSoundLevel(level: level))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    func playSoundAndAnimateText() {
        guard !isPlaying else {
            // Audio is currently playing, don't start another instance
            return
        }
        
        guard let soundURL = Bundle.main.url(forResource: "helloRecord", withExtension: "mp3") else {
            print("Sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            // Set isPlaying to true when audio starts
            isPlaying = true
            
            // Disable mic button while audio is playing
            isMicEnabled = false
            
            animateText()
            
            // Enable mic button and reset isPlaying when audio finishes playing
            DispatchQueue.main.asyncAfter(deadline: .now() + (audioPlayer?.duration ?? 0)) {
                isMicEnabled = true
                isPlaying = false
            }
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func animateText() {
        animatedText = ""
        for (index, character) in helloText.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 + Double(index) * 0.1) {
                animatedText.append(character)
                // You can add haptic feedback to support typing animation (optional).
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
    
    private func performJumpAnimation() {
        withAnimation(.easeInOut(duration: 0.25)) {
            offset = -20
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeInOut(duration: 0.25)) {
                offset = 50
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    offset = 0
                }
            }
        }
    }
    
    private func resetButton() -> some View {
        Button(action: resetConditions) {
            Text("Reset")
                .font(.system(size: 20))
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    private func resetConditions() {
        recording = false
        animatedText = ""
        textColor = .black
        offset = 0
        speechManager.isRecording = false
        playSoundAndAnimateText()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
