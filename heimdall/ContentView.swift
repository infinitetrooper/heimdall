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
    @State private var isPlaying = false
    private var notePlayer = NotePlayer()
    @State private var noteQueue: [Double] = []
    @State private var currentNoteIndex = 0

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
            Button("Capture and Play") {
                cameraManager.captureImage { image in
                    if let image = image {
                        processAndPlayImage(image)
                    }
                }
            }
            
            if isPlaying {
                Text("Playing...")
            } else {
                Text("Ready")
            }
        }
        
        .onAppear() {
            cameraManager.stopSound()
            isSoundPlaying = false
        }
    }
    
    private func processAndPlayImage(_ image: UIImage) {
        let segmentedColors = getSegmentedColors(from: image, gridRows: 10, gridColumns: 10)
        let notes = segmentedColors.map(mapColorToNote)

        notePlayer.playNotesSequence(notes, noteDuration: 0.25)
    }
}


#Preview {
    ContentView()
}
