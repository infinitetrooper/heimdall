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
    @State private var notePlayer = NotePlayer()
    @State private var isPlaying = false

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
    }
    
    private func processAndPlayImage(_ image: UIImage) {
        let colors = getSegmentedColors(from: image)
        let notes = colors.map(mapColorToNote)

        playNotesSequence(notes)
    }
    
    private func playNotesSequence(_ notes: [Float]) {
        isPlaying = true

        // This is a simple approach to play notes one after another.
        // For more accurate timing, you might need a more sophisticated approach.
        DispatchQueue.global(qos: .userInitiated).async {
            for note in notes {
                DispatchQueue.main.async {
                    self.notePlayer.play(noteFrequency: note, duration: 0.5)
                }
                sleep(1) // Wait for the note to finish playing
            }
            DispatchQueue.main.async {
                self.isPlaying = false
            }
        }
    }
}


#Preview {
    ContentView()
}
