//
//  NowApp.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/18/25.
//

import SwiftUI
import SwiftData

// MARK: - APP ENTRY POINT
@main
struct NowApp: App {
    let container: ModelContainer
    
    // Track scene phase to lock app when backgrounded
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled: Bool = false
    @AppStorage("isAppLocked") private var isAppLocked: Bool = false
    
    init() {
        do {
            container = try ModelContainer(for: JournalEntry.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .preferredColorScheme(.dark)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    // If the app goes into the background and FaceID is on, lock it.
                    if newPhase == .background && isFaceIDEnabled {
                        isAppLocked = true
                    }
                }
        }
    }
}
