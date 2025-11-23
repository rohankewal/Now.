//
//  ContentView.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/18/25.
//

import SwiftUI
import SwiftData

// MARK: - ROOT VIEW (ORCHESTRATOR)
struct ContentView: View {
    // Environment for SwiftData (Required to inject entries)
    @Environment(\.modelContext) private var modelContext

    // Persistent storage to track state across app launches
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("isAppLocked") var isAppLocked: Bool = false
    @AppStorage("isFaceIDEnabled") var isFaceIDEnabled: Bool = false
    
    var body: some View {
        ZStack {
            // 1. First Launch: Show Onboarding
            if !hasCompletedOnboarding {
                OnboardingView()
            }
            // 2. Backgrounded/Protected: Show Lock Screen
            else if isAppLocked && isFaceIDEnabled {
                LockView()
            }
            // 3. Normal Use: Show Main Journal
            else {
                JournalHomeView()
            }
        }
        // Smooth transitions between these major states
        .animation(.easeInOut, value: hasCompletedOnboarding)
        .animation(.easeInOut, value: isAppLocked)
    } 
}
