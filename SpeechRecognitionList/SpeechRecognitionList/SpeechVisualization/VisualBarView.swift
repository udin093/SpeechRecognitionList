//
//  VisualBarView.swift
//  SpeechRecognitionList
//
//  Created by M Khalid Assiddiq on 03/06/24.
//

import SwiftUI

struct VisualBarView: View {
    
    var value: CGFloat
    var numberOfSamples : Int = 30
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(LinearGradient(gradient: Gradient(colors: [.black, .gray, .black]), startPoint: .top, endPoint: .bottom))
                .frame(width: (UIScreen.main.bounds.width - CGFloat(numberOfSamples) * 10) / CGFloat(numberOfSamples), height: value)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 3)
                .animation(.easeInOut(duration: 0.2), value: value)
        }
    }
}

#Preview {
    VisualBarView(value: 2.0, numberOfSamples: 10)
}
