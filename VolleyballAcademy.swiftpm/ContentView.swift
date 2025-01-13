import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TeachingView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }

            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "questionmark.circle.fill")
                }

            TacticSimulatorView()
                .tabItem {
                    Label("Simulator", systemImage: "gamecontroller.fill")
                }

            MotionAnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }
        }
    }
}
