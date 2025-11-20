//
//  BreathingSpaceView.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import SwiftUI

struct BreathingSpaceView: View {
    @State private var breathe = false
    let quote: String
    
    var body: some View {
        ZStack {
            LiquidBackground()
            
            // Breathing Circle
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: breathe ? 300 : 150, height: breathe ? 300 : 150)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breathe)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        .scaleEffect(breathe ? 1.2 : 0.8)
                        .opacity(breathe ? 0 : 1)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breathe)
                )
            
            VStack(spacing: 30) {
                Image(systemName: "wind")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.5))
                
                Text(quote)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .shadow(color: .black.opacity(0.5), radius: 10)
                
                Text("Breathe in... Breathe out...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 20)
            }
        }
        .onAppear {
            breathe = true
        }
    }
}
