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
        let segmentedColors = getSegmentedColors(from: image, gridRows: 4, gridColumns: 4)
        let notes = segmentedColors.map(mapColorToNote)

        playNotesSequence(notes)
    }
    
    private func playNotesSequence(_ notes: [Float], noteDuration: TimeInterval = 0.25) {
        isPlaying = true

        DispatchQueue.global(qos: .userInitiated).async {
            for note in notes {
                DispatchQueue.main.sync {
                    self.notePlayer.play(noteFrequency: note, duration: noteDuration)
                }
                // Wait for the note to finish playing, plus a small gap between notes
                Thread.sleep(forTimeInterval: noteDuration + 0.1)
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
