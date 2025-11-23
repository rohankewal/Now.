//
//  ProfileView.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ProfileView: View {
    @Query(sort: \JournalEntry.timestamp, order: .reverse) private var entries: [JournalEntry]
    @Environment(\.dismiss) private var dismiss
    
    // User Preferences
    @AppStorage("userName") var userName: String = "Traveler"
    @AppStorage("userAgeRange") var userAgeRange: String = "N/A"
    @AppStorage("journalingPreference") var journalingPreference: String = "Night"
    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = false
    @AppStorage("isFaceIDEnabled") var isFaceIDEnabled: Bool = false

    // Export State
    @State private var isExporting = false
    @State private var document: JournalBackupFile?

    var totalEntries: Int { entries.count }
    var currentStreak: Int { return entries.isEmpty ? 0 : 1 }
    
    var averageMood: String {
        if entries.isEmpty { return "N/A" }
        let total = entries.reduce(0) { $0 + $1.moodScore }
        let average = total / Double(entries.count)
        switch average {
        case 0..<0.2: return "Heavy"
        case 0.2..<0.4: return "Anxious"
        case 0.4..<0.6: return "Neutral"
        case 0.6..<0.8: return "Calm"
        case 0.8...1.0: return "Radiant"
        default: return "Present"
        }
    }

    var body: some View {
        ZStack {
            LiquidBackground()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Profile")
                            .font(.system(size: 40, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)

                    // Identity
                    VStack(spacing: 12) {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(userName.prefix(1).uppercased())
                                    .font(.system(size: 40, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                            )
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            .shadow(radius: 10)

                        Text(userName)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text("Mindful Member • \(userAgeRange)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.vertical)

                    // Stats
                    HStack(spacing: 12) {
                        StatCard(title: "Entries", value: "\(totalEntries)")
                        StatCard(title: "Day Streak", value: "\(currentStreak)")
                        StatCard(title: "Avg Mood", value: averageMood)
                    }
                    .padding(.horizontal)

                    // Settings Area
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PREFERENCES")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.leading, 8)
                            .padding(.top, 10)

                        // 1. Notification Toggle
                        Toggle(isOn: $areNotificationsEnabled) {
                            HStack {
                                Image(systemName: "bell.fill").frame(width: 24)
                                Text("Daily Reminders")
                            }
                        }
                        .padding()
                        .liquidGlass()
                        .foregroundColor(.white)
                        .onChange(of: areNotificationsEnabled) { oldValue, newValue in
                            if newValue {
                                NotificationManager.requestPermission { granted in
                                    if granted {
                                        NotificationManager.scheduleDailyReminder(isEnabled: true, timePreference: journalingPreference)
                                    } else {
                                        areNotificationsEnabled = false
                                    }
                                }
                            } else {
                                NotificationManager.scheduleDailyReminder(isEnabled: false)
                            }
                        }
                        
                        // 2. Time Preference Picker (New Feature)
                        if areNotificationsEnabled {
                            HStack {
                                Image(systemName: "clock.fill").frame(width: 24)
                                Text("Reminder Time")
                                Spacer()
                                Picker("Time", selection: $journalingPreference) {
                                    Text("Morning").tag("Morning")
                                    Text("Afternoon").tag("Afternoon")
                                    Text("Night").tag("Night")
                                }
                                .tint(.white)
                                .pickerStyle(.menu)
                            }
                            .padding()
                            .liquidGlass()
                            .foregroundColor(.white)
                            .onChange(of: journalingPreference) { oldValue, newValue in
                                // Reschedule immediately when changed
                                NotificationManager.scheduleDailyReminder(isEnabled: true, timePreference: newValue)
                            }
                        }

                        // 3. FaceID Toggle
                        Toggle(isOn: $isFaceIDEnabled) {
                            HStack {
                                Image(systemName: "faceid").frame(width: 24)
                                Text("Face ID Lock")
                            }
                        }
                        .padding()
                        .liquidGlass()
                        .foregroundColor(.white)
                        .onChange(of: isFaceIDEnabled) { oldValue, newValue in
                            if newValue {
                                AuthenticationManager.authenticate { success in
                                    if !success { isFaceIDEnabled = false }
                                }
                            }
                        }
                        
                        // 4. Working Export Button
                        Button(action: prepareExport) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(width: 24)
                                Text("Export Data (JSON)")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .padding()
                            .liquidGlass()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 50)
            }
        }
        // This triggers the iOS "Save to Files" sheet
        .fileExporter(
            isPresented: $isExporting,
            document: document,
            contentType: .json,
            defaultFilename: "Now_Journal_Backup"
        ) { result in
            if case .success = result {
                print("Export successful")
            } else {
                print("Export failed")
            }
        }
    }
    
    // Logic to convert SwiftData entries to JSON
    func prepareExport() {
        let exportableEntries = entries.map { entry in
            ExportableEntry(
                date: entry.timestamp,
                moodLabel: entry.moodLabel,
                moodScore: entry.moodScore,
                prompt: entry.prompt,
                content: entry.content
            )
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        if let data = try? encoder.encode(exportableEntries),
           let jsonString = String(data: data, encoding: .utf8) {
            self.document = JournalBackupFile(text: jsonString)
            self.isExporting = true
        }
    }
}
