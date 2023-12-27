import AVFoundation

class SoundManager {
    var audioEngine: AVAudioEngine
    var playerNode: AVAudioPlayerNode
    var buffer: AVAudioPCMBuffer

    init() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        let frameCapacity = AVAudioFrameCount(format?.sampleRate ?? 44100)
        buffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: frameCapacity)!

        fillBuffer(withFrequency: 440) // A default frequency

        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.outputNode, format: format)

        try? audioEngine.start()
        playerNode.play()
    }

    func fillBuffer(withFrequency frequency: Float) {
        let sampleRate = buffer.format.sampleRate
        let length = sampleRate * 1.0 // 1 second buffer
        buffer.frameLength = AVAudioFrameCount(length)

        let waveLength = sampleRate / Double(frequency)
        let amplitude: Float = 0.5

        for frame in 0..<Int(buffer.frameLength) {
            let angle = (2.0 * .pi / waveLength) * Double(frame)
            let sample = Float(sin(angle)) * amplitude
            buffer.floatChannelData?.pointee[frame] = sample
        }
    }

    func start() {
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
                playerNode.play()
                print("Sound started")
            } catch {
                print("Error starting sound: \(error)")
            }
        }
    }

    func stop() {
        if audioEngine.isRunning {
            playerNode.stop()
            audioEngine.stop()
            print("Sound stopped")
        }
    }

    func updateFrequency(frequency: Float) {
        fillBuffer(withFrequency: frequency)
        playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
    }
    


    deinit {
        playerNode.stop()
        audioEngine.stop()
    }
}
