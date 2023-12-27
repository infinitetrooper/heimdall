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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.playerNode.stop()
        }
    }

    private var lastPhase: Double = 0.0

    private func fillBuffer(buffer: AVAudioPCMBuffer, withFrequency frequency: Float, frameCount: AVAudioFrameCount) {
        let amplitude: Float = 0.5
        let sampleRate = Double(buffer.format.sampleRate)
        let waveLength = sampleRate / Double(frequency)

        buffer.frameLength = buffer.frameCapacity
        let channelData = buffer.floatChannelData![0]

        let fadeInLength = Int(Double(frameCount) * 0.1)
        let fadeOutLength = Int(Double(frameCount) * 0.1)
        let startFadeOutIndex = Int(frameCount) - fadeOutLength

        for frame in 0..<Int(frameCount) {
            let phase = 2.0 * .pi * (Double(frame) / waveLength)
            let sample = amplitude * Float(sin(lastPhase + phase))

            let fadeFactorIn = frame < fadeInLength ? Float(frame) / Float(fadeInLength) : 1.0
            let fadeFactorOut = frame >= startFadeOutIndex ? Float(startFadeOutIndex + fadeOutLength - frame) / Float(fadeOutLength) : 1.0

            channelData[frame] = sample * fadeFactorIn * fadeFactorOut
        }

        // Update last phase for the next buffer
        lastPhase += 2.0 * .pi * (Double(frameCount) / waveLength)
        lastPhase = fmod(lastPhase, 2.0 * .pi) // Keep phase within 0 to 2π
    }



    func stop() {
        playerNode.stop()
    }
}
