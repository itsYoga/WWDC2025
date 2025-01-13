import SwiftUI

struct MotionAnalysisView: View {
    var body: some View {
        VStack {
            Text("🏐 Analyze Your Moves")
                .font(.headline)
                .padding()

            Button("Start Analysis") {
                // 啟動分析邏輯
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
    }
}
