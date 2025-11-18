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
    
    init() {
        do {
            // Initializes the database for the JournalEntry model
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
        }
    }
}
