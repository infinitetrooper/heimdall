import AudioKit
import AVFoundation
import SoundpipeAudioKit

class NotePlayer {
    var engine: AudioEngine
    var oscillator: Oscillator
    var envelope: AmplitudeEnvelope
    
    private var isPlaying: Bool = false

    init() {
        // Initialize the Audio Engine and components
        engine = AudioEngine()
        oscillator = Oscillator()
        envelope = AmplitudeEnvelope(oscillator)
        
        // Configure the envelope
        envelope.attackDuration = 0.5  // Fast attack
        envelope.decayDuration = 0.25    // Decay
        envelope.sustainLevel = 0.5     // Sustain level
        envelope.releaseDuration = 0.25  // Slightly longer release

        // Connect the envelope to the engine's output
        engine.output = envelope

        // Start the engine
        do {
            try engine.start()
        } catch {
            print("Audio Engine didn't start: \(error)")
        }
    }

    func play(noteFrequency: Double, duration: TimeInterval) {
        guard !isPlaying else { return }
        
        isPlaying = true
        oscillator.frequency = AUValue(noteFrequency)
        oscillator.start()
        envelope.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.envelope.stop()

            let releaseDuration = TimeInterval(self.envelope.releaseDuration)
            DispatchQueue.main.asyncAfter(deadline: .now() + releaseDuration) {
                self.oscillator.stop()
                self.isPlaying = false
            }
        }
    }


    deinit {
        // Stop the engine when the note player is deinitialized
        do {
            try engine.stop()
        } catch {
            print("Audio Engine didn't stop: \(error)")
        }
    }
}
