//
//  LockView.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import SwiftUI

struct LockView: View {
    @AppStorage("isAppLocked") var isAppLocked: Bool = false
    @State private var shake = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LiquidBackground()
                .blur(radius: 20) // Heavier blur for privacy
            
            VStack(spacing: 20) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Now. is Locked")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Button("Unlock") {
                    unlockApp()
                }
                .padding(.top, 20)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
            }
            .offset(x: shake ? 10 : 0)
            .animation(.default.repeatCount(3).speed(4), value: shake)
        }
        .onAppear {
            unlockApp()
        }
    }
    
    func unlockApp() {
        AuthenticationManager.authenticate { success in
            if success {
                withAnimation {
                    isAppLocked = false
                }
            } else {
                shake.toggle()
            }
        }
    }
}
