//
//  ContentView.swift
//  MagiCode
//
//  Created by Vedant Malhotra on 2/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var overlayPoints: [CGPoint] = []

    var body: some View {
        NavigationView {
            ZStack {
                CameraView { overlayPoints = $0 }
                    .ignoresSafeArea()
                    .opacity(0.1)

                VStack {
                    Text("MagiCode")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Hand Tracking Demo")
                        .foregroundColor(.white.opacity(0.8))

                    Spacer()

                    if !overlayPoints.isEmpty {
                        Text("Thumb Position: \(overlayPoints.first?.description ?? "Unknown")")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
}
