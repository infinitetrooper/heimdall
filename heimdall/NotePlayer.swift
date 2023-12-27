import AVFoundation
import UIKit

class NotePlayer {
    private var audioEngine: AVAudioEngine
    private var playerNode: AVAudioPlayerNode

    init() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)

        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }

    func play(noteFrequency: Float, duration: TimeInterval) {
        let outputFormat = audioEngine.mainMixerNode.outputFormat(forBus: 0)
        let frameCount = AVAudioFrameCount(outputFormat.sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: frameCount)!

        fillBuffer(buffer: buffer, withFrequency: noteFrequency, frameCount: frameCount)
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)

        if !playerNode.isPlaying {
            playerNode.play()
        }
    }

    private func fillBuffer(buffer: AVAudioPCMBuffer, withFrequency frequency: Float, frameCount: AVAudioFrameCount) {
        let waveLength = Double(buffer.format.sampleRate) / Double(frequency)
        let amplitude: Float = 0.5

        buffer.frameLength = buffer.frameCapacity
        let channelData = buffer.floatChannelData![0]

        for frame in 0..<Int(frameCount) {
            let sample = amplitude * Float(sin(2.0 * .pi / waveLength * Double(frame)))
            channelData[frame] = sample
        }
    }

    func stop() {
        playerNode.stop()
    }
}
