import AVFoundation
import Combine

class CameraManager: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var currentISO: Float = 0.0
    private var isoUpdateTimer: Timer?
    private var soundManager = SoundManager()
    let noteFrequencies = [261.63, // Sa (C)
                          293.66, // Re (D)
                          329.63, // Ga (E)
                          349.23, // Ma (F)
                          392.00, // Pa (G)
                          440.00, // Dha (A)
                          493.88, // Ni (B)
                          523.25] // Sa (C one octave higher)


    override init() {
        super.init()
        self.setupCamera()
        self.startUpdatingISO()
    }

    func setupCamera() {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            print("Unable to access camera")
            return
        }
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            }
        } catch {
            print("Unable to access camera: \(error)")
            return
        }

        let newPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        newPreviewLayer.videoGravity = .resizeAspectFill
        self.previewLayer = newPreviewLayer

        captureSession.startRunning()
    }
    
    private func updateCurrentISO() {
        DispatchQueue.main.async {
            if let iso = self.videoDeviceInput?.device.iso {
                self.currentISO = iso
                let frequency = self.mapISOTOFrequency(iso)
                self.soundManager.updateFrequency(frequency: frequency)
            }
        }
    }

    private func startUpdatingISO() {
        isoUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateCurrentISO()
        }
    }
    
    private func mapISOTOFrequency(_ isoValue: Float) -> Float {
        let maxISO: Float = 3200 // Example max ISO as a Float
        let segments: Float = 8 // Number of notes

        // Calculate the index based on ISO value
        let index = Int((isoValue / maxISO) * segments)

        // Make sure the index is within the array bounds
        let safeIndex = min(max(index, 0), noteFrequencies.count - 1)

        return Float(noteFrequencies[safeIndex])
    }

    
    func startSound() {
        soundManager.start()
    }

    func stopSound() {
        soundManager.stop()
    }

    deinit {
        isoUpdateTimer?.invalidate()
    }
}
