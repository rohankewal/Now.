//
//  OnboardingView.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userAgeRange") var userAgeRange: String = ""
    @AppStorage("journalingPreference") var journalingPreference: String = "Night"
    
    @State private var currentTab = 0
    
    let ageRanges = ["Under 18", "18-24", "25-34", "35-44", "45-54", "55+"]
    let timePreferences = [
        ("Morning", "sun.max.fill", "Start your day with clarity."),
        ("Afternoon", "sun.min.fill", "A midday reset."),
        ("Night", "moon.stars.fill", "Reflect before rest.")
    ]
    
    var body: some View {
        ZStack {
            LiquidBackground()
            
            TabView(selection: $currentTab) {
                // Step 0: Welcome
                VStack(spacing: 20) {
                    Text("Now.")
                        .font(.system(size: 60, weight: .bold, design: .serif))
                    Text("Your space for clarity,\npresence, and peace.")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .opacity(0.8)
                }
                .tag(0)
                
                // Step 1: Name
                VStack(spacing: 30) {
                    Text("What should we call you?")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    TextField("Your Name", text: $userName)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .tint(.white)
                }
                .tag(1)
                
                // Step 2: Age Range
                VStack(spacing: 20) {
                    Text("Which age group represents you?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(ageRanges, id: \.self) { range in
                                Button(action: {
                                    userAgeRange = range
                                    withAnimation { currentTab = 3 }
                                }) {
                                    Text(range)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            userAgeRange == range
                                            ? AnyShapeStyle(Color.white)
                                            : AnyShapeStyle(.ultraThinMaterial)
                                        )
                                        .foregroundColor(userAgeRange == range ? .black : .white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .tag(2)
                
                // Step 3: Time Preference
                VStack(spacing: 20) {
                    Text("When do you prefer to reflect?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 16) {
                        ForEach(timePreferences, id: \.0) { pref, icon, desc in
                            Button(action: {
                                journalingPreference = pref
                                withAnimation { currentTab = 4 }
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading) {
                                        Text(pref)
                                            .fontWeight(.bold)
                                        Text(desc)
                                            .font(.caption)
                                            .opacity(0.8)
                                    }
                                    Spacer()
                                    
                                    if journalingPreference == pref {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                                .padding()
                                .background(
                                    journalingPreference == pref
                                    ? AnyShapeStyle(Color.white)
                                    : AnyShapeStyle(.ultraThinMaterial)
                                )
                                .foregroundColor(journalingPreference == pref ? .black : .white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .tag(3)
                
                // Step 4: Notifications
                VStack(spacing: 30) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 60))
                        .opacity(0.8)
                    
                    Text("Consistency is key.")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("We'll nudge you in the **\(journalingPreference.lowercased())** to return to the present moment.")
                        .multilineTextAlignment(.center)
                        .opacity(0.7)
                        .padding(.horizontal)
                    
                    Button("Enable Reminders") {
                        NotificationManager.requestPermission { granted in
                            if granted {
                                NotificationManager.scheduleDailyReminder(isEnabled: true, timePreference: journalingPreference)
                                UserDefaults.standard.set(true, forKey: "areNotificationsEnabled")
                            }
                            withAnimation { currentTab = 5 }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(25)
                    
                    Button("Maybe Later") {
                        withAnimation { currentTab = 5 }
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                }
                .tag(4)
                
                // Step 5: Finish
                VStack(spacing: 30) {
                    Text("You are ready.")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Button(action: {
                        withAnimation {
                            if userName.isEmpty { userName = "Traveler" }
                            hasCompletedOnboarding = true
                        }
                    }) {
                        Text("Begin Journey")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(30)
                    }
                }
                .tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .foregroundColor(.white)
        }
    }
}
