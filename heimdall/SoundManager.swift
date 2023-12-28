import AudioKit
import SoundpipeAudioKit

class SoundManager {
    var engine: AudioEngine
    var oscillator: Oscillator

    init() {
        engine = AudioEngine()
        oscillator = Oscillator()
        oscillator.amplitude = 0.5  // Set the amplitude

        engine.output = oscillator

        do {
            try engine.start()
        } catch {
            print("Error starting AudioKit engine: \(error)")
        }
    }

    func start() {
        oscillator.start()
        print("Sound started")
    }

    func stop() {
        oscillator.stop()
        print("Sound stopped")
    }

    func updateFrequency(frequency: AUValue) {
        oscillator.frequency = frequency
    }
}
