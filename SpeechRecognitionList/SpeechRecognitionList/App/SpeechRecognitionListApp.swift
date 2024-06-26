//
//  SpeechRecognitionListApp.swift
//  SpeechRecognitionList
//
//  Created by M Khalid Assiddiq on 03/06/24.
//

import SwiftUI

@main
struct SpeechRecognitionListApp: App {
    
    @Environment(\.colorScheme) var colorScheme
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(colorScheme == .dark ? .dark : .light)
        }
    }
}
