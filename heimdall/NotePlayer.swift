import AudioKit
import AVFoundation

class NotePlayer {
    var engine: AudioEngine
    var sampler: AppleSampler

    init() {
        engine = AudioEngine()
        sampler = AppleSampler()
        engine.output = sampler

        do {
            try engine.start()
        } catch {
            print("Audio Engine didn't start: \(error)")
        }
    }

    func playNotesSequence(_ notes: [MIDINoteNumber], noteDuration: TimeInterval) {
        for (index, note) in notes.enumerated() {
            let delay = noteDuration * Double(index)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.play(note, duration: noteDuration)
                print(note)
            }
        }
    }

    private func play(_ note: MIDINoteNumber, duration: TimeInterval) {
        sampler.play(noteNumber: note, velocity: 127, channel: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.sampler.stop(noteNumber: note)
        }
    }

    deinit {
        do {
            try engine.stop()
        } catch {
            print("Audio Engine didn't stop: \(error)")
        }
    }
}
