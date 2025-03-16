import AVFoundation
import Vision
import UIKit

/// A small struct to store x, y, and confidence for each joint.
struct MyRecognizedPoint {
    let x: Float
    let y: Float
    let confidence: Float
}

/// Subclass of Camera that performs Vision-based hand pose detection and runs the ASL model.
class MLCamera: Camera {
    let aslModel = try? ASLModel(configuration: MLModelConfiguration())
    
    // Joints your model expects: wrist, thumb, index, middle, ring, little
    let requiredJoints: [VNHumanHandPoseObservation.JointName] = [
        .wrist,
        .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
        .indexMCP, .indexPIP, .indexDIP, .indexTip,
        .middleMCP, .middlePIP, .middleDIP, .middleTip,
        .ringMCP, .ringPIP, .ringDIP, .ringTip,
        .littleMCP, .littlePIP, .littleDIP, .littleTip
    ]
    
    /// Async function that detects hand poses and runs the ML model.
    func gatherObservations(pixelBuffer: CVPixelBuffer) async {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
            guard let observation = request.results?.first else { return }
            
            let recognizedPoints = try observation.recognizedPoints(.all)
            
            // Convert recognized points into MyRecognizedPoint array
            var myPoints: [MyRecognizedPoint] = []
            myPoints.reserveCapacity(requiredJoints.count)
            
            for joint in requiredJoints {
                if let rp = recognizedPoints[joint], rp.confidence > 0.3 {
                    // Cast each rp.x, rp.y, rp.confidence to Float individually
                    myPoints.append(
                        MyRecognizedPoint(
                            x: Float(rp.x),
                            y: Float(rp.y),
                            confidence: Float(rp.confidence)
                        )
                    )
                } else {
                    myPoints.append(MyRecognizedPoint(x: 0, y: 0, confidence: 0))
                }
            }
            
            // Convert points to 1×3×21 MLMultiArray
            if let multiArray = keypointsToMultiArray(points: myPoints) {
                if let model = aslModel {
                    // Run the ASL model
                    if let prediction = try? model.prediction(poses: multiArray) {
                        DispatchQueue.main.async {
                            // Update predictions
                            AppModel.shared.immediatePrediction = prediction.label
                            // Optionally implement smoothing, for now just set stable directly
                            AppModel.shared.stablePrediction = prediction.label
                        }
                    }
                }
            }
            
            // Update skeleton overlay on main thread
            DispatchQueue.main.async {
                // Convert from Vision coords (lower-left origin) to SwiftUI (upper-left origin)
                let converted = myPoints.map { pt in
                    CGPoint(x: CGFloat(pt.x), y: 1 - CGFloat(pt.y))
                }
                AppModel.shared.handKeypoints = converted
            }
            
        } catch {
            print("Error in hand pose detection: \(error)")
        }
    }
    
    /// Builds the 1×3×21 multiarray (time=1, [x,y,confidence], 21 joints).
    private func keypointsToMultiArray(points: [MyRecognizedPoint]) -> MLMultiArray? {
        guard let multiArray = try? MLMultiArray(shape: [1, 3, 21], dataType: .float32) else {
            return nil
        }
        for (i, pt) in points.enumerated() {
            multiArray[[0, 0, NSNumber(value: i)]] = NSNumber(value: pt.x)
            multiArray[[0, 1, NSNumber(value: i)]] = NSNumber(value: pt.y)
            multiArray[[0, 2, NSNumber(value: i)]] = NSNumber(value: pt.confidence)
        }
        return multiArray
    }
}
