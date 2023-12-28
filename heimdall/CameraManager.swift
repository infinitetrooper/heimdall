import AVFoundation
import Combine
import UIKit

class CameraManager: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var photoOutput = AVCapturePhotoOutput()
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var currentISO: Float = 0.0
    private var isoUpdateTimer: Timer?
    private var soundManager = SoundManager()
    
    typealias ImageCaptureCompletion = (UIImage?) -> Void
    private var imageCaptureCompletion: ImageCaptureCompletion?


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
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
        } catch {
            print("Unable to access camera: \(error)")
            return
        }

        let newPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        newPreviewLayer.videoGravity = .resizeAspectFill
        self.previewLayer = newPreviewLayer

        startSession()
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            // Any other setup that needs to be done when the session starts
        }
    }
    
    func captureImage(completion: @escaping ImageCaptureCompletion) {
        self.imageCaptureCompletion = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
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

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)
            imageCaptureCompletion?(image)
        } else {
            imageCaptureCompletion?(nil)
        }
        // Reset the completion handler
        imageCaptureCompletion = nil
    }
}
