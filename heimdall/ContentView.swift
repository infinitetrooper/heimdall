//
//  ContentView.swift
//  heimdall
//
//  Created by Akhil Varma on 27/12/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var isSoundPlaying = true

    var body: some View {
        VStack {
            Toggle(isOn: $isSoundPlaying) {
                Text(isSoundPlaying ? "Stop Sound" : "Start Sound")
            }
            .padding()
            .onChange(of: isSoundPlaying) { newValue in
                if newValue {
                    cameraManager.startSound()
                } else {
                    cameraManager.stopSound()
                }
            }
            ZStack {
                CameraPreviewView(cameraManager: cameraManager)
                VStack {
                    Spacer()
                    Text("ISO: \(cameraManager.currentISO)")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
