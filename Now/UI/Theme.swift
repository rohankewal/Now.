//
//  Theme.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import SwiftUI

// MARK: - LIQUID GLASS EFFECT
struct LiquidGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}

extension View {
    func liquidGlass() -> some View {
        self.modifier(LiquidGlassCard())
    }
}

// MARK: - ANIMATED BACKGROUND
struct LiquidBackground: View {
    @State private var moveBlobs = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            // Blob 1: Deep Purple
            Circle()
                .fill(Color.purple.opacity(0.4))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: moveBlobs ? -100 : 100, y: moveBlobs ? -150 : 150)
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: moveBlobs)
            // Blob 2: Teal/Blue
            Circle()
                .fill(Color.blue.opacity(0.4))
                .frame(width: 350, height: 350)
                .blur(radius: 70)
                .offset(x: moveBlobs ? 120 : -120, y: moveBlobs ? 200 : -200)
                .animation(.easeInOut(duration: 12).repeatForever(autoreverses: true), value: moveBlobs)
            // Blob 3: Accent Pink
            Circle()
                .fill(Color.pink.opacity(0.2))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: moveBlobs ? -150 : 150, y: moveBlobs ? 50 : -50)
                .animation(.easeInOut(duration: 15).repeatForever(autoreverses: true), value: moveBlobs)
        }
        .ignoresSafeArea()
        .onAppear {
            moveBlobs.toggle()
        }
    }
}
