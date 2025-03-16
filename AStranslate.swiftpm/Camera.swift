import AVFoundation
import UIKit
import SwiftUI

/// Basic camera class: sets up an AVCaptureSession, preview layer, and captures frames.
class Camera: NSObject {
    let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "camera session queue")
    
    override init() {
        super.init()
        configureSession()
    }
    
    func configureSession() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
            print("❌ Unable to find front camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self,
                                                queue: DispatchQueue(label: "video output queue", qos: .userInteractive))
            
            captureSession.beginConfiguration()
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            captureSession.commitConfiguration()
        } catch {
            print("❌ Camera configuration error: \(error)")
        }
    }
    
    func start() {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    // Async wrapper for SwiftUI .task
    func startAsync() async {
        await withCheckedContinuation { continuation in
            start()
            continuation.resume()
        }
    }
    
    func setupPreview(in view: UIView) {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        view.layer.addSublayer(previewLayer!)
    }
}

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Update a live preview image (optional)
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        DispatchQueue.main.async {
            if let uiImage = ciImage.toUIImage() {
                AppModel.shared.viewfinderImage = uiImage
            }
        }
        
        // If this is MLCamera, run ML inference
        if let mlCamera = self as? MLCamera {
            Task {
                await mlCamera.gatherObservations(pixelBuffer: pixelBuffer)
            }
        }
    }
}

// Helper to convert CIImage -> UIImage
extension CIImage {
    func toUIImage() -> UIImage? {
        let context = CIContext()
        if let cgImage = context.createCGImage(self, from: extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
