import SwiftUI

struct HandSkeletonOverlayView: View {
    let points: [CGPoint]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(points.indices, id: \.self) { index in
                let point = points[index]
                Circle()
                    .fill(Color.green.opacity(0.8))
                    .frame(width: 8, height: 8)
                    .position(
                        x: point.x * geometry.size.width,
                        y: point.y * geometry.size.height
                    )
            }
        }
    }
}

struct HandSkeletonOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        HandSkeletonOverlayView(points: [CGPoint(x: 0.5, y: 0.5)])
    }
}
