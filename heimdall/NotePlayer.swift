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
            }
        }
    }
    
    func playNotesInRhythm(_ notes: [MIDINoteNumber], baseNoteDuration: TimeInterval, gapDuration: TimeInterval) {
        var cumulativeDelay: TimeInterval = 0
        var lastNote: MIDINoteNumber? = nil
        var currentNoteDuration = baseNoteDuration

        for note in notes {
            if note == lastNote {
                // If the note is the same as the last one, increase its duration
                currentNoteDuration += baseNoteDuration
            } else {
                // If it's a new note, play the last note with the accumulated duration
                if let lastNote = lastNote {
                    scheduleNote(lastNote, at: cumulativeDelay, duration: currentNoteDuration)
                    cumulativeDelay += currentNoteDuration + gapDuration
                }
                // Reset the duration and set the new note as the last note
                currentNoteDuration = baseNoteDuration
                lastNote = note
            }
        }
        // Schedule the last note
        if let lastNote = lastNote {
            scheduleNote(lastNote, at: cumulativeDelay, duration: currentNoteDuration)
        }
    }

    private func scheduleNote(_ note: MIDINoteNumber, at delay: TimeInterval, duration: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.play(note, duration: duration)
        }
    }

    private func play(_ note: MIDINoteNumber, duration: TimeInterval) {
        print(note, duration)
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
