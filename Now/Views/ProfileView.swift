//
//  ProfileView.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var entries: [JournalEntry]
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("userName") var userName: String = "Traveler"
    @AppStorage("userAgeRange") var userAgeRange: String = "N/A"
    @AppStorage("journalingPreference") var journalingPreference: String = "Night"
    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = false
    @AppStorage("isFaceIDEnabled") var isFaceIDEnabled: Bool = false

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

                    // User Identity
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

                    // Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PREFERENCES")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.leading, 8)
                            .padding(.top, 10)

                        // Notification Toggle
                        Toggle(isOn: $areNotificationsEnabled) {
                            HStack {
                                Image(systemName: "bell.fill").frame(width: 24)
                                VStack(alignment: .leading) {
                                    Text("Daily Reminders")
                                    Text(journalingPreference).font(.caption).opacity(0.7)
                                }
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

                        // FaceID Toggle
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
                        
                        // Export
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(width: 24)
                                Text("Export Data")
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
    }
}
