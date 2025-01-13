import SwiftUI
import SpriteKit

struct TacticSimulatorView: View {
    var body: some View {
        VStack {
            Text("🏐 Drag players to create a tactic")
                .font(.headline)
                .padding()

            TacticFieldView()
                .frame(height: 400)
                .background(Color.green.opacity(0.2))
                .cornerRadius(10)

            Button("▶️ Simulate") {
                // 動畫播放按鈕
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct TacticFieldView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        let scene = TacticScene(size: CGSize(width: 300, height: 400))
        view.presentScene(scene)
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {}
}

class TacticScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .white
        for i in 0..<6 {
            let player = SKShapeNode(circleOfRadius: 20)
            player.fillColor = .blue
            player.position = CGPoint(x: CGFloat(50 + i * 40), y: size.height / 2)
            player.name = "player\(i)"
            addChild(player)
        }
    }
}
