//
//  AnimationView.swift
//  VolleyballAcademy
//
//  Created by Jesse Liang on 2025/1/9.
//

import SwiftUI

struct AnimationView: View {
    @State private var ballPosition = CGPoint(x: 100, y: 100)

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all)

            Text("🏐")
                .font(.system(size: 50))
                .position(ballPosition)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        ballPosition = CGPoint(x: 300, y: 300)
                    }
                }
        }
    }
}
