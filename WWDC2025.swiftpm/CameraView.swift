import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    var pointsProcessorHandler: (([CGPoint]) -> Void)?

    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.pointsProcessorHandler = pointsProcessorHandler
        return cameraViewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
