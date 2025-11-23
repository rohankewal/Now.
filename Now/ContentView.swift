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
    
    // MARK: - SCREENSHOT DATA GENERATOR
    /*func addScreenshotData() {
        do {
            // 1. Clear existing data to prevent duplicates
            try modelContext.delete(model: JournalEntry.self)
            
            // 2. Create the 5 sample entries
            let samples = [
                JournalEntry(
                    moodScore: 0.9,
                    prompt: "What would make today great?",
                    content: "Woke up before the alarm. The house is quiet. If I can just get two solid hours of deep work done on the project before the meetings start, today will be a win. Coffee is brewing. I am ready."
                ),
                JournalEntry(
                    moodScore: 0.3,
                    prompt: "What is weighing on your mind right now?",
                    content: "I feel like I'm behind on everything. The launch date is creeping up and I'm doubting the design choices. I need to remember: Focus on what I can control. The effort is mine; the outcome is not."
                ),
                JournalEntry(
                    moodScore: 0.75,
                    prompt: "How did you practice discipline today?",
                    content: "I wanted to doom-scroll when I got home, but I put the phone in the drawer and read for 30 minutes instead. It was hard at first, but my mind feels so much clearer now."
                ),
                JournalEntry(
                    moodScore: 0.6,
                    prompt: "What is a small win you had recently?",
                    content: "I actually listened during the conversation with Sarah instead of thinking about what I was going to say next. It felt like a genuine connection."
                ),
                JournalEntry(
                    moodScore: 0.85,
                    prompt: "Write one thing you are grateful for.",
                    content: "The sunlight hitting the desk this afternoon. It was just a fleeting moment, but it reminded me to pause and just breathe. Beautiful."
                )
            ]
            
            // 3. Insert them with staggered timestamps (spaced 4 hours apart)
            for (index, entry) in samples.enumerated() {
                entry.timestamp = Date().addingTimeInterval(Double(-index * 3600 * 4))
                modelContext.insert(entry)
            }
            
            print("📸 Screenshot data injected successfully!")
            
        } catch {
            print("Failed to inject screenshot data: \(error)")
        }
    }*/
}
