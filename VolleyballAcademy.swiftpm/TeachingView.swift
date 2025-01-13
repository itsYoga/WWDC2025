import SwiftUI

struct TeachingView: View {
    let lessons = [
        ("Serving", "Start the rally with a serve.", "⚡"),
        ("Passing", "Control the ball to assist a teammate.", "🏐"),
        ("Spiking", "Strike the ball with power.", "🔥")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("🏐 Volleyball Basics")
                .font(.largeTitle)
                .padding()

            ForEach(lessons, id: \.0) { lesson in
                HStack {
                    Text(lesson.0)
                        .font(.headline)
                    Spacer()
                    Text(lesson.2)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }
}
