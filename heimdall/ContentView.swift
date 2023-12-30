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
    private var notePlayer = NotePlayer()
    @State private var noteQueue: [Double] = []
    @State private var currentNoteIndex = 0
    @State private var currentColor = UIColor.clear

    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                ZStack {
                    CameraPreviewView(cameraManager: cameraManager)
                    
                    // ISO Display at the bottom
                    VStack {
                        Spacer()
                        HStack {
                            Text("ISO: \(Int(cameraManager.currentISO))")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                            
                            Spacer()
                            
                            // Toggle for Sound Playing
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
                        }
                        .padding()
                    }
                }
                Spacer() // Pushes everything above to the top
                Button("Capture and Play") {
                    cameraManager.captureImage { image in
                        if let image = image {
                            processAndPlayImage(image)
                        }
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .font(.headline)
                .cornerRadius(10)
                .padding(20)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .overlay(
                Color(currentColor)
                    .opacity(0.5) // Adjust opacity for translucency
                    .edgesIgnoringSafeArea(.all)
            )
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear() {
            cameraManager.stopSound()
            isSoundPlaying = false
            notePlayer.onColorChange = { color in
                self.currentColor = color
            }
        }
    }
    
    private func processAndPlayImage(_ image: UIImage) {
        let colors = getSegmentedColors(from: image, gridRows: 10, gridColumns: 10)
        let notes = colors.map(mapColorToNote)

        notePlayer.playNotesInRhythm(notes, colors: colors, baseNoteDuration: 0.2, gapDuration: 0.1)
        //notePlayer.playNotesSequence(notes, noteDuration: 0.25)
    }
}


#Preview {
    ContentView()
}
