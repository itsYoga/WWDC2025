import SwiftUI

struct QuizView: View {
    @State private var questionIndex = 0
    @State private var score = 0
    private let questions = [
        ("What is the maximum number of players on the court for one team?", "6"),
        ("What is the name of the skill used to receive a serve?", "Pass")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Quiz Time")
                .font(.largeTitle)
                .padding()

            Text(questions[questionIndex].0)
                .font(.title2)
                .padding()

            TextField("Your Answer", text: Binding(
                get: { "" },
                set: { answer in
                    if answer.lowercased() == questions[questionIndex].1.lowercased() {
                        score += 1
                    }
                    questionIndex = (questionIndex + 1) % questions.count
                }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            Text("Score: \(score)")
                .font(.title2)
        }
        .padding()
    }
}
