import UIKit
import AVFoundation
import Vision

final class CameraViewController: UIViewController {
    private var cameraFeedSession: AVCaptureSession?

    override func loadView() {
        view = CameraPreview()
    }

    private var cameraView: CameraPreview { view as! CameraPreview }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
                cameraView.previewLayer.videoGravity = .resizeAspectFill
            }
            DispatchQueue.global(qos: .userInteractive).async {
                self.cameraFeedSession?.startRunning()
            }
        } catch {
            print("Camera setup error: \(error.localizedDescription)")
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewDidDisappear(animated)
    }

    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedOutput", qos: .userInteractive)

    func setupAVSession() throws {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw NSError(domain: "MagiCode", code: -1, userInfo: [NSLocalizedDescriptionKey: "No front camera available."])
        }
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw NSError(domain: "MagiCode", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to access camera input."])
        }

        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .high

        guard session.canAddInput(deviceInput) else {
            throw NSError(domain: "MagiCode", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot add input to session."])
        }
        session.addInput(deviceInput)

        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        }

        session.commitConfiguration()
        cameraFeedSession = session
    }

    var pointsProcessorHandler: (([CGPoint]) -> Void)?

    func processPoints(_ fingerTips: [CGPoint]) {
        let convertedPoints = fingerTips.map {
            cameraView.previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
        }
        pointsProcessorHandler?(convertedPoints)
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var fingerTips: [CGPoint] = []
        defer {
            DispatchQueue.main.sync {
                self.processPoints(fingerTips)
            }
        }

        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            let handPoseRequest = VNDetectHumanHandPoseRequest()
            handPoseRequest.maximumHandCount = 1
            try requestHandler.perform([handPoseRequest])
            guard let observations = handPoseRequest.results?.prefix(1), !observations.isEmpty else { return }
            for observation in observations {
                let recognizedPoints = try observation.recognizedPoints(.all)
                if let thumbTip = recognizedPoints[.thumbTip] {
                    fingerTips.append(CGPoint(x: thumbTip.location.x, y: 1 - thumbTip.location.y))
                }
            }
        } catch {
            print("Error processing hand pose: \(error.localizedDescription)")
        }
    }
}
