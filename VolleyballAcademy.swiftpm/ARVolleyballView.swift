import SwiftUI
import RealityKit

struct ARVolleyballView: View {
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
